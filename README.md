# raspberrypi-camera

Intended for video recording capture for vehicle recording and personal property security.

## How to Install
1. Copy `video_record.sh` to desired user home directory
2. `sudo chmod a+x /home/<user>/video_record.sh`
3. Configure runtime parameters in source code script or set configuration file at `config_path`
4. Install camera to Raspberry Pi. Tested with Arducam 5MP Camera Module OV5647

## How to Record on Demand
1. `/home/<user>/video_record.sh`

## How to Install Cron Jobs

1. `crontab -e`
2. Insert line `@reboot /home/<user>/video_record.sh` to start recording on boot.
3. Insert line `* * * * * /home/<user>/clean_oldest_video_parts.sh > /dev/null 2>&1` to clean up older video artifacts periodically.
4. See video recording cron running `ps -o pid,cmd -afx | egrep -A20 "( |/)cron( -f)?$"` or `tail -f /home/<user>/video.log`