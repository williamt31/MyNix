# U #
####################################################################################################
#!/usr/bin/env bash
# Created by: William
# Created on: 230802
# Updated by:
# Updated on:
# Version: 0.2
# Purpose: Dandified updateme.sh alternative update mechanism
####################################################################################################
if [[ $EUID -ne 0 ]]
then
    echo -e "\n# U # Script was not executed by root/sudo, auto relaunching with priviledge\n"
    exec sudo /usr/bin/env bash "$0" "$@"
fi
echo -e "\n# U # Begin execution of :${0##*/} script!\n"
####################################################################################################
# U # Global variables set here #
repo7="/mnt/share/repo7"
repo8="/mnt/share/repo8"
keyStore="/etc/pki/rpm-gpg"
reposD="/etc/yum.repos.d"
SYSTEM=$(hostnamectl | grep "Operating System" | awk -F ":" '{ print $2 }')
isRocky="Rocky"
isCentOS="CentOS"
####################################################################################################
# U # Global functions set here #
write-log () {
    # -t <TAG> -p Priority 1-5 "${0##*/}" <-- logs script name with statement "$2"
    systemd-cat -t ORG -p $1 echo -e "${0##*/}\t$2"
}
####################################################################################################
# U # Begin processing here #
if [[ "$SYSTEM" == *"$isRocky"* ]]
then
    write-log "4" "Found Rocky Linux installed!"
    repo="$repo8"
elif [[ "$SYSTEM" == *"$isCentOS"* ]]
then
    write-log "4" "Found CentOS Linux installed!"
    repo="$repo7"
else
    write-log "1" "UNKNOWN SYSTEM EXITING NOW!"
    exit
fi

write-log "4" "Updating GPG Keys"
for key in "$repo/keys/*"
do
    if ! [ -f "$keyStore/$key" ]
    then
        \cp -n $key "$keyStore/"
    fi
done

for file in "$keyStore/*"
do
    rpm --import $file
done

if [ -d "$reposD/newRepo" ]
then
    write-log "4" "Removing Offline repo file & exiting."
    echo -e "# U # Removing Offline repo file"
    \rm -f "$reposD/*.repo"
    \mv -f $reposD/newRepo/*.* "$reposD/"
    \rmdir $reposD/newRepo
else
    write-log "4" "Backing up current repo files."
    echo -e "# U # Placing Offline repo file"
    \mkdir "$reposD/newRepo"
    \mv -f $reposD/*.* "reposD/newRepo/"
    write-log "4" "Copying temporary repo file."
    \cp $repo/*.repo "$reposD/"
    if ! [ -f /bin/dnf ]
    then
        yum install -y dnf
    fi
fi
####################################################################################################
echo -e "\n# U # Global cleanup here!\n"

####################################################################################################
echo -e "\n# U # End of Script!\n"

####################################################################################################
