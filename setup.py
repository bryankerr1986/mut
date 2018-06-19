################################################################################
##  TITLE: Setup Python Environment
##
##  FILENAME: setup.py
##
##  AUTHOR: Bryan Kerr
##
##  REVISION: 1.2
##  DATE: 06/18/2018
##
##  DESCRIPTION:
##  
##  Makes sure all required packages and drivers are installed for the Max1000
##  mut project.
##  
################################################################################
##  REVISION HISTORY (MANUAL):
##  06/01/2018 BEK - Initial coding
##  06/18/2018 BEK - Changed "conda install pywinauto" to "pip install pywinauto"
##
################################################################################
## Library declarations
################################################################################
import subprocess

subprocess.call("conda install numpy",      shell=True)
subprocess.call("conda install matplotlib", shell=True)
subprocess.call("pip install pywinauto",    shell=True)
subprocess.call("conda install pyserial",   shell=True)

from pywinauto.application import Application

fsv = Application().start(r"imp/driver/Arrow-USB-Blaster-Setup-2.0.exe")