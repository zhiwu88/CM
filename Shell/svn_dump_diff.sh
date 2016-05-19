#!/bin/bash
################################
#增量备份 by 2014-11-13
################################

SVN_BACKUP_DIR="/data_bak/svn_bak_data/svn_bak_diff"
SVN_DIR="/data/app/svnroot/repository"
SVN_BACKUP_CONF="/data_bak/svn_bak_conf"
SVN_BACKUP_LOG="/data_bak/svn_bak_log"
TIME=`date +"%F-%T"`
DATE=`date +"%F"`


echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
echo -e "######### \033[32m [`date +"%F %T"`] Svn Begin Backup  \033[0m ##################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log

for i in `/bin/ls $SVN_DIR`;
do
    if [ -d "$SVN_DIR/$i" ];then
	if [ -e $SVN_BACKUP_CONF/${i}.conf ];then
	    repo_num1=`awk '{print $2}' $SVN_BACKUP_CONF/${i}.conf`
	else
   	    repo_num1=0
	fi

	repo_num2=`/usr/local/subversion/bin/svnlook youngest $SVN_DIR/$i` 
	echo "################[ `date +"%F %T"` repo is ${i} num is ${repo_num1} to ${repo_num2} ]############" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	if [ -d $SVN_BACKUP_DIR/${i} ];then
	    if [ $repo_num2 != $repo_num1 ];then
	        /usr/local/subversion/bin/svnadmin dump $SVN_DIR/$i -r ${repo_num1}:${repo_num2} |gzip -9 > $SVN_BACKUP_DIR/${i}/${i}_${repo_num1}-${repo_num2}_diff_$TIME.dump.gz
	    else
	        echo -e "########### \033[32m [ `date +"%F %T"` $i backup repo num ${repo_num1} to ${repo_num2} svn no change] \033[0m ##" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	        echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	    fi
	else
	    mkdir $SVN_BACKUP_DIR/${i}
	    if [ $repo_num2 != $repo_num1 ];then
	        /usr/local/subversion/bin/svnadmin dump $SVN_DIR/$i -r ${repo_num1}:${repo_num2} |gzip -9 > $SVN_BACKUP_DIR/${i}/${i}_${repo_num1}-${repo_num2}_diff_$TIME.dump.gz
	    else
	        echo -e "########### \033[32m [ `date +"%F %T"` $i backup repo num ${repo_num1} to ${repo_num2} svn no change] \033[0m ##" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	        echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	    fi
	fi

	if [ $? -eq 0 ];then
	    echo "$i $repo_num2" > $SVN_BACKUP_CONF/$i.conf
	    echo -e "########### \033[32m [ `date +"%F %T"` $i backup repo num ${repo_num1} to ${repo_num2} successfull] \033[0m ##" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	    echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	else
	    echo -e "########### \033[31m [ `date +"%F %T"` $i backup repo num ${repo_num1} to ${repo_num2}  fail] \033[0m ##" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	    echo -e "[ `date +"%F %T"` $i backup repo num ${repo_num1} to ${repo_num2}  fail] " >> $SVN_BACKUP_LOG/mes
	    echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	fi
    fi
done
echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
echo -e "######### \033[32m [`date +"%F %T"`] Svn Backup Done  \033[0m ##################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log

if [ -s $SVN_BACKUP_LOG/mes ];then
    mes=`cat $SVN_BACKUP_LOG/mes`
    curl http://10.0.8.8:9000/svn/send_mail?User=chenjiliang\&Passwd=1\&Mes=$mes
fi 
rm -f $SVN_BACKUP_LOG/mes
