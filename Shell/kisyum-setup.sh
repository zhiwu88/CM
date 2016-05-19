#!/bin/bash
master="1.1.1.1"
yumrepo="/etc/yum.repos.d/kingsoft.repo"
cron="/etc/cron.d/kismirrorscron"
yumprofile="/etc/profile.d/yum.sh"
old_yum_repo="/etc/yum.repos.d/CentOS-Base.repo"
old_kis_repo="/etc/yum.repos.d/kisyum.repo"

echo "卸载旧YUM配置"
rpm -q kisyum-release && rpm -e --nodeps kisyum-release 
if [ -f "$old_yum_repo" ];then
	mv $old_yum_repo ${old_yum_repo}.bak
fi
if [ -f "$old_kis_repo" ];then
	rm -fv $old_kis_repo
fi

echo "开始同步脚本目录"
mkdir -p /opt/kingsoft/kis_mirrors
for loop in 1 2 3 4 5
do
rsync -avz --progress --delete --bwlimit=10 $master::kis_mirrors  /opt/kingsoft/kis_mirrors
exitcode="$?"
if [ "$exitcode" = "0" ];then
break
fi
done

echo "放置repo文件"
if [ -f "$yumrepo" ];then
rm -fv $yumrepo
fi
#release=`grep CentOS /etc/issue | awk '{ print $3 }'| cut -b1`
release=`cat /etc/redhat-release  |awk -F'.' '{print $1}'|awk '{print $NF}'`
case "$release" in
	5)
	ln -s /opt/kingsoft/kis_mirrors/kingsoft_centos5.repo $yumrepo
	;;
	6)
	ln -s /opt/kingsoft/kis_mirrors/kingsoft_centos6.repo $yumrepo
	;;
	7)
	ln -s /opt/kingsoft/kis_mirrors/kingsoft_centos7.repo $yumrepo
	;;
	*)
	ln -s /opt/kingsoft/kis_mirrors/kingsoft_centos5.repo $yumrepo
	;;
esac
#if [ "$release" = "6" ]; then
#        ln -s /opt/kingsoft/kis_mirrors/kingsoft_centos6.repo $yumrepo
#else
#        ln -s /opt/kingsoft/kis_mirrors/kingsoft_centos7.repo $yumrepo
#fi

echo "放置例行任务"
if [ -f "$cron" ];then
rm -fv $cron
fi
ln -s /opt/kingsoft/kis_mirrors/kismirrorscron  $cron

echo "放置yum环境文件"
if [ -f "$yumprofile" ];then
rm -fv $yumprofile
fi
ln -s /opt/kingsoft/kis_mirrors/yum.sh $yumprofile
yum clean all
source /etc/profile
