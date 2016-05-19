#!/bin/sh

today=$(date  +'%Y%m%d')

tmp_path="/data/app/123.com/caches/tmp/"

filename="cm_channel_info_$today.dat.gz"
pay_info_file="cm_channel_pay_info_$today.dat.gz"

filename_IBD="cm_ibd_channel_info_$today.dat.gz"
pay_info_file_IBD="cm_ibd_channel_pay_info_$today.dat.gz"


s3_cmd="/usr/bin/s3cmd -c /root/.s3cfg put"
s3_path="s3://house/android/cm_unspam"

s3_cmd1="$s3_cmd $tmp_path$filename $s3_path/cm_channel_info/cm_channel_info_$today.dat.gz"
echo $s3_cmd1
$s3_cmd1

s3_cmd2="$s3_cmd $tmp_path$pay_info_file $s3_path/cm_channel_pay_info/cm_channel_pay_info_$today.dat.gz"
echo $s3_cmd2
$s3_cmd2

s3_cmd1_IBD="$s3_cmd $tmp_path$filename_IBD $s3_path/cm_ibd_channel_info/cm_ibd_channel_info_$today.dat.gz"
echo $s3_cmd1_IBD
$s3_cmd1_IBD

s3_cmd2_IBD="$s3_cmd $tmp_path$pay_info_file_IBD $s3_path/cm_ibd_channel_pay_info/cm_ibd_channel_pay_info_$today.dat.gz"
echo $s3_cmd2_IBD
$s3_cmd2_IBD
