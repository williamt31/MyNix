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

