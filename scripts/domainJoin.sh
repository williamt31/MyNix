# U #
######################################################################################
#!/bin/bash
# Created By: William Thompson
# Created on: 20250825
# Version: 0.1
# Purpose:
######################################################################################
if [[ $EUID -ne 0 ]]
then
    echo -e "\n# U # Script was not executed by root/sudo, auto relaunching with priviledge\n"
    exec sudo /usr/bin/env bash "$0" "$@"
fi
echo -e "\n# U # Begin execution of :${0##*/} script!\n"
######################################################################################
# U # Global variables set here #
dateTime=$(date +%Y%m%d-%H%M)
exitMenu=false
getHostname=$(hostname -s)
userPass1="userPass1"
userPass2="userPass2"
pCount=0
######################################################################################
# U # Global functions set here #
write-log () {
    # -t <TAG> -p Priority 1-5 "${0##*/}" <-- logs script name with statement "$2"
    echo -e "\n${0##*/}\t$2\n" | tee >(systemd-cat -t SCRIPT -p "$1")
}
######################################################################################
# U # Begin processing #
while true
do
    read -ep "Do you want to clear and replace the default netplan config? (y/n): " RESPONSE
    case $RESPONSE in
        [Yy]* ) write-log "3" "Replacing default netplan config."
                cat > /etc/netplan/01-netcfg.yaml <<EOF
network:
    version: 2
    renderer: networkd
    ethernets:
        ens160:
            addresses:
                - X.X.X.XXX/24
            nameservers:
                addresses: [1.1.1.1, 8.8.8.8]
            routes:
                - to: default
                  via: X.X.X.X
EOF
            read -se -n 1 -p "Press any key to modify netplan file"
            nano /etc/netplan/01-netcfg.yaml
            netplan apply
            break;;

        [Nn]* ) break;;

        * ) echo "Invalid response. Please answer y or n.";;
    esac
done
apt update
apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit
write-log "3" "Joining to example.com domain"
read -ep "Enter Username with domain join priviledge: " userName
while [[ "$userPass1" != "$userPass2" ]]
do
    if [[ "$pCount" -ne 0 ]]
    then
        echo -e "\n Passwords do NOT match, try again! \n"
    fi
    read -sep "Enter Password: " userPass1
    read -sep "Enter Password again: " userPass2
    ((pCount+=1))
done
echo "$userPass2" | realm join -U "$userName" example.com

write-log "3" "Updating pam-auth config"
cat > /usr/share/pam-configs/mkhomedir <<EOF
Name: Create home directory on login
Default: yes
Priority: 900
Session-Type: Additional
Session-Interactive-Only: no
Session:
        required                        pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF
DEBIAN_FRONTEND=noninteractive pam-auth-update --force

write-log "3" "Updating sssd config"
cat > /etc/sssd/sssd.conf <<EOF
[sssd]
domains = example.com
config_file_version = 2
services = nss, pam, ssh, sudo
debug_level = 7

[domain/example.com]
debug_level = 7
ad_domain = example.com
krb5_realm = EXAMPLE.COM
krb5_store_password_if_offline = True

realmd_tags = manages-system joined-with-adcli
cache_credentials = True

id_provider = ad
access_provider = ad
auth_provider = ad
chpass_provider = ad

default_shell = /bin/bash
override_shell = /bin/bash
fallback_homedir = /home/%u
auto_private_groups = true

ldap_id_mapping = False
use_fully_qualified_names = False

dyndns_update = true
dyndns_refresh_interval = 43200
dyndns_update_ptr = true
dyndns_ttl = 3600

ad_gpo_map_service = +sudo, +sudo-i
ad_gpo_map_permit = -sudo, -sudo-i
ad_gpo_ignore_unreadable = true
EOF
systemctl restart sssd.service

write-log "3" "Adding admin groups to sudoers"
cat > /etc/sudoers.d/system-config-user <<EOF
adminUser ALL=(ALL) ALL
%adminGroup ALL=(ALL) ALL
EOF

######################################################################################
echo -e "\n# U # Global cleanup here!\n"
unset dateTime
unset exitMenu
unset getHostname
unset userName
unset userPass1
unset userPass2
unset pCount
######################################################################################
