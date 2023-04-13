# U #
#!/bin/bash
# Created By: William Thompson
# Created On: 20230307
# Updated By: William Thompson
# Updated On: 20230411
# Version:    1.2


echo -e "\n# U # Begin execution of :${0##*/} script!\n"
echo -e "\n# U # If not executed by root/sudo, script will auto relaunch with priviledge\n"
if [[ $EUID -ne 0 ]]
then
    exec sudo /bin/bash "$0" "$@"
fi

    
# U # Global variables set here #
saveLocation="."


# U # Global functions set here #


# U # Begin processing #
adapters=$(ifconfig -s | awk -F" " '{print $1}' | grep -v lo | grep -v Iface)
for nic in $adapters;
do
    nic_HOSTNAME=$(hostname)
	
	# Returns just MAC addy
    nic_MAC=$(ifconfig $nic | grep "ether" | awk -F" " '{print $2}')
	
	# Returns whether NIC is connected
	nic_CARRIER=$(cat "/sys/class/net/$nic/carrier")
	if [[ $nic_CARRIER == 1 ]] ; then
		nic_STATUS="Up"
	else
		nic_STATUS="Disconnected"
	fi
	
	# Returns just link Speed
	if [[ "$nic_STATUS" == "Up" ]]; then
		nic_SPEED=$(ethtool $nic 2> /dev/null | grep "Speed" | awk -F" " '{print $2}')
	else
		nic_SPEED="0 bps"
	fi
	
	# Returns just NIC Desc
	nic_DESC=$(lshw -class network -short 2> /dev/null | grep "$nic " | awk -F" network        " '{print (NF>1)? $NF : ""}')
    
	# Returns just IPv4 IP
	nic_IP=$(ifconfig $nic | grep "inet " | awk -F" " '{print $2}')
	
	# Returns just DNS servers
	nic_DNS=$(grep "nameserver" /etc/resolv.conf | awk -F" " '{print $2}' | tr '\n' ' ')

	# Return string, local left for testing.
	echo "$nic_HOSTNAME,$nic,$nic_MAC,$nic_STATUS,$nic_SPEED,$nic_DESC,$nic_IP,$nic_DNS" >> $saveLocation/"NICs_$nic_HOSTNAME.csv"
done


echo -e "\n# U # Global cleanup here!\n"

    
echo -e "\n# U # End of Script!\n"
