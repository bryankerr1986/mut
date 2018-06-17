################################################################################
##  TITLE: Plot Accelerometer Data (PAD)
##
##  FILENAME: pad.py
##
##  AUTHOR: Bryan Kerr
##
##  REVISION: 1.1
##  DATE: 06/01/2018
##
##  DESCRIPTION:
##  
##  1. Make sure COM port is correct (See comments below)
##  2. Writes random value to loopback register and plots it if
##     plt_loopback=True. If you don't want to plot loopback register then set
##     plt_loopback=False.
##  3. Also plots accelerometer data received from MUT.
##  
##  
################################################################################
##  REVISION HISTORY (MANUAL):
##  06/01/2018 BEK - Initial coding
##
################################################################################
## Library declarations
################################################################################
# Standard libraries
import numpy as np
import random
from matplotlib import pyplot as plt
from matplotlib import style
from matplotlib import animation

import sys
import argparse
# Custom Libraries
from uart_ctrl import *
import uart_ctrl

# Plots accelerometer data. Set plt_loopback=False if you don't want to plot the
# loopback register data. If you want the plot to go longer than 500 samples, then
# change plt_len equal to whatever length you want.
def plot_accelerometer(j=1, plt_loopback=False, plt_len=500):
   if j==0:
      return
   if j>plt_len:
      input("Plot has reached maximum limit, press enter to quit...")
      raise SystemExit
   
   x_ys.append(uart.rd_x_bytes(addr=b'\x02', read_cnt=1)) # Read from accelerometer x data reg in MUT
   y_ys.append(uart.rd_x_bytes(addr=b'\x03', read_cnt=1)) # Read from accelerometer y data reg in MUT
   z_ys.append(uart.rd_x_bytes(addr=b'\x04', read_cnt=1)) # Read from accelerometer z data reg in MUT
   xs = np.linspace(1,j,j)
   ax1.clear()
   ax1.set_ylim([-135,135])
   #ax1.set_xlim([0,150])
   ax1.set_title("Accelerometer Data")
   
   if plt_loopback:
      lb = random.randint(0,255)
      lb = pack("B",lb)
      uart.wr_byte(byte=lb)
      lbs.append(uart.rd_x_bytes(addr=b'\x01', read_cnt=1)) # Read from Loopback Register in MUT
      ax1.plot(xs,x_ys,'r',xs,y_ys,'g',xs,z_ys,'b', xs, lbs, 'y--')
      return
   ax1.plot(xs,x_ys,'r',xs,y_ys,'g',xs,z_ys,'b')

if __name__ == '__main__':
   
   # Parse input arguments. Here the user can specify:
   # 1. How many accelerometer data samples to plot (default=500).
   # 2. Whether or not to plot loopback register random data (default=False).
   parser = argparse.ArgumentParser(description='Data plot length')
   parser.add_argument("--run",
                       help="Number of accelerometer samples to plot. Default= 500 (int)",
                       required=False,type=int,default=500)
   parser.add_argument("--loop",
                       help="Send/Receive/Plot Loopback Register Data. Default= False (bool)",
                       required=False,type=bool,default=False)
   parser.add_argument("--com",help="UART COM port to open. Default= COM4 (str)",
                       type=str,required=False, default='COM4')
   args = parser.parse_args()
   
   # This opens the COM port to the UART connected to the FPGA.
   # You have to make sure the port is correct. Change COM4 to COMX (where X is
   # a number corresponding the port). To find out which port number it is you
   # can do the following steps:
   # 1. open 'Device Manager' in Windows.
   # 2. Goto Ports(COM & LPT)
   # 3. Look for connected port (probably says 'USB Serial Port (COMX)'
   uart = uart_ctrl.uart_ctrl(port=args.com) # Opens serial port
   
   xs,lbs,x_ys,y_ys,z_ys = ([] for i in range(5))
   style.use('fivethirtyeight')
   fig = plt.figure()
   ax1 = fig.add_subplot(1,1,1)
   ani = animation.FuncAnimation(fig, plot_accelerometer, 
                                 fargs=(args.loop,args.run), interval=1) # Plot every 1ms
   plt.show()