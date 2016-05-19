#!/bin/bash
CORE_SUM=$(($(grep '^processor' /proc/cpuinfo | wc -l)-1))
IRQ_SUM="`echo "2 4 8 10 20 40 80 100 200 400 800 1000 2000 4000 8000 10000 20000 40000 80000 100000 200000 400000 800000"| cut -d " " -f -${CORE_SUM}`"
IRQ_NUM="`echo ${IRQ_SUM}`"
for i in `grep -E '(eth[0-9]+|em[0-9]+)' /proc/interrupts | grep -E '[0-9]{3,}' | awk -F ":" '{print $1}' | sed 's/\ //g'`; do
        echo -e "${i}\t:`cat /proc/irq/${i}/smp_affinity`"

        y="`echo ${IRQ_NUM} | awk '{print $1}'`"
        echo ${y} > /proc/irq/${i}/smp_affinity

        if [ "${y}" == "`echo ${IRQ_SUM} | awk '{print $NF}'`" ]; then
                IRQ_NUM="`echo ${IRQ_SUM}`"
        else
                IRQ_NUM="`echo ${IRQ_NUM} | sed 's/^\([0-9]\+\)\ \(.*\)/\2/g'`"
        fi

        echo -e "----\t `cat /proc/irq/${i}/smp_affinity`"
done

for i in `grep -E '(eth[0-9]+|em[0-9]+)' /proc/interrupts | grep -vE '[0-9]{3,}' | awk -F ":" '{print $1}' | sed 's/\ //g'`; do
        echo -e "${i}\t:`cat /proc/irq/${i}/smp_affinity`"
        echo 1 > /proc/irq/${i}/smp_affinity
        echo -e "----\t `cat /proc/irq/${i}/smp_affinity`"
done

###### Disable RPS (Receive Packet Steering)
sysctl -w net.core.rps_sock_flow_entries=0
for i in $(ls /sys/class/net/e{m,th}*/queues/rx-*/rps_{cpus,flow_cnt})
do
    echo 0 > $i
    cat $i
done

exit 0
