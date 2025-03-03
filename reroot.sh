#! /bin/bash

# Magisk usage instructions here:
# https://topjohnwu.github.io/Magisk/install.html

function showhelp () {
    echo "usage: reroot.sh -r <release-number>"
    echo "example: reroot.sh -r e-2.8-t-20250219470166"
}

if [ "$#" = 0 ]; then
    showhelp && exit
fi

for arg in "$@"
do
    case $1 in
        "-h" | "--help" )
            showhelp && exit;;
        "-r" | "--release" )
            OS_RELEASE=$2;;
        "-s" | "--skip-download" )
            skip_download=true;;
   esac
    shift
done

if [ "$OS_RELEASE" = "" ]; then
    exit
fi

# First, download needed firmware file from /e/os website.

DOWNLOAD_URL="https://images.ecloud.global/community/lemonade/"
OS_FILE="${OS_RELEASE}-community-lemonade.zip"
RECOVERY_FILE="recovery-IMG-${OS_FILE}"

if [ "$skip_download" = false ]; then
    echo "Downloading via wget: $DOWNLOAD_URL$OS_FILE"
    wget "$DOWNLOAD_URL$OS_FILE"
else
    echo "Skipping download of '$OS_FILE'..."
fi

# connect to the adb device

function adb_check () {
    devices=$(adb devices | grep "List" -A1 | grep -v "List")
    if [ "$devices" ]; then
        return true
    else
        return false
    fi
}

manual=true

echo "Checking for a connection to your device..."
for run in {1..3}; do
    if ! [ adb_check ]; then
    echo "adb did not find your device - plug it in and enable USB Debugging and try again."
    read input
    else
        manual=false
        echo "Found!"
        break
    fi
done

if [ "$manual" = true ]; then
    echo "drag and drop the file '$OS_FILE' onto your device. Press Enter to continue."
    read input
else
echo "Uploading $OS_FILE to your device..."
    # check if OS file is already present
    present=$(adb shell "ls /sdcard/Download/" | grep "$OS_FILE")
    if [ "$present" = "" ]; then
        adb push "./$OS_FILE" /sdcard/Download/
        echo "Done."
    else
        echo "File was already present. Skipped."
    fi
    echo "Checking for old magisk files..."
    old_files=$(adb shell 'ls /sdcard/Download/ | grep "magisk"')
    if [ ! "$old_files" = "" ]; then
        echo "Found old files:"
        echo "$old_files"
        echo "Removing..."
        for file in "$old_files"; do
            adb shell rm "/sdcard/Download/$file"
        done
    fi
    echo "Done."
fi

echo "Now, patch the uploaded .zip file using the Magisk app."
echo "Ensure that the app is set to save the file to your device's Download folder."
echo "Press Enter when you're done."
read input

if [ "$manual" = false ]; then
    filename=$(adb shell ls "/sdcard/Download/" | grep "magisk")
    if [ ! "$filename" = "" ]; then
        adb pull "/sdcard/Download/$filename"
    else
        echo "magisk file wasn't found. aborting."
        exit
    fi
else
echo "Also, be sure that any old magisk images are removed from the folder, to prevent confusion."
echo "Next, drag and drop the patched magisk file to this folder ($(pwd)). Press Enter to continue."
read input
fi

filename=$(ls | grep "magisk")

if [ "$filename" = "" ]; then
    echo "Couldn't find the file. Aborting."
    exit
fi

# then instruct the user to boot to fastboot
echo "Boot your device into fastboot mode."
echo "If you routinely root your phone, you probably already know how to do this."
echo "Press Enter when your device is attached and in fastboot mode."
read input

current_slot=$(fastboot getvar current-slot) # -> a or b
if [ current_slot = "a" ]; then
    current_slot="b"
else
    current_slot="a"
fi
fastboot set_active "$current_slot"

fastboot flash boot_"$current_slot" "$filename"
# instruct the user to reboot
echo "Done - reboot your device."
# and you're done.
