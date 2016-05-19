#!/bin/bash

################################
#全量备份 by 2014-11-13
################################

SVN_BACKUP_DIR="/data_bak/svn_bak_data/svn_bak_full"
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
	repo_num=`/usr/local/subversion/bin/svnlook youngest $SVN_DIR/$i` 
	echo "################[ `date +"%F %T"` repo is ${i} num is ${repo_num} ]############" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log

	if [ -d $SVN_BACKUP_DIR/${i} ];then
	    /usr/local/subversion/bin/svnadmin dump $SVN_DIR/${i} -r ${repo_num} |gzip -9 > $SVN_BACKUP_DIR/${i}/${i}_${repo_num}_full_$TIME.dump.gz
	else
            mkdir $SVN_BACKUP_DIR/${i}
	    /usr/local/subversion/bin/svnadmin dump $SVN_DIR/${i} -r ${repo_num} |gzip -9 > $SVN_BACKUP_DIR/${i}/${i}_${repo_num}_full_$TIME.dump.gz
	fi

	if [ $? -eq 0 ];then
	    echo "$i $repo_num" > $SVN_BACKUP_CONF/$i.conf
	    echo -e "########### \033[32m [ `date +"%F %T"` $i backup repo num $repo_num successfull] \033[0m ################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	    echo "###################################################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	else
	    echo -e "########### \033[31m [ `date +"%F %T"` $i backup repo num $repo_num fail] \033[0m ################################" >> $SVN_BACKUP_LOG/svn_backup-$DATE.log
	    echo -e "[ `date +"%F %T"` $i backup repo num $repo_num fail]" >> $SVN_BACKUP_LOG/mes
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
