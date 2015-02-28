#!/opt/bin/bash

full_path=$1
base_name=$2
base_name_mpeg=`echo $base_name | sed 's/.mkv/.mpeg/'`
base_name_mp4=`echo $base_name | sed 's/.mkv/.mp4/'`
channel=$3
title=$4
description=$5
dest_path=`echo "/data/TV/$title"`
log_file="/data/bin/post_process_error.log"
exec > $log_file 2>&1


if [ ! -d "$dest_path" ]; then
mkdir "$dest_path"
cat > "$dest_path"/tvshow.nfo <<EOL
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<tvshow>
    <title>$title</title>
    <showtitle>$title</showtitle>
</tvshow>
EOL
fi

echo $full_path >> /data/bin/post_process.log
echo $base_name >> /data/bin/post_process.log
echo $base_name_mpeg  >> /data/bin/post_process.log
echo $channel >> /data/bin/post_process.log
echo $title >> /data/bin/post_process.log
echo $description >> /data/bin/post_process.log
echo $dest_path >> /data/bin/post_process.log

##http://blown-to-bits.blogspot.com/2011/07/synology-dnla-transcoding-alternative.html
###

/opt/bin/sudo /volume1/@appstore/VideoStation/bin/ffmpeg -y -prefer_smd \
	-i "$full_path" -threads 0 -c:v h264_smd -vprofile high \
	-s hd720 -bf 0 -b:v 2500k -c:a copy "$dest_path/$base_name_mpeg" \
	&& /opt/bin/sudo /volume1/@appstore/VideoStation/bin/ffmpeg -y \
	-i "$dest_path/$base_name_mpeg" -c:v copy -c:a copy -f mp4 "$dest_path/$base_name_mp4" \
	&& rm -rf "$full_path" "$dest_path/$base_name_mpeg"

###  -vsync 2
