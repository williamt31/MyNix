# UNCLASSIFIED #
####################################################################################################
#!/usr/bin/env bash
# Created by: williamt31
# Created on: 20230426
# Version: 1
# Purpose: Bring a newly imaged system to configured, STIGed, and IDM joined.
####################################################################################################
distroName=`grep -m 1 "NAME" /etc/os-release | awk -F '"' '{print $2}'`
majorVer=`grep "CPE_NAME" /etc/os-release | awk -F ':' '{print $5}' | awk -F '"' '{print $1}'`
#if ! [ "$distroName" == "Rocky Linux" ] || [ "$majorVer" -eq 8 ]
if [ "$distroName" == "CentOS Linux" ]
then
    echo -e "\n\n# U # This script is intended for Rocky Linux 8 ONLY, exiting now!\n\n"
    exit
fi
if [[ $EUID -ne 0 ]]
    then
    echo -e "\n# U # Script was not executed by root/sudo, auto relaunching with priviledge\n"
    exec sudo /bin/bash "$0" "$@"
fi
echo -e "\n# U # Begin execution of :${0##*/} script!\n"
####################################################################################################
# U # Global variables set here #
SCRIPTS="/mnt/scripts"
CYBER="/mnt/cyber"
CENT7="/mnt/cent7"
SOFTWARE="/mnt/software"
HOST=$(hostname | awk -F "." '{print $1}')
DATE=$(date '+%Y%m%d')
LOGFILE="$HOST.$DATE"
####################################################################################################
# U # Global functions set here #


# U # Begin processing #
####################################################################################################
echo -e "\n# U # Checking for Updates\n"
dnf update -y
dnf install -y ipa-client 
echo "Checking for Updates return code:$?" | tee -a "$LOGFILE"

echo -e "\n# U # Applying additional STIG Settings\n"
$SCRIPTS/rockySetSTIGsettings.sh
echo "Applying additional STIG Settings return code:$?" | tee -a "$LOGFILE"

echo -e "\n# U # Kicking off Evaluate-STIG\n"
$CYBER/evaluate-rSTIG.sh

echo -e "\n# U # Setting up fstab\n"
$CENT7/setMounts.sh
echo "Setting up fstab return code:$?" | tee -a "$LOGFILE"

echo -e "\n# U # Joining IDM\n"
$SCRIPTS/joinRocky8.sh
echo "Joining IDM return code:$?" | tee -a "$LOGFILE"

echo -e "\n# U # Applying SSSD fix\n"
$SCRIPTS/sssdFix_8.sh
echo "Applying SSSD fix return code:$?" | tee -a "$LOGFILE"

#read -p "Will this be a Post Process system? [N]: " yesPP
#yesPP=${yesPP:-N}
#if ! [ $yesPP == "N" ]
DELLMATCH=$(hostname | awk -F "." '{print $1}' | cut -c 1-4 )
#if [[ "$DELLMATCH" == "dell" ]]
#then
    #echo -e "\n# U # Running Post Process script\n"
    #$SCRIPTS/ppRocky8.sh
#fi

#echo -e "\n# U # Installing ACI HBSS client\n"
#$SOFTWARE/HBSS/HBSS_Install.sh

#echo -e "\n# U # \n"
systemctl enable --now cockpit.socket
echo "Enabling cockpit return code:$?" | tee -a "$LOGFILE"

####################################################################################################
echo -e "\n\n# U # Global cleanup here!\n"

echo -e "\n# U # End of Script!\n"
####################################################################################################
# UNCLASSIFIED #
