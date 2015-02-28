#!/opt/bin/bash

full_path=$1
base_name=$2
channel=$3
title=$4
description=$5
dest_path=/data/TV


##http://blown-to-bits.blogspot.com/2011/07/synology-dnla-transcoding-alternative.html

###/usr/local/ffmpeg/bin/ffmpeg -i "$full_path" -r 60 -s hd720 -c:v libx264 -c:a copy "$dest_path/$base_name"
###/volume1/@appstore/tvheadend-testing/bin/ffmpeg -i "$full_path" -y -r 35 -c:v copy -copyts -c:a copy -map 0:0 -map 0:1 -sn -f mpegts "$dest_path/$base_name"

##/usr/local/ffmpeg/bin/ffmpeg -threads 0 -y -i "/data/dvr/The Oscars.2015-02-22.mkv" -c:v libx264 -vsync 2 -preset veryfast -vprofile high -c:a ac3 -t 10 "/data/TV/The Oscars.2015-02-22.mp4"

###/volume1/@appstore/tvheadend-testing/bin/ffmpeg -i "$full_path" -y -vcodec copy -vbsf h264_mp4toannexb -copyts -acodec ac3 -ab 128k -ac 2 -map 0:0 -map 0:1 -sn -f mpegts "$dest_path/$base_name"

###/volume1/@appstore/tvheadend-testing/bin/ffmpeg -y -threads 4 -i "$full_path" -r 60 -s hd720 -c:v libx264 -c:a copy "$dest_path/$base_name"

/usr/syno/bin/ffmpeg -y -i "$full_path" -prefer_smd -r 60 -s hd720 -c:v h264_smd -c:a copy "$dest_path/$base_name"

##todo: remove old


###/volume1/@appstore/VideoStation/bin/ffmpeg

###/volume1/@appstore/FFmpegWithDTS/bin/ffmpeg

###/volume1/@appstore/tvheadend-testing/bin/ffmpeg

###/usr/syno/bin/ffmpeg
