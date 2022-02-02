#!/usr/bin/python

from jproperties import Properties
import datetime
import os
import gzip
import shutil

ConfigFileName = 'ConfigFile.properties'
configs = Properties()
with open(ConfigFileName, 'rb') as read_prop:
    configs.load(read_prop)

objDateTime = datetime.datetime.now()
CurrentDate = str(objDateTime.year) + str(objDateTime.strftime('%m')) + str(objDateTime.strftime('%d'))

######print(configs.get("Schema"))
######print(f'ORACLE_HOME: {configs.get("ORACLE_HOME").data}')
######print(f'Properties Count: {len(configs)}')

# #Create Logs Directory if is not exist
# if not os.path.exists(configs.get("LogPath").data):
#     os.makedirs(configs.get("LogPath").data)
#
# #Create primary backup server path if not exist
# if configs.get("EnablePrimaryBackupServer"):
#     if not os.path.exists(configs.get("PrimaryBackupPath").data):
#         os.makedirs(configs.get("PrimaryBackupPath").data)
#
# #Create secondary backup server path if not exist
# if configs.get("EnableSecondaryBackupServer"):
#     if not os.path.exists(configs.get("SecondaryBackupPath").data):
#         os.makedirs(configs.get("SecondaryBackupPath").data)

#Create a dump file
DumpFileName = configs.get("FileNamePrefix").data + "_" + CurrentDate
EXPDPCommand = configs.get("ORACLE_HOME").data + "/bin/expdp " + \
               configs.get("DBUser").data + "/" + \
               configs.get("DBPassword").data + \
               " directory=" + \
               configs.get("DBDirectory").data + \
               " dumpfile=" + DumpFileName + ".dmp" + \
               " logfile=" + DumpFileName + ".log" + " " + \
               configs.get("ExportOptions").data

os.system("export ORACLE_HOME=" + configs.get("ORACLE_HOME").data + "; " +
          "export ORACLE_SID=" + configs.get("ORACLE_SID").data + "; " +
          EXPDPCommand)

with open(configs.get("DumpPath").data + "/" + DumpFileName + ".log", 'r') as file:
    for last_line in file:
        pass

if (last_line.find("successfully completed at") == -1):
    os.remove(configs.get("DumpPath").data + "/" + DumpFileName + ".*")
    os.system("export ORACLE_HOME=" + configs.get("ORACLE_HOME").data + "; " +
              "export ORACLE_SID=" + configs.get("ORACLE_SID").data + "; " +
              EXPDPCommand)

#Remove current compressed DUMP file if exist.
if os.path.exists(configs.get("DumpPath").data + "/" + DumpFileName + ".dmp.gz"):
    os.remove(configs.get("DumpPath").data + "/" + DumpFileName + ".dmp.gz")

#Compressing DUMP file.
with open(configs.get("DumpPath").data + "/" + DumpFileName + ".dmp", 'rb') as InputDump:
    with gzip.open(configs.get("DumpPath").data + "/" + DumpFileName + ".dmp.gz", 'wb') as OutputComressed:
        shutil.copyfileobj(InputDump, OutputComressed)