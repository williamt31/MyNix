#!/bin/bash

# Set Variables
BASE_PATH="/data/projects/kickstart"
VOLUME_NAME="CentOS 7 x86_64"   ### This MUST match the Volume label in grub.cfg ###
VOLUME_PATH="CentOS-7-x86_64-DVD-2207-02"
SOURCE_FILES="$BASE_PATH/working_copies/$VOLUME_PATH"
CONFIG_FILES="$BASE_PATH/config_files/$VOLUME_PATH"
ISO_FILE="$VOLUME_PATH.iso"
STORE="$BASE_PATH/built_isos"
NAS="/mnt/share"

# Delete $ISO_FILE If it exists
if [ -f $STORE/$ISO_FILE ]
then
    echo -e "\nRemoving $ISO_FILE\n"
    rm -f $STORE/$ISO_FILE
fi

# Copy updated config files into working files
\cp $CONFIG_FILES/ks*.cfg  $SOURCE_FILES/
\cp $CONFIG_FILES/grub.cfg $SOURCE_FILES/EFI/BOOT/

# UEFI ISO Build
xorriso -as mkisofs \
-c isolinux/boot.cat \
-b isolinux/isolinux.bin \
-no-emul-boot \
-boot-load-size 4 \
-boot-info-table \
-eltorito-alt-boot \
-e images/efiboot.img \
-no-emul-boot \
-isohybrid-gpt-basdat \
-o $STORE/$ISO_FILE \
-V "$VOLUME_NAME" $SOURCE_FILES/ ### Quotes must stay here ###

if [ -f $STORE/$ISO_FILE ]
then
    echo -e "\nMoving $ISO_FILE to the $NAS\n"
    \mv $STORE/$ISO_FILE $NAS/
else
    echo -e "\nERROR, Unable to move: $ISO_FILE to $NAS\n"
fi

# Optional, scp .iso directly to ESXi datastore
#scp $STORE/$ISO_FILE e1:/vmfs/volumes/<datastore_name>/_iso-Tools/
