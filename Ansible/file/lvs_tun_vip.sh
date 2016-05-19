#!/bin/bash
#srcipt to start LVS TUN realserver

VIP=10.51.13.202

#start LVS-TUN real server on this machine
/sbin/ifconfig tunl0 down
/sbin/ifconfig tunl0 up
echo 1 > /proc/sys/net/ipv4/conf/tunl0/arp_ignore
echo 2 > /proc/sys/net/ipv4/conf/tunl0/arp_announce
echo 0 > /proc/sys/net/ipv4/conf/tunl0/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/tunl0/forwarding

echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
/sbin/ifconfig tunl0 $VIP broadcast $VIP netmask 255.255.255.255  up
/sbin/route add -host $VIP dev tunl0
