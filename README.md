# reroot.sh

A simple bash automation script for re-rooting /e/OS, Lineage, or similar using Magisk.

## The Problem: 
When using a custom Android ROM, updating your ROM will lose root privileges.
You can patch your ROM with Magisk, but following the steps every time there's an update gets tedious and confusing.

## The Solution:
Using a "wizard" to streamline the update process makes it go faster and less error-prone - just run the script after your phone has updated to the new ROM, and you'll download, patch, and flash the update to regain root. 

### Caveat:
Since I use /e/OS, it is currently hardcoded for that. If you want to use LineageOS, you'll need to change the download URL or manually download your update .zips. 

It is also configured to look for OnePlus 9 firmware specifically, codename "lemonade". That will also need to be changed if you want to use this for a different device. 

## How it Works:

1. Downloads the .zip from the appropriate source. Can be skipped with a flag.
  (for my purposes, it downloads /e/OS for the OnePlus 9 aka Lemonade device.)
2. Checks whether you have a device visible to the Android Debug Bridge (adb).
   2b. If device is not found, the script has a fallback called "manual" mode which will guide the user through the process without automating via adb. 
4. Uploads the .zip from the current working directory to your device's Download folder (adb push).
5. Instructs the user to patch the .zip with the Magisk app and waits for confirmation before continuing.
6. Downloads the patched .zip that Magisk created. Waits for the user to enter fastboot mode.
7. Flashes the patched zip to the device (on the alternate slot so you can fallback if needed).

Then, reboot your device and you'll have root again. 

### Launch Options:
`-h | --help`           Show the help menu. Also the default option if no argument is given.   
`-r | --release`        Specify OS Release Number.    
`-s | --skip-download`  Skip downloading the .zip from e/OS/'s website - useful for testing or if you downloaded it already.    

### Obviously needed features I probably won't make unless someone asks:
- a flag for specifying the name of your device (not just lemonade)
- a flag for specifying whether to use /e/OS or LineageOS (or others? Branch off?)
- Some sort of config file where someone could specify arbitrary API layout for their ROM provider's website
- a safety feature where the script reverts to the unchanged boot slot for you if the update fails for some reason


Ok bye
