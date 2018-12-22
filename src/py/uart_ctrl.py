################################################################################
##  TITLE: UART Controller
##
##  FILENAME: uart_ctrl.py
##
##  AUTHOR: Bryan Kerr
##
##  REVISION: 2
##  DATE: 12/21/2018
##
##  DESCRIPTION:
##  
##  Uart Controller
##  
##  
################################################################################
##  REVISION HISTORY (MANUAL):
##  06/01/2018 BEK - Initial coding
##  12/21/2018 BEK - Changed UART baud rate from 38400 to 9600 because 38400
##                   was giving errors at the receiver.
##
################################################################################
## Library declarations
################################################################################
import serial
from struct import unpack, pack
from struct import *
import numpy as np
import time

class uart_ctrl:
   def __init__(self, port='COM4', baudrate=9600, bytesize=8, parity='N',
               stopbits=1, timeout=1, xonxoff=0, rtscts=0):
      self.ser = serial.Serial(
         port     = port     ,
         baudrate = baudrate ,
         bytesize = bytesize ,
         parity   = parity   ,
         stopbits = stopbits ,
         timeout  = timeout  ,
         xonxoff  = xonxoff  ,
         rtscts   = rtscts)
      if (self.ser.is_open):
         print("Serial port is open")
   
   def wr_byte(self, addr=b'\x81', byte=b'\xAA'):
      if (self.ser.is_open):
         self.ser.write(addr)
         self.ser.write(byte)
         print("Data", byte, "has been written to the address", addr)
   
   def rd_byte(self, addr=b'\x01'):
      if (self.ser.is_open):
         self.ser.write(addr)
         read_val = self.ser.read(size=1)
         print("Read", read_val, "from the address", addr)
         return read_val
   
   def wr_x_bytes(self, addr=b'\xFF', bytes=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                                             1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                                             1, 2, 3, 4, 5]):
      new_bytes = [pack("B",num) for num in bytes]
      if (self.ser.is_open):
         self.ser.write(addr)
         self.ser.write(pack("B", len(new_bytes)))
         tf_inner = time.time()
         for i in range(0,len(new_bytes)):
            self.ser.write(new_bytes[i])
         tf_inner2 = time.time()
         print("Data", new_bytes, "has been written to the address", addr)
   
   def rd_x_bytes(self, addr=b'\x7F', read_cnt=255):
      if (self.ser.is_open):
         self.ser.write(addr)
         self.ser.write(pack("B", read_cnt))
         read_val = self.ser.read(size=read_cnt)
         read_val = list(np.frombuffer(read_val, dtype=np.int8))
         print("Read", read_val, "from the address", addr)
         return read_val