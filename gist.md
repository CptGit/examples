### [Linux] how to enable autohibernate after sleep for some time like on windows

This might have been outdated but I won't update/check it until I have a new laptop to configurate. Maybe in 10 years, who knows. Long Live the ThinkPad!

modified on Aug 12, 2018 (CDT), worked on Ubuntu 18.04, ThinkPad-T470

#### Section 1

Turn off your Secure Boot in BIOS

#### Section 2

Make sure a swap partition more than your RAM and activate the swap partition

(from [https://help.ubuntu.com/community/SwapFaq#How_do_I_add_or_modify_a_swap_partition.3F](https://help.ubuntu.com/community/SwapFaq#How_do_I_add_or_modify_a_swap_partition.3F))

Process to Increase Size of Swap Partition and use it for Hibernation

1. Creating the swap partition
2. Activating the swap partition
3. Making the new swap partition work for hibernate (optional)

Creating the swap partition

1. Boot to Ubuntu install CD (I'm on Natty) and choose the option to run Ubuntu now
2. Go to system -> GParted Partition Editor
3. Delete the swap partition and, if there is nothing else in it, the extended partition that holds it. (If by some miracle you're able to resize your swap partition from here, I imagine your life will be a lot easier than mine.)
4. Decrease the size of your primary partition by the amount you want your new swap to be (I made mine 2x RAM + 500MB just to be safe). The easiest way to do this is to fill in the amount of space you want swap to be in the "free space following" field
5. In the free space that has now been created, choose new, type linux-swap and you can name the partition "swap" if you like
6. Hit the *Apply* button (should be a check mark) to write the changes to disk
7. When done, reboot back into Ubuntu

Activating the swap partition
(If your swap is on your primary hard drive, you don't need to do anything here.) Now you need to find what partition your swap is on and what its UUID is. UUID?! you say? Well that's the Universally Unique IDentifier for the partition so you can reference it even if it's on a different mount point from boot-to-boot due to adding disks, etc.

1. Pull up a terminal and run gksu gparted & and enter your root password. The & lets this process run while still giving you access to the command line.

2. Right-click on your swap partition and choose *Information*. You should see the **Path** and **UUID** listed there. Keep this open for further reference.

3. Run `gksu gedit /etc/fstab &` and look for the line that has *swap* in it. It should be the third column, separated by spaces or tabs. You can either use the path or the UUID to tell Linux where to find your swap partition. I recommend UUID because it'll stay constant even if you move the partition around or the disk somehow becomes sdb instead of sda or something like that. Make the appropriate edits and save the file. Your line should look something like this if you used UUID (with your UUID instead, of course):

1. `UUID=41e86209-3802-424b-9a9d-d7683142dab7 none swap sw 0 0`

2. or this if you used path: `/dev/sda2 none swap sw 0 0`

4. Save the file.

5. Enable the new swap partition with this command.
```
sudo swapon --all OR
```
```
$ sudo swapon --all --verbose
swapon on /dev/sda2
swapon: /dev/sda2: found swap signature: version 1, page-size 4, same byte order
swapon: /dev/sda2: pagesize=4096, swapsize=2147483648, devsize=2147483648
```

6. Confirm that the swap partition exists.
```
$ cat /proc/swaps
Filename                                Type            Size    Used    Priority
/dev/sda2                               partition       2097148 0       -1
```

7. Reboot to make sure the new swap gets activated properly at startup

Making the swap partition work for hibernate (optional)
'INFO: This will not work for 12.04, resume from hibernate work differently in 12.04.'

1. Pull up a Terminal again and run `cat /proc/swaps` and hopefully you see the path to your swap partition listed there. If not chances are something went wrong in the steps above. Here's my output:

```
Filename                                Type            Size    Used    Priority
/dev/sda2                               partition       2676732 73380   -1
```

2. `gksu gedit /etc/default/grub &` to pull up the boot loader configuration

3. Look for the line `GRUB_CMDLINE_LINUX=""` and make sure it looks like this (using your UUID of course) `GRUB_CMDLINE_LINUX="resume=UUID=41e86209-3802-424b-9a9d-d7683142dab7"` and save the file

4. `sudo update-grub` and wait for it to finish

5. `gksu gedit /etc/initramfs-tools/conf.d/resume &` and make sure its contents are `resume=UUID=41e86209-3802-424b-9a9d-d7683142dab7` (with your UUID of course in place of mine). Save the file!

6. `sudo update-initramfs -u`

7. Reboot!
Now you should be able to hibernate and resume!

#### Section 3

Steps to enable hibernate in menus:

(from [https://askubuntu.com/questions/768136/how-can-i-hibernate-on-ubuntu-16-04/821122#821122](https://askubuntu.com/questions/768136/how-can-i-hibernate-on-ubuntu-16-04/821122#821122))


1. Create a file as root in `/etc/polkit-1/localauthority/50-local.d/enable-hibernate.pkla`
```
sudo -i nano /etc/polkit-1/localauthority/50-local.d/enable-hibernate.pkla
```

2. Put these contents on that file
```
[Re-enable hibernate by default in upower]
Identity=unix-user:*
Action=org.freedesktop.upower.hibernate
ResultActive=yes

[Re-enable hibernate by default in logind]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate;org.freedesktop.login1.handle-hibernate-key;org.freedesktop.login1;org.freedesktop.login1.hibernate-multiple-sessions;org.freedesktop.login1.hibernate-ignore-inhibit
ResultActive=yes
```

3. Save the file by pressing Ctrl-O. Exit with Ctrl-X

4. Restart the polkitd daemon
```
systemctl restart polkitd.service
```
It should enable hibernate.

#### Section 4

(from [https://askubuntu.com/questions/12383/how-to-go-automatically-from-suspend-into-hibernate](https://askubuntu.com/questions/12383/how-to-go-automatically-from-suspend-into-hibernate))

Steps to enable the switch from suspend/sleep into hibernate after a pre-determined time:

1. Make sure hibernate is working as expected when running
```
systemctl hibernate
```

2. Copy the original `suspend.target` file:
```
sudo cp /lib/systemd/system/suspend.target /etc/systemd/system/suspend.target
```
Then edit the file `/etc/systemd/system/suspend.target` and add the line:
```
Requires=delayed-hibernation.service
```
to the `[Unit]` section of that file.

3. Create the file `/etc/systemd/system/delayed-hibernation.service` with the following content:
```
[Unit]
Description=Delayed hibernation trigger
Before=suspend.target
Conflicts=hibernate.target hybrid-suspend.target
StopWhenUnneeded=true

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/delayed-hibernation.sh pre suspend
ExecStop=/usr/local/bin/delayed-hibernation.sh post suspend

[Install]
WantedBy=sleep.target
```

4. Create the configuration file `/etc/delayed-hibernation.conf` for the script with the following content:
```
# Configuration file for 'delayed-hibernation.sh' script

# Specify the time in seconds to spend in sleep mode before the computer hibernates
TIMEOUT=1200  #in seconds, gives 20 minutes
```

5. Create the script which will actually does the hard work.

Create file `/usr/local/bin/delayed-hibernation.sh` with the content:

```bash
#!/bin/bash
# Script name: delayed-hibernation.sh
# Purpose: Auto hibernates after a period of sleep
# Edit the `TIMEOUT` variable in the `$hibernation_conf` file to set the number of seconds to sleep.

hibernation_lock='/var/run/delayed-hibernation.lock'
hibernation_fail='/var/run/delayed-hibernation.fail'
hibernation_conf='/etc/delayed-hibernation.conf'

# Checking the configuration file
if [ ! -f $hibernation_conf ]; then
    echo "Missing configuration file ('$hibernation_conf'), aborting."
    exit 1
fi
hibernation_timeout=$(grep "^[^#]" $hibernation_conf | grep "TIMEOUT=" | awk -F'=' '{ print $2 }' | awk -F'#' '{print $1}' | tr -d '[[ \t]]')
if [ "$hibernation_timeout" = "" ]; then
    echo "Missing 'TIMEOUT' parameter from configuration file ('$hibernation_conf'), aborting."
    exit 1
elif [[ ! "$hibernation_timeout" =~ ^[0-9]+$ ]]; then
    echo "Bad 'TIMEOUT' parameter ('$hibernation_timeout') in configuration file ('$hibernation_conf'), expected number of seconds, aborting."
    exit 1
fi

# Processing given parameters
if [ "$2" = "suspend" ]; then
    curtime=$(date +%s)
    if [ "$1" = "pre" ]; then
        if [ -f $hibernation_fail ]; then
            echo "Failed hibernation detected, skipping setting RTC wakeup timer."
        else
            echo "Suspend detected. Recording time, set RTC timer"
            echo "$curtime" > $hibernation_lock
            rtcwake -m no -s $hibernation_timeout
        fi
    elif [ "$1" = "post" ]; then
        if [ -f $hibernation_fail ]; then
            rm $hibernation_fail
        fi
        if [ -f $hibernation_lock ]; then
            sustime=$(cat $hibernation_lock)
            rm $hibernation_lock
            if [ $(($curtime - $sustime)) -ge $hibernation_timeout ]; then
                echo "Automatic resume from suspend detected. Hibernating..."
                systemctl hibernate
                if [ $? -ne 0 ]; then
                    echo "Automatic hibernation failed. Trying to suspend instead."
                    touch $hibernation_fail
                    systemctl suspend
                    if [ $? -ne 0 ]; then
                        echo "Automatic hibernation and suspend failover failed. Nothing else to try."
                    fi
                fi
            else
                echo "Manual resume from suspend detected. Clearing RTC timer"
                rtcwake -m disable
            fi
        else
            echo "File '$hibernation_lock' was not found, nothing to do"
        fi
    else
        echo "Unrecognised first parameter: '$1', expected 'pre' or 'post'"
    fi
else
    echo "This script is intended to be run by systemctl delayed-hibernation.service (expected second parameter: 'suspend')"
fi
```

6. Make the script executable:
```
sudo chmod 755 /usr/local/bin/delayed-hibernation.sh
```
It took me quite a lot until writing this script based on other replies in this thread, things I found on the internet like [https://bbs.archlinux.org/viewtopic.php?pid=1554259](https://bbs.archlinux.org/viewtopic.php?pid=1554259)

My version of the script tries to deal with many problems like go into suspend again if hibernate was not successful but do not wake again after the pre-determined time over and over.

7. Final step I assume would be to just execute
```
sudo systemctl daemon-reload
sudo systemctl enable delayed-hibernation.service 
```
to make sure new service/configurations are being used.

To check the service log, you can use:
```
sudo systemctl status delayed-hibernation.service
```
or for a complete log of the service use:
```
sudo journalctl -u delayed-hibernation.service
```
A normal log I get from the running service is:
```
mile@mile-ThinkPad:~$ sudo systemctl status delayed-hibernation.service 
● delayed-hibernation.service - Delayed hibernation trigger
ed: loaded (/etc/systemd/system/delayed-hibernation.service; enabled; vendor preset: enabled)
ve: inactive (dead)

Jun 09 20:35:42 mile-ThinkPad systemd[1]: Starting Delayed hibernation trigger...
Jun 09 20:35:42 mile-ThinkPad delayed-hibernation.sh[2933]: Suspend detected. Recording time, set RTC timer
Jun 09 20:35:42 mile-ThinkPad delayed-hibernation.sh[2933]: rtcwake: assuming RTC uses UTC ...
Jun 09 20:35:42 mile-ThinkPad delayed-hibernation.sh[2933]: rtcwake: wakeup using /dev/rtc0 at Thu Jun  9 18:55:43 2016
Jun 09 20:55:44 mile-ThinkPad systemd[1]: Started Delayed hibernation trigger.
Jun 09 20:55:44 mile-ThinkPad systemd[1]: delayed-hibernation.service: Unit not needed anymore. Stopping.
Jun 09 20:55:44 mile-ThinkPad systemd[1]: Stopping Delayed hibernation trigger...
Jun 09 20:55:44 mile-ThinkPad delayed-hibernation.sh[3093]: Automatic resume from suspend detected. Hibernating...
Jun 09 20:55:44 mile-ThinkPad systemd[1]: Stopped Delayed hibernation trigger.
mile@mile-ThinkPad:~$ 
```
So This would be it, I hope it really helps someone since I spent days trying to figure out the right combination of configurations and script versions to make this handy feature work.

#### Section 5

Keep grub default entry count down time when waking up from hibernation the same with fresh start

1. modify `/etc/default/grub` and add this line:
```
GRUB_RECORDFAIL_TIMEOUT=$GRUB_TIMEOUT
```

2. Do NOT forget update grub
```
sudo update-grub
```

### [Emacs] Configurate CC mode advanced indentation

https://stackoverflow.com/questions/1365612/how-to-i-configure-emacs-in-java-mode-so-that-it-doesnt-automatically-align-met/1365821#1365821

This comes from the Info manual for Emacs CC Mode, using GNU Emacs 23.1 on Windows:

Start building your Java class that's not indenting properly. In your case, exactly what you've typed above.

Move your cursor to the start of the line that's not indenting properly. In your case, "String two) {".

Hit C-c C-s (c-show-syntactic-information) to ask Emacs what syntax element it thinks you're looking at. In your case, it'll say something like ((arglist-cont-nonempty n m)).

Use C-c C-o (c-set-offset) to tell it you want to change the indentation level for this syntactic element.
It defaults to what it thinks that syntactic element is, e.g., arglist-cont-nonempty. Just hit RET if that default is correct.

Now it wants to know what expression to use to calculate the offset. In your case, the default is an elisp expression. Delete that, and just use a single plus sign + instead.

Test it out to make sure it's working correctly: Hit TAB a bunch on different lines, or M-x indent-region or similar.

To make it permanent, add this to your .emacs file:
```lisp
(setq c-offsets-alist '((arglist-cont-nonempty . +)))
```

### [Bash] Deal with symbolic/relative/both link when getting the absolute path of the script

```bash
_DIR="$( cd -P "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
```

### [CJK] [Linux] Set CJK fonts priority on Ubuntu 18.04
Edit "/etc/fonts/conf.avail/64-language-selector-prefer.conf" to move
up/down preferences.

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
        <alias>
                <family>sans-serif</family>
                <prefer>
                        <family>Noto Sans CJK SC</family>
                        <family>Noto Sans CJK TC</family>
                        <family>Noto Sans CJK HK</family>
                        <family>Noto Sans CJK JP</family>
                        <family>Noto Sans CJK KR</family>
                </prefer>
        </alias>
        <alias>
                <family>serif</family>
                <prefer>
                        <family>Noto Serif CJK SC</family>
                        <family>Noto Serif CJK TC</family>
                        <family>Noto Serif CJK JP</family>
                        <family>Noto Serif CJK KR</family>
                </prefer>
        </alias>
        <alias>
                <family>monospace</family>
                <prefer>
                        <family>Noto Sans Mono CJK SC</family>
                        <family>Noto Sans Mono CJK TC</family>
                        <family>Noto Sans Mono CJK HK</family>
                        <family>Noto Sans Mono CJK JP</family>
                        <family>Noto Sans Mono CJK KR</family>
                </prefer>
        </alias>
</fontconfig>
```

### [Bash] Read line by line from a file OR read a csv file
```bash
while IFS='' read -r line || [[ -n "${line}" ]]; do
    IFS=',' read -ra arr <<< "${line}"
    local var1="${arr[0]}"
    ...
done < input.txt
```


### [Bash] CAUTION! `<<<` gives you an extra newline
`<<< "${x}"` actually gives you `"${x}\n"`. Sometimes you want to use `< <(printf "${x}")` instead.

### [Bash] Use `"${arr[*]}"` to print an array

`$*`: `$1 $2 $3`
`$@`: `$1 $2 $3`
`"$*"`: `"$1 $2 $3" # Double quote entirely`
`"$@"`: `"$1" "$2" "$3" # Double quote separately`

### [Bash] Correct way to decide if a variable is set

`-z ${var}` cannot differentiate unset and empty. Use `-z ${var+x}`.

```bash
if [[ -z ${var+x} ]]; then
    echo "unset"
else
    echo "set"
fi
```

### [ASM] COMPUTE_FRAMES is incompetent

To put it simple, `COMPUTE_FRAMES` is not able to always correctly
compute stack map frames for you (if any the computation itself is
consuming) so you might want to replace the flag with `COMPUTE_MAXS`
and do the computation by yourself.

See a detailed elaboration at
<https://stackoverflow.com/questions/49222338/which-class-hierarchy-differences-can-exist-compared-to-the-jse-javadoc/49262105#49262105>

### [BASH] Correct way to iterate files over a directory

`for $( find ${A_DIR} -name "*.zip" ); do ...; done` is bad. I forgot
why but at least it cannot parse filename with whitespace.

The following is the correct way to iterate files over a given directory:
```bash
while IFS= read -r -d '' zip_file; do
    ...
done < <( find ${A_DIR} -name "*.zip" -print0 )
```

### [Hack] Download Java from Oracle without login

[https://gist.github.com/wavezhang/ba8425f24a968ec9b2a8619d7c2d86a6](https://gist.github.com/wavezhang/ba8425f24a968ec9b2a8619d7c2d86a6)

1. Replace 'otn' with 'otn-pub' in the download link.

2. Use `wget -c --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie"`.

For example:
```bash
wget -c --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/11.0.12%2B8/f411702ca7704a54a79ead0c2e0942a3/jdk-11.0.12_linux-x64_bin.tar.gz
```
