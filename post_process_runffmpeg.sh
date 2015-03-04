#!/opt/bin/bash

processing_in_path="/data/dvr/processing_in/"
processing_current_path="/data/dvr/processing_current/"
processing_done_path="/data/dvr/processing_done/"
dest_folder="/data/TV/"
base_path="/data/dvr"


exec >> /data/bin/log_postproc-ffmpeg.log 2>&1
if [ "$(ls -A $processing_current_path)" ]; then
	echo "already processing a file"
	exit 0
fi

for f in $processing_in_path*
do
	echo "Processing $f"
	IFS="="
	while read -r var value
	do
		declare "$var"="${value//\"/}"
	done < "$f"
	#$full_path
	#$base_name
	#$base_name_root
	#$current_datecode
	#$channel
	#$title
	#$description
	#$xml_description
	echo $full_path
	base_name_mpeg="$base_name_root".mpeg
	base_name_mp4="$base_name_root".mp4
	base_name_nfo="$base_name_root".nfo
	dest_path=$dest_folder$title
	mv $f "$processing_current_path""$base_name_root"".dvr"


	### process
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
	/opt/bin/sudo /volume1/@appstore/VideoStation/bin/ffmpeg -y -prefer_smd \
	-i "$full_path" -threads 0 -c:v h264_smd -vprofile high \
	-s hd720 -bf 0 -b:v 2500k -c:a copy "$base_path/$base_name_mpeg" \
	&& /opt/bin/sudo /volume1/@appstore/VideoStation/bin/ffmpeg -y \
	-i "$base_path/$base_name_mpeg" -c:v copy -c:a copy -f mp4 "$dest_path/$base_name_mp4" \
	&& rm -rf "$full_path" "$base_path/$base_name_mpeg" \
	&& mv "$processing_current_path""$base_name_root"".dvr" "$processing_done_path""$base_name_root"".dvr"

cat > "$dest_path"/"$base_name_nfo" <<EOL
<episodedetails>
	<title>$xml_description</title>
	<showtitle>$title</showtitle>
	<plot>$description</plot>
	<studio>$channel</studio>
</episodedetails>
EOL


done






exit 0












###current_pid=`/opt/bin/sudo /bin/ps | /bin/grep ffmpeg | /bin/grep prefer_smd | /bin/grep sudo | /usr/bin/awk '{print $1}'`
if [ -n "$current_pid" ]; then 
	echo /data/bin/post_process_mkv.sh \"$full_path\" \"$base_name\" \"$channel\" \"$title\" \"$description\" >> /data/bin/post_process_waiting.log
	echo "CURRENT_PID: $current_pid" >> /data/bin/post_process_waiting.log
	echo "job currently running with pid $current_pid" >> /data/bin/post_process_waiting.log
	while [ -n "$current_pid" ]
	do
		current_pid=`cat /data/bin/pid_lock`
		###current_pid=`/opt/bin/sudo /bin/ps | /bin/grep ffmpeg | /bin/grep prefer_smd | /bin/grep sudo | /usr/bin/awk '{print $1}'`
		sleep `expr 20 + $RANDOM % 20`
		echo "`date` $base_name waiting on pid $current_pid" >> /data/bin/post_process_waiting.log
	done
	echo "`date` $base_name pid# $current_pid freed up...continuing." >> /data/bin/post_process_waiting.log
fi

echo "$base_name" > /data/bin/pid_lock

exec >> $log_file 2>&1
echo "ffmpeg is free to process $base_path"


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



##http://blown-to-bits.blogspot.com/2011/07/synology-dnla-transcoding-alternative.html
###

/opt/bin/sudo /volume1/@appstore/VideoStation/bin/ffmpeg -y -prefer_smd \
	-i "$full_path" -threads 0 -c:v h264_smd -vprofile high \
	-s hd720 -bf 0 -b:v 2500k -c:a copy "$base_path/$base_name_mpeg" \
	&& /opt/bin/sudo /volume1/@appstore/VideoStation/bin/ffmpeg -y \
	-i "$base_path/$base_name_mpeg" -c:v copy -c:a copy -f mp4 "$dest_path/$base_name_mp4" \
	&& rm -rf "$full_path" "$base_path/$base_name_mpeg"

cat > "$dest_path"/"$base_name_nfo" <<EOL
<episodedetails>
	<title>$base_name</title>
	<showtitle>$title</showtitle>
	<plot>$description</plot>
	<aired>$today_date</aired>
	<studio>$channel</studio>
</episodedetails>
EOL

rm -rf /data/bin/pid_lock
###  -vsync 2

###/volume1/@appstore/VideoStation/bin/ffmpeg

###/volume1/@appstore/FFmpegWithDTS/bin/ffmpeg

###/volume1/@appstore/tvheadend-testing/bin/ffmpeg

###/usr/syno/bin/ffmpeg
