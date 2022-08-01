#!/bin/bash

save_path=/mnt/usb
log_path=${save_path}/video.log
log_format="%m/%d/%Y %X.%N %z"
record_name=video_part
record_extension=.h264
max_bytes_storage_threshold=5000000
max_percentage_storage_threshold=80

log() {
	local timestamp="`date +\"${log_format}\"`"
	local log_message="${timestamp} $1"
	echo ${log_message}
	echo ${log_message} >> ${log_path}
}

delete_oldest_video_parts() {
	local oldest_video_part_path=`ls ${save_path}/${record_name}*${record_extension} -t | tail -1`
	if [[ ! -z "${oldest_video_part_path}" ]]; then
		local modified_date=`date --reference=${oldest_video_part_path}`
		log "Deleting ${oldest_video_part_path} modified at ${modified_date}"
		rm ${oldest_video_part_path}
	else
		log "Nothing to delete - check thresholds and used/max file system size"
	fi	
}

clean_oldest_video_parts_check() {
	while [ true ]; do
		root_stats=`df | grep "/mnt/usb"`
		used_bytes=`echo ${root_stats} | awk '{print $3}'`
		#available_bytes=`echo ${root_stats} | awk '{print $4}'`
		percentage_used=`echo ${root_stats} | awk '{print $5}' | sed 's/.$//'`
		if [ "$used_bytes" -gt "$max_bytes_storage_threshold" ] | [ "$percentage_used" -gt "$max_percentage_storage_threshold" ]; then
			delete_oldest_video_parts
		else
			break
		fi
	done
}

log "Clean-up start"

clean_oldest_video_parts_check

log "Clean-up end"