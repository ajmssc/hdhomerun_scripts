#!/opt/bin/bash

processing_in_path="/data/dvr/processing_in/"

full_path=$1
base_name=$2
base_name_root=`echo $base_name | sed 's/.mkv//'`
base_name_mpeg=`echo $base_name | sed 's/.mkv/.mpeg/'`
base_name_mp4=`echo $base_name | sed 's/.mkv/.mp4/'`
base_name_nfo=`echo $base_name | sed 's/.mkv/.nfo/'`
base_path="/data/dvr"
channel=$3
title=$4
description=$5
dest_path=`echo "/data/TV/$title"`
log_file="/data/bin/post_process_error.log"
today_date=`date +%Y-%m-%d`



current_minute_code=`date +%M`
current_minute_plus_five=`expr $current_minute_code + 5`
minute_offset=`expr $current_minute_code % 30`
minute_final=`expr $current_minute_code - $minute_offset`00
current_datecode=`date +%Y%m%d%H`$minute_final

##current_datecode="20150303220000"
xmlval=`/opt/bin/xmllint --xpath "(//programme[@stop[contains(.,'$current_datecode')] and title='$title'])[1]" /data/dvr/epg/tv/xmltv.xml | /usr/bin/tr '\n' ' '`
xml_description=`echo $xmlval | xmllint --xpath "/programme/sub-title" - |  sed '/^\/ >/d' | sed 's/<[^>]*.//g'` 2> /dev/null


echo "full_path=$full_path" > "$processing_in_path"/"$base_name_root".dvr
echo "base_name=$base_name" >> "$processing_in_path"/"$base_name_root".dvr
echo "base_name_root=$base_name_root" >> "$processing_in_path"/"$base_name_root".dvr
echo "current_datecode=$current_datecode" >> "$processing_in_path"/"$base_name_root".dvr
echo "channel=$channel" >> "$processing_in_path"/"$base_name_root".dvr
echo "title=$title" >> "$processing_in_path"/"$base_name_root".dvr
echo "description=$description" >> "$processing_in_path"/"$base_name_root".dvr
echo "xml_description=$xml_description" >> "$processing_in_path"/"$base_name_root".dvr
echo "xmltv_raw=$xmlval" >> "$processing_in_path"/"$base_name_root".dvr

exit 0


