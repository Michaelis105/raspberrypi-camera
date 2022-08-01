# raspberrypi-camera

Intended for video recording capture for vehicle recording and personal property security.


## Important notes

Highly discourage using this code to save videos to SD card also running operating system.

Observed kernel paging request, addressing between user and kernel ranges, SP/PC alignment exception, and PREEMPT SMP errors.

Highly encourage using this code to save videos to external high-write storage device using high-speed protocol such as USB 3.x.


## How to Install
1. Copy `video_record.sh` to desired user home directory.
2. Grant execute permissions to others `sudo chmod a+x /home/<user>/video_record.sh`.
3. Configure runtime parameters in source code script or set configuration file at `config_path`.
4. Install camera to Raspberry Pi using standard camera install procedure. Tested with Arducam 5MP Camera Module OV5647.


## How to Record on Demand
1. `/home/<user>/video_record.sh`

libcamera will write video frames to save path immediately.


## How to Install Cron Jobs

Update root's crontab for USB access. Probably not the most secure usage.

1. Open root's crontab `sudo crontab -e`.
2. Insert line `@reboot /home/<user>/video_record.sh` to start recording on boot.
3. Insert line `* * * * * /home/<user>/clean_oldest_video_parts.sh > /dev/null 2>&1` to clean up older video artifacts periodically.
4. Save and Exit.
5. Reboot Raspberry Pi `sudo shutdown now -r`.
6. See video recording cron running `ps -o pid,cmd -afx | egrep -A20 "( |/)cron( -f)?$"` or `tail -f /home/<user>/video.log`.


## How to Automount (USB) External Storage

Useful for saving videos and logs to external storage.

1. Insert storage device into Raspberry PI open USB port (if USB, preferably USB 3.0 probably blue-colored).
2. Retrieve storage device name (/dev/sdXN) and file system type (e.g. FAT32, HPFS, NTFS, exFAT) `sudo fdisk -l`.
3. Retrieve storage UUID `sudo ls -l /dev/disk/by-uuid/`.
4. Create mount point `sudo mkdir <path/to/usb/mount/point>`. Example `/mnt/usb` 
5. Open fstab `sudo nano /etc/fstab`
6. Insert line `UUID=<device-uuid> <path/to/usb/mount/point> <filesystem-type> defaults,auto,users,rw,nofail,umask=000 0 0`. Note: This line varies depending on filesystem type
	defaults = default options such as rw, suid, dev, exec, auto, nouser, and async.
	auto = mount on `mount -a` such as at boot time.
	users = allows any user to mount/unmount.
	rw = mount read-write.
	nofail = Do not report errors for device if it does not exist.
	umask = Allow read, write, execute for all users.
	0 0 = Do not dump or check filesystem for errors.
7. Save and Exit.
8. Reboot Raspberry Pi `sudo shutdown now -r`.
9. Verify storage is autmounted `lsblk`.


## How to Recover from Broken /etc/fstab

Raspberry PI may no longer boot in the event of an incorrect /etc/fstab entry.

1. Append `init=/bin/sh` to first line `cmdline.txt` in `/boot` partition of operating system SD card. May need separate device to rewrite this file. Do not add line.
2. Reboot Raspberry PI with this setting.
3. Remount partition as read/writable `mount -o remount,rw /dev/mmcblk0p1 /`. This is because `/etc/fstab` is in read-only filesystem mode.
4. Fix/comment/remove potentially buggy line `sudo nano /etc/fstab`.
5. Revert change in Step 1.
6. Reboot Raspberry PI with this setting.
7. Worst case if above steps don't fix boot, reflash entire SD card.


## (Optional) Adding User

1. Create user `sudo adduser <username>`.
2. Add to various groups used for Raspberry PI `sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi <username>`.