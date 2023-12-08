# My WSL Images

### Description

Build a CentOS to use on WSL (Windows 10 FCU or later).
Based on [wsldl](https://github.com/yuk7/wsldl).

![screenshot](https://raw.githubusercontent.com/wiki/yuk7/wsldl/img/Cent_Arch_Alpine.png)

### Configuration

No configuration needed.

### Usage

Install this script on a CentOS 8 machine and execute it.

#### How-to-Use (for Installed Instance)

Please visit the original yuk7 documentation on GitHub: https://github.com/yuk7/wsldl
To have multiple usage of the same CentOS version, simply rename the CentOS.exe to whatever you want.

#### exe Usage

```dos
Usage :
    <no args>
      - Open a new shell with your default settings.

    run <command line>
      - Run the given command line in that instance. Inherit current directory.

    runp <command line (includes windows path)>
      - Run the given command line in that instance after converting its path.

    config [setting [value]]
      - `--default-user <user>`: Set the default user of this instance to <user>.
      - `--default-uid <uid>`: Set the default user uid of this instance to <uid>.
      - `--append-path <true|false>`: Switch of Append Windows PATH to $PATH
      - `--mount-drive <true|false>`: Switch of Mount drives
      - `--wsl-version <1|2>`: Set the WSL version of this instance to <1 or 2>
      - `--default-term <default|wt|flute>`: Set default type of terminal window.

    get [setting]
      - `--default-uid`: Get the default user uid in this instance.
      - `--append-path`: Get true/false status of Append Windows PATH to $PATH.
      - `--mount-drive`: Get true/false status of Mount drives.
      - `--wsl-version`: Get the version os the WSL (1/2) of this instance.
      - `--default-term`: Get Default Terminal type of this instance launcher.
      - `--lxguid`: Get WSL GUID key for this instance.

    backup [contents]
      - `--tar`: Output backup.tar to the current directory.
      - `--tgz`: Output backup.tar.gz to the current directory.
      - `--vhdx`: Output backup.ext4.vhdx to the current directory. (WSL2 only)
      - `--vhdxgz`: Output backup.ext4.vhdx.gz to the current directory. (WSL2 only)
      - `--reg`: Output settings registry file to the current directory.

    clean
      - Uninstall that instance.

    help
      - Print this usage message.
```

#### How to differenciate instances

By default, the prompt shell looks like this for ALL of your WSL:

```
[root@DESKTOP-A4HBTNU ~]#
```

You can change the PS1 variable to identificate the WSL:

```
[root@DESKTOP-A4HBTNU ~]# PS1='[my new name \W]\$ '
[my new name ~]# 
```

To apply changes for the next console,

```
[my new name ~]# vim ~/.bashrc
```

 ```bash
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

PS1='[My_Pretty_Name \W]$ '
```

Close and restart your CentWSL instance:

```
[My_Pretty_Name locobastos]$
```
