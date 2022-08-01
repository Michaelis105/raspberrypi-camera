#!/bin/bash

# Recommended save to external USB and not SD card sharing boot. 
# Known issues with PREEMPT SMP kernel panics with user/kernel paging request addresses
save_path=/mnt/usb
log_path=${save_path}/video.log
log_format="%m/%d/%Y %X.%N %z"
config_path=${save_path}/my_libcamera-vid.config
record_interval=60000
record_width=1920
record_height=1080
record_name=video_part
record_format=%04d
record_extension=.h264

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

log "Script start"

if test -f ${config_path}; then
	log "Using config file at ${config_path}"
	#source ${config_path}
else
	log "Config file not found - using default settings in script source code"
fi

log "Recording start"

trap kill_record SIGINT

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

log "Recording end"

log "Script end"