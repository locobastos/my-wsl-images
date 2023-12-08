#!/usr/bin/env bash

# Check if the script was run as root
if [ "$EUID" -ne 0 ]
then
    echo "This script has to be run as root. Exiting..."
    exit 1
fi

# Check if the OS is RHEL-like
if [ ! -f /etc/redhat-release ]
then
    echo "This script has to be run on an RHEL-like machine. Exiting..."
    exit 2
fi

# Check if the OS is not a WSL
if grep -q microsoft /proc/version
then
    echo "This script has to be run on a real RHEL-like machine or virtual machine but not on a WSL. Exiting..."
    exit 3
fi

# Progress bar
# Source: https://github.com/fearside/ProgressBar
#
# Input is currentState($1), totalState($2) and descritpionState($3)
function ProgressBar {
    # Process data
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*3)/10
    let _left=30-$_done

    # Build progressbar string lengths
    _done=$(printf "%${_done}s")
    _left=$(printf "%${_left}s")

    # Build progressbar strings and print the ProgressBar line
    printf "\rProgress: [${_done// /#}${_left// /.}] ${_progress}%% ---> $3                                 \r"
}

# Directory where the script is launched
DIR=$(cd "$(dirname "$(readlink --canonicalize "$0")")/.." && pwd)

while true
do
    echo ""
    echo "Choose a distro to build (q to quit):"
    select distro_name in $(ls distro/rpm/)
    do
        if [ "${REPLY}" = "q" ]
        then
            exit 0
        fi

        if [ -e "distro/rpm/${distro_name}" ]
        then
            read -r -p "Do you want to do update your WSL system? (y/n): " updated
            if [[ "${updated}" =~ (y|Y|o|O) ]]
            then
                MAX_STEPS=11
            else
                MAX_STEPS=10
            fi
            CURRENT_STEP=1

            START_DATE=$(date +%s)
            echo "Starting date: $(date --date=@${START_DATE})"

            source distro/rpm/${distro_name}

            echo "Creating ${ZIP_NAME}"

            # Before Script
            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Updating your system..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            yum update -y -q > /dev/null

            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Installing dependencies..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            yum install -y -q wget xz zip unzip tar qemu-img > /dev/null

            wget -q "${RPM_GPG_KEY_URL}" -P /etc/pki/rpm-gpg/

            # Working directory
            TEMP_DIR=$(mktemp -d)
            cd "${TEMP_DIR}"

            # Download the cloud image and Yuk7's WSLDL
            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Downloading cloud image..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            wget -q "${ROOTFS_URL}"
            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Downloading Yuk7 tool..."
            # Environment variables for Yuk7's wsldl
            LNCR_BLD="23072600"
            LNCR_ZIP="icons.zip"
            LNCR_FN=${LNCR_NAME}.exe
            LNCR_URL="https://github.com/yuk7/wsldl/releases/download/${LNCR_BLD}/${LNCR_ZIP}"
            CURRENT_STEP=$((CURRENT_STEP + 1))
            wget -q "${LNCR_URL}"

            # Extract the WSL Launcher
            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Extracting WSL launcher..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            unzip -q "${LNCR_ZIP}" "${LNCR_FN}"
            rm -f "${LNCR_ZIP}"

            # Mount the qcow2 image
            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Mounting the qcow2 image..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            mkdir mntfs
            modprobe nbd
            qemu-nbd -c /dev/nbd0 ${ROOTFS_FN}
            ping -c 5 127.0.0.1 1>/dev/null
            mount -o rw $(fdisk /dev/nbd0 -l | grep Linux | cut -d' ' -f1) mntfs/

            # Create the rootfs file
            cd mntfs || exit 10
            if [ "${1}" == "update" ]
            then
                ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Updating WSL...\n"
                CURRENT_STEP=$((CURRENT_STEP + 1))
                ${PKG_MGNT} update -q --assumeyes --installroot=$(pwd) > /dev/null
                # Cleaning YUM caches
                ${PKG_MGNT} clean all -q --installroot=$(pwd)
                rm --recursive --force "$(pwd)/var/cache/${PKG_MGNT}"
            fi

            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Creating the rootfs file..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            tar -zcpf ../rootfs.tar.gz -- *
            cd ..
            chown "$(id -un)" rootfs.tar.gz

            # Unmount the qcow2 image
            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Unmounting the qcow2 image..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            umount mntfs
            qemu-nbd -d /dev/nbd0 1>/dev/null
            ping -c 5 127.0.0.1 1>/dev/null
            rmmod nbd
            rm -rf mntfs/
            rm -f ./${ROOTFS_FN}

            # Build the ZIP archive
            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Building the ZIP Archive..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            zip -q "${DIR}/${ZIP_NAME}" -- *

            # Delete the working directory
            ProgressBar ${CURRENT_STEP} ${MAX_STEPS} "Cleaning up temporary files..."
            CURRENT_STEP=$((CURRENT_STEP + 1))
            rm -rf ${TEMP_DIR}

            END_DATE=$(date +%s)
            echo ""
            echo "Ending date: $(date --date=@${END_DATE})"

            RUNTIME=$((END_DATE-START_DATE))
            hours=$((RUNTIME / 3600))
            minutes=$(( (RUNTIME % 3600) / 60 ))
            seconds=$(( (RUNTIME % 3600) % 60 ))
            echo "Runtime: $hours:$minutes:$seconds (hh:mm:ss)"

            cd ${DIR}
        fi
    done
done
