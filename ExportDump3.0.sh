#!/bin/bash

#Version=3.0

#2021-12-19----Soheil Mamdouhi

#Oracle database variables
ORACLE_SID=rcfsdb;
ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1;
NLS_LANG=.AR8MSWIN1256;
DBUser=rcfs;
DBPassword=123sfcr;
DBDirectory=dmp;
FileNamePrefix=fst;
Schema=rcfs;

#Backup Flags
EnablePrimaryBackupServer=YES;
EnableSecondaryBackupServer=NO;
EnableDeleteBackupFiles=NO;

DeleteLocalFilesTime=$(date --date="1 days ago" +%Y%m%d);
DeletePrimaryBackupFilesTime=$(date --date="1 days ago" +%Y%m%d);
DeleteSecondaryBackupFilesTime=$(date --date="1 days ago" +%Y%m%d);

MD5SumOrgFile=null;
MD5SumBackupFile=null;
CurrentDate=$(date +%Y%m%d);

#Paths and File names
DumpPath=/u01/dump;
PrimaryBackupPath=/u01/backup/logical;
SecondaryBackupPath=/u02/backup/logical;
LogFileName=DBBackupDMP_$Schema_$CurrentDate.log;
LogPath=/u01/Logs;

#Create Logs Directory if is not exist
if [[ ! -d "$LogPath" ]] ; then
	mkdir -p $LogPath;
fi

#Create primary backup server path if not exist
if [[ $EnablePrimaryBackupServer == "YES" ]] ; then
	if [[ ! -d "$PrimaryBackupPath" ]] ; then
		mkdir -p $PrimaryBackupPath;
	fi
fi

#Create secondary backup server path if not exist
if [[ $EnableSecondaryBackupServer == "YES" ]] ; then
	if [[ ! -d "$SecondaryBackupPath" ]] ; then
		mkdir -p $SecondaryBackupPath;
	fi
fi

#Create a dump file
echo $(date)"	Start creating dump." > $LogPath/$LogFileName;

#$ORACLE_HOME/bin/expdp "'"'$DBUser'/'$DBPassword' as sysdba"'" directory=$DBDirectory status=60 dumpfile=$FileNamePrefix_$CurrentDate.dmp logfile=$FileNamePrefix_$CurrentDate.log schemas=$Schema;
$ORACLE_HOME/bin/expdp $DBUser/$DBPassword directory=$DBDirectory dumpfile=$FileNamePrefix'_'$CurrentDate.dmp logfile=$FileNamePrefix'_'$CurrentDate.log INCLUDE=TABLE:LIKE"('FST%')";
echo $(date)"	End of creating dump." >> $LogPath/$LogFileName;

#Send last line of DUMP log to a variable
LogLastLine=$(tail -1 $DumpPath/$FileNamePrefix'_'$CurrentDate.log);
SuccessSTR='successfully completed at';

#To check creating dump was successful or not.
#If creating of dump was successful no action made but if not creating a dump start again
if [[ "$LogLastLine" != *"$SuccessSTR"* ]] ; then
	echo "Last dump is failed." >> $LogPath/$LogFileName;
	echo $(date)"	Start creating dump second try." >> $LogPath/$LogFileName;
	/bin/rm -rf $DumpPath/$FileNamePrefix'_'$CurrentDate.*;
	$ORACLE_HOME/bin/expdp $DBUser/$DBPassword directory=$DBDirectory dumpfile=$FileNamePrefix'_'$CurrentDate.dmp logfile=$FileNamePrefix'_'$CurrentDate.log INCLUDE=TABLE:LIKE"('FST%')";
	echo $(date)"	End of creating dump(second try)." >> $LogPath/$LogFileName;
fi

#Remove last days dump
/bin/rm -rf $DumpPath/$FileNamePrefix'_'$DeleteLocalFilesTime.dmp.gz;

#Compressing new dmp file.
echo $(date)"	Start compressing $DumpPath/$FileNamePrefix"_"$CurrentDate.dmp." >> $LogPath/$LogFileName;
gzip $DumpPath/$FileNamePrefix'_'$CurrentDate.dmp;
echo $(date)"	End of compressing $DumpPath/$FileNamePrefix"_"$CurrentDate.dmp." >> $LogPath/$LogFileName;

#Calculating MD5Sum for DMP file in local system
echo $(date)"	Start of calculating MD5 checksum of $DumpPath/$FileNamePrefix"_"$CurrentDate.dmp.gz." >> $LogPath/$LogFileName;
MD5SumOrgFile=$(md5sum $DumpPath/$FileNamePrefix'_'$CurrentDate.dmp.gz);
MD5SumOrgFile=`echo $MD5SumOrgFile|cut -d' ' -f1`;
echo $MD5SumOrgFile >> $LogPath/$LogFileName;
echo $(date)"	End of calculating MD5 checksum of $DumpPath/$FileNamePrefix"_"$CurrentDate.dmp.gz." >> $LogPath/$LogFileName;

#Try copy dump file to primary backup location
if [[ $EnablePrimaryBackupServer == "YES" ]] ; then
	for Counter in {1..4}
	do
		echo $(date)"	Start of copy to Backup server." >> $LogPath/$LogFileName;
		/bin/cp -rf $DumpPath/$FileNamePrefix'_'$CurrentDate.* $PrimaryBackupPath;
		echo $(date)"	End of copy to Backup server." >> $LogPath/$LogFileName;

		echo $(date)"	Start of calculating MD5 checksum of $PrimaryBackupPath/$FileNamePrefix"_"$CurrentDate.dmp.gz."$(date) >> $LogPath/$LogFileName;
		MD5SumBackupFile=$(md5sum $PrimaryBackupPath/$FileNamePrefix'_'$CurrentDate.dmp.gz);
		echo $MD5SumBackupFile >> $LogPath/$LogFileName;
		echo $(date)"	End of calculating MD5 checksum of $PrimaryBackupPath/$FileNamePrefix"_"$CurrentDate.dmp.gz."$(date) >> $LogPath/$LogFileName;
		
		MD5SumBackupFile=`echo $MD5SumBackupFile|cut -d' ' -f1`;
		
		if [[ $MD5SumOrgFile == $MD5SumBackupFile ]] ; then
			echo $(date)"	File correctly copied." >> $LogPath/$LogFileName;
			break;
		fi
	done
fi

#Try copy dump file to secondary backup location
if [[ $EnableSecondaryBackupServer == "YES" ]] ; then
	for Counter in {1..4}
	do
		echo $(date)"	Start of copy to Backup server." >> $LogPath/$LogFileName;
		/bin/cp -rf $DumpPath/$FileNamePrefix'_'$CurrentDate.* $SecondaryBackupPath;
		echo $(date)"	End of copy to Backup server." >> $LogPath/$LogFileName;

		echo $(date)"	Start of calculating MD5 checksum of $SecondaryBackupPath/$FileNamePrefix"_"$CurrentDate.dmp.gz."$(date) >> $LogPath/$LogFileName;
		MD5SumBackupFile=$(md5sum $SecondaryBackupPath/$FileNamePrefix'_'$CurrentDate.dmp.gz);
		echo $MD5SumBackupFile >> $LogPath/$LogFileName;
		echo $(date)"	End of calculating MD5 checksum of $SecondaryBackupPath/$FileNamePrefix"_"$CurrentDate.dmp.gz."$(date) >> $LogPath/$LogFileName;
		
		MD5SumBackupFile=`echo $MD5SumBackupFile|cut -d' ' -f1`;
		
		if [[ $MD5SumOrgFile == $MD5SumBackupFile ]] ; then
			echo $(date)"	File correctly copied." >> $LogPath/$LogFileName;
			break;
		fi
	done
fi

#Remove old backups
if [[ $EnableDeleteBackupFiles == "YES" ]] ; then
	/bin/rm -rf $DumpPath/$FileNamePrefix'_'$DeleteLocalFilesTime.dmp.gz;

	if [[ $EnablePrimaryBackupServer == "YES" ]] ; then
		/bin/rm -rf $PrimaryBackupPath/$FileNamePrefix'_'$DeletePrimaryBackupFilesTime.dmp.gz;
	fi

	if [[ $EnableSecondaryBackupServer == "YES" ]] ; then
		/bin/rm -rf $SecondaryBackupPath/$FileNamePrefix'_'$DeleteSecondaryBackupFilesTime.dmp.gz;
	fi
fi
