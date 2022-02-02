import os
import sys
import time
from datetime import datetime, timedelta

tplPathsToCheck = ("C:\\Users\\s.mamdoohi\\Downloads\\ddddd\\",)
lstImmediateDeletePaths = []
DaysToDelete = 3
is_Immediate_Delete=True

def file_remover(FilesToDelete):
    for index in FilesToDelete:
        os.remove(index)

CurrentDate = datetime.today()
lstFilesToDelete = []
dctFiles = { }

for PathToDelete in tplPathsToCheck:
    lstFiles = os.listdir(PathToDelete)

    WhileCounter = 0
    while WhileCounter < len(lstFiles):
        FileName = PathToDelete + lstFiles[WhileCounter]
        FileModifTime = time.ctime(os.path.getmtime(PathToDelete + lstFiles[WhileCounter]))
        objDateTime = datetime.strptime(FileModifTime, '%a %b %d %H:%M:%S %Y')
        dctFiles[FileName] = objDateTime.date()
        WhileCounter += 1

    for DictCounter in dctFiles.keys():
        DictValue = dctFiles[DictCounter]
        Delta = CurrentDate.date() - DictValue

        if Delta.days > DaysToDelete:
            lstFilesToDelete.append(DictCounter)

    file_remover(lstFilesToDelete)

    lstFilesToDelete.clear()
    dctFiles.clear()

if is_Immediate_Delete == True:
    file_remover(lstFilesToDelete)