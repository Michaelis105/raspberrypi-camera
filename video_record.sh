#!/bin/bash

save_path=${HOME}
log_path=${save_path}/video.log
log_format="%m/%d/%Y %X.%N %z"
config_path=${save_path}/my_libcamera-vid.config
record_interval=30000
record_width=1920
record_height=1080
record_name=video_part
record_format=%04d
record_extension=.h264
max_bytes_storage_threshold=5000000

log() {
	local timestamp="`date +\"${log_format}\"`"
	local log_message="${timestamp} $1"
	echo ${log_message}
	echo ${log_message} >> ${log_path}
}

kill_record() {
	log "Caught SIGINT - Stopping recording"
	local record_job_id=`ps -C libcamera-vid -o pid= `
	if [[ ! -z "${record_job_id}" ]]; then
		kill -9 ${record_job_id}
		log "Recording stopped"
	else
		log "Not recording"
	fi
	pkill -P $$ sleep
}

is_recording() {
	echo `ps -C libcamera-vid -o pid= `
}

delete_oldest_video_parts() {
	local oldest_video_part_path=`ls ${save_path}/${record_name}* -t | tail -1`
	if [[ ! -z "${oldest_video_part_path}" ]]; then
		local modified_date=`date --reference=${oldest_video_part_path}`
		log "Deleting ${oldest_video_part_path} modified at ${modified_date}"
		rm ${oldest_video_part_path}
	else
		log "Nothing to delete - check thresholds and used/max file system size"
	fi	
}

clean_oldest_video_parts_check() {
	root_stats=`df | grep "/dev/root"`
	used_bytes=`echo ${root_stats} | awk '{print $3}'`
	#available_bytes=`echo ${root_stats} | awk '{print $4}'`
	#percentage_used=`echo ${root_stats} | awk '{print $4}' | sed 's/.$//`
	if [ "$used_bytes" -gt "$max_bytes_storage_threshold" ]; then
		delete_oldest_video_parts
	fi
}

log "Script start"

if test -f ${config_path}; then
	log "Using config file at ${config_path}"
	#source ${config_path}
else
	log "Config file not found - using default settings in script source code"
fi

log "Recording start"

# --flush: Write frames to disk immediately without waiting for video to stop recording.
# --inline: Allow viewing video sequences from any frame, useful for video seeking.
libcamera-vid \
	-t 0 \
	--segment ${record_interval} \
	-o ${save_path}/${record_name}${record_format}${record_extension} \
	--width ${record_width} \
	--height ${record_height} \
	--flush	\
	--inline \
	--nopreview true \
	&

# Give libcamera time to start recording.
sleep 2

trap kill_record SIGINT

log "Record loop start"

while : ; do
	is_record=`is_recording`
	if [[ -z "${is_record}" ]]; then
		log "Record loop end"
		break
	fi
	clean_oldest_video_parts_check
	log "Alive"
	sleep 10
done

log "Script end"