#!/usr/bin/env python

import os
import re
import string
import commands

def h3c ():
	print ("\033[32m You have upped %s network card,Please Wait!\033[0m" % (len(Get_Network)))
	for eth in Get_Network:
		(status,output) = commands.getstatusoutput("tcpdump -i %s ether proto 0x88cc -A -s0 -t -c 1 -v" % ( eth.strip('\n')))
		Get_Info = output.split('\n')
#		Get_Info = os.popen( "tcpdump -i %s -A -s0 -t -c 1 -v" % ( eth.strip('\n')) ).readlines()
		switchname = ""
		interface = ""
		vlanid = ""
		address = ""
		for inf in Get_Info:
			if "System Name TLV" in inf:
				info = inf.split(' ')
				switchname = info[-1]
			elif "Subtype Interface Name" in inf:
				info = inf.split(' ')
				interface = info[-1]
			elif "port vlan id" in inf:
				info = inf.split(' ')
				vlanid = info[-1]
			elif "Management Address length 5, AFI IPv4" in inf:
				info = inf.split(' ')
				address = info[-1]
        	if switchname is not "":
			print ("\033[31m %s\033[0m Switch Name: \t\t \033[31m %s \033[0m \n Interface: \t\t \033[31m %s \033[0m \n VlanId: \t\t \033[31m %s \033[0m \n Management \t\t \033[31m %s \033[0m \n" % (eth,switchname,interface,vlanid,address)) 
		else:
			print ("%s IS NOTHING" % (eth))		


Get_Network = os.popen( "ifconfig| egrep -i \"eth|em\"| awk '{print $1}'").readlines()
h3c ()
