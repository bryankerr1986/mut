import subprocess

subprocess.call("conda install numpy",      shell=True)
subprocess.call("conda install matplotlib", shell=True)
subprocess.call("conda install pywinauto",  shell=True)
subprocess.call("conda install pyserial",   shell=True)

from pywinauto.application import Application

fsv = Application().start(r"imp/driver/Arrow-USB-Blaster-Setup-2.0.exe")