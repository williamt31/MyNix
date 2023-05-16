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
SCRIPTS="/mnt/admin/_admin/scripts"
CYBER="/mnt/admin/_admin/cyber"
CENT7="/mnt/admin/_SA-IA/cent7"
SOFTWARE="/mnt/admin/_admin/software"
####################################################################################################
# U # Global functions set here #


# U # Begin processing #
####################################################################################################
echo -e "\n# U # Fixing NetworkManager\n"
if ! grep "dns=none" "/etc/NetworkManager/NetworkManager.conf"
then
    sed -i "/^\[main/adns=none\nrc-manager=unmanaged" "/etc/NetworkManager/NetworkManager.conf"
fi

echo -e "\n# U # Updating resolv.conf\n"
chattr -i /etc/resolv.conf

cat > /etc/resolv.conf <<EOF
nameserver _IpAddress_
nameserver _IpAddress_
nameserver _IpAddress_
nameserver _IpAddress_

search idm.myshop.mydomain myshop.mydomain
EOF

chattr +i /etc/resolv.conf

realm discover idm.myshop.mydomain | grep login
if [ $? -eq 0 ]
then
    echo -e "\n# U # System is already joined, dis-joining idm.myshop.mydomain\n"
    ipa-client-install --uninstall -U
    for file in "/etc/sssd/sssd.conf" "/etc/krb5.conf" "/etc/krb5.keytab"
    do
        if [ -f "$file" ]
        then
            rm -f "$file"
        fi
    done
fi

echo -e "\n# U # Joining idm.myshop.mydomain\n"
ipa-client-install --mkhomedir -N --force-join -U -p admin -w ipaadmin --enable-dns-updates
#ipa-client-install --mkhomedir -N --force-join --domain=idm.myshop.mydomain --server=myshop-ipa02.idm.myshop.mydomain -U -p admin -w ipaadmin --enable-dns-updates

echo -e "\n# U # Applying SSSD fix and restarting the service\n"
if [ -f /etc/sssd/sssd.conf ]
then
    /mnt/admin/_admin/scripts/sssdFix_8.sh
    systemctl restart sssd.service
else
    echo -e "\nSSSD.CONF IS MISSING!, Diagnose faulty IPA client join!!\n"
exit
fi

echo -e "\n# U # You should see AD user information for acas.sa here:"
id acas.sa

echo -e "\n# U # Setting Time service and sources\n"
/mnt/admin/_SA-IA/cent7/setTime.sh





#echo -e "\n# U # \n"


#echo -e "\n# U # \n"


#echo -e "\n# U # \n"


####################################################################################################
#echo -e "\n\n# U # Global cleanup here!\n"

echo -e "\n# U # End of Script!\n"
####################################################################################################
# UNCLASSIFIED #
