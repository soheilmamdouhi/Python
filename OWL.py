#!/usr/bin/python

import os
import sys
import time

WLUsernameOfPrimary = 'weblogic'
WLPasswordOfPrimary = 'weblogic951'
URLOfPrimary = 't3://'
is
WLUsernameOfSecondary = 'weblogic'
WLPasswordOfSecondary = 'weblogic951'
URLOfSecondary = 't3://'

class clsColors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

        def disable(self):
            self.HEADER = ''
            self.OKBLUE = ''
            self.OKGREEN = ''
            self.WARNING = ''
            self.FAIL = ''
            self.ENDC = ''
            self.OKCYAN = ''
            self.BOLD = ''
            self.UNDERLINE = ''

def _StartAdminServer():



def __ConnectToServer():
    try:
        #CONNECTION To SERVER
        connect(WLUsernameOfFirst, WLPasswordOfFirst, URLOfFirst)
    except:
        print(clsColors.OKGREEN + '  CONNECTION FAILED....' + clsColors.ENDC)
        print dumpStack()
        exit()