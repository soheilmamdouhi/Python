#!/usr/bin/python

import os
import sys
import time
from datetime import datetime, timedelta
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

tplPathsToCheck = ("C:\\Users\\s.mamdoohi\\Downloads\\ddddd\\",)
lstImmediateDeletePaths = []
DaysToDelete = 3
is_Immediate_Delete = True

ECODE = '\033[0m \n'
G = '\033[1;40;32m'
R = '\033[1;40;31m'

print ( bcolors.WARNING + "HELLO")
