# raspberrypi-camera

Intended for video recording capture for vehicle recording and personal property security.

## How to Install
1. Copy `video_record.sh` to desired user home directory.
2. `sudo chmod a+x /home/<user>/video_record.sh`.
3. Configure runtime parameters in source code script or set configuration file at `config_path`.
4. Install camera to Raspberry Pi. Tested with Arducam 5MP Camera Module OV5647.

## How to Record on Demand
1. `/home/<user>/video_record.sh`.

## How to Record on Startup

1. `crontab -e`.
2. Insert line `@reboot /home/<user>/video_record.sh`.
3. See cron running `ps -o pid,cmd -afx | egrep -A20 "( |/)cron( -f)?$"` or `tail -f /home/<user>/video.log`.