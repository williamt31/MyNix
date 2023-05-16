# UNCLASSIFIED #
####################################################################################################
#!/usr/bin/env bash
# Created by: williamt31
# Created on: 20230420
# Version: V1R9.1
# Purpose: To Set as many DOD STIG settings as possible without breaking usabilty on Rocky Linux 8
# Using: Red Hat Enterprise Linux 8 Security Technical Implementation Guide :: Version 1, Release: 9 Benchmark Date: 26 Jan 2023
####################################################################################################
distroName=`grep -m 1 "NAME" /etc/os-release | awk -F '"' '{print $2}'`
majorVer=`grep "CPE_NAME" /etc/os-release | awk -F ':' '{print $5}' | awk -F '"' '{print $1}'`
#if ! [ "$distroName" == "Rocky Linux" ] || [ "$majorVer" -eq 8 ]
if [ "$distroName" == "CentOS Linux" ]
then
    echo -e "\n\n# U # This STIG script is intended for Rocky Linux 8 ONLY, exiting now!\n\n"
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
HOST=$(hostname | awk -F "." '{print $1}')
DATE=$(date '+%Y%m%d')
LOGFILE="$HOST.$DATE"
####################################################################################################
# U # Global functions set here #
##### Common function nomanclature Work outside in, $1 File, $2 Line, $3+ String. #####
stigAddLine () {
    # Appends line $2 to file $1
    echo "$2" >> "$1";
}

stigRemLine () {
    # Deletes matched line $2 from file $1
    sed -i "/""$2""/d" "$1";
}

stigAddString () {
    # Append string $3 to the end of matched line $2 in file $1
    sed -i "/""$2""/s/$/ ""$3""/" "$1";
}

stigRemString () {
    # Remove string $3 from matched line $2 in file $1
    sed -i "/""$2""/s/""$3""//g" "$1";
}

stigAddComment () {
    # Inserts a # on matched line $2 in file $1
    sed -i "/^""$2""/ s/./#&/" "$1";
}

stigRemComment () {
    # Removes a # on matched line $2 in file $1
    sed -i "/""$2""/s/^# //g" "$1";
}

### Need additional testing!!!  ###  Currently doesn't work with value in $2
stigModString () {
    # Replaces string $3 with string $4 on matched line $2 in file $1
    sed -i ";""$2"";s;""$3"";""$4"";" "$1";
}
# U # Begin processing #
####################################################################################################
VULN=V-230226
# Rule Title: RHEL 8 must display the Standard Mandatory DoD Notice and Consent Banner before granting local or remote access to the system via a graphical user logon.
# Notes: Default install missing /etc/dconf/db/local.d/01-banner-message
v230226_1="/etc/dconf/db/local.d/01-banner-message"
f_v230226 () {
cat > "$v230226_1" <<EOF
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.\nBy using this IS (which includes any device attached to this IS), you consent to the following conditions:\n-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.\n-At any time, the USG may inspect and seize data stored on this IS.\n-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.\n-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.\n-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details.'
EOF
}

if [ -f "$v230226_1" ]
then
    grep -q "banner-message-enable=true" "$v230226_1"
    if ! [ $? -eq 0 ]
    then
        f_v230226
        echo -e "Fixing $VULN"
    fi
else
    f_v230226
    echo -e "Fixing $VULN"
fi
####################################################################################################
VULN=V-230233
# Rule Title: The RHEL 8 shadow password suite must be configured to use a sufficient number of hashing rounds.
# Notes: While per logins.defs man the default hashing rounds is 5000 when 'ENCRYPT_METHOD SHA512' is set,
# Notes: adding additional comments so Evaluate-STIG scan will pass check.
v230233_1="/etc/login.defs"
v230233_2="SHA_CRYPT_MIN_ROUNDS 5000"
grep -q "$v230233_2" "$v230233_1"
if ! [ $? -eq 0 ]
then
    stigAddLine "$v230233_1" "$v230233_2"
    echo -e "Fixing $VULN"
fi
####################################################################################################
VULN=V-230237
# Rule Title: The RHEL 8 pam_unix.so module must be configured in the password-auth file to use a FIPS 140-2 approved cryptographic hashing algorithm for system authentication.
# Notes: Adding 'sha512' and removing 'yescrypt'
# Notes: Per https://access.redhat.com/solutions/6989354 'yescrypt' is not supported in 8.7
v230237_1="/etc/pam.d/password-auth"
v230237_2="password    sufficient                                   pam_unix.so"
v230237_3="sha512"
v230237_4="yescrypt"

if grep "$v230237_2" "$v230237_1" | grep -qv "$v230237_3"
then
    stigAddString "$v230237_1" "$v230237_2" "$v230237_3"
    echo -e "Fixing $VULN 1/2"
fi
if grep "$v230237_2" "$v230237_1" | grep -q "$v230237_4"
then
    stigRemString "$v230237_1" "$v230237_2" "$v230237_4"
    echo -e "Fixing $VULN 2/2"
fi

####################################################################################################
VULN=V-230251
# Rule Title: The RHEL 8 SSH server must be configured to use only Message Authentication Codes (MACs) employing FIPS 140-2 validated cryptographic hash algorithms.
# Notes: Remove non FIPS 140-2 complient ssh algorithms
v230251_1="/etc/crypto-policies/back-ends/opensshserver.config"
v230251_2=""
v230251_3=`cat "$v230251_1" | awk -F " " '{print $2}' | awk -F "=" '{print $2}'`
v230251_4="hmac-sha2-512,hmac-sha2-256"
grep -q "$v230251_4" "$v230251_1"
if ! [ $? -eq 0 ]
then
    stigModString "$v230251_1" "$v230251_2" "$v230251_3" "$v230251_4"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-230252
# Rule Title: The RHEL 8 operating system must implement DoD-approved encryption to protect the confidentiality of SSH server connections.
# Notes:Remove non FIPS 140-2 complient ssh ciphers
v230252_1="/etc/crypto-policies/back-ends/opensshserver.config"
v230252_2=""
v230252_3=`cat "$v230252_1" | awk -F " " '{print $1}' | awk -F "=" '{print $3}'`
v230252_4="aes256-ctr,aes192-ctr,aes128-ctr"
grep -q "$v230252_4" "$v230252_1"
if ! [ $? -eq 0 ]
then
    stigModString "$v230252_1" "$v230252_2" "$v230252_3" "$v230252_4"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-230311
# Rule Title: RHEL 8 must disable the kernel.core_pattern.
# Notes: Disabling core dumps
v230311_1="/usr/lib/sysctl.d/50-coredump.conf"
v230311_2=""
v230311_3=`grep "kernel.core_pattern" "$v230311_1" | awk -F "=" '{print $2}'`
v230311_4="|/bin/false"
grep -q "$v230311_4" "$v230311_1"
if ! [ $? -eq 0 ]
then
    stigModString "$v230311_1" "$v230311_2" "$v230311_3" "$v230311_4"
    echo -e "Fixing $VULN 1/2"
fi
v230311_1="/lib/sysctl.d/50-coredump.conf"
v230311_3=`grep "kernel.core_pattern" "$v230311_1" | awk -F "=" '{print $2}'`
grep -q "$v230311_4" "$v230311_1"
if ! [ $? -eq 0 ]
then
    stigModString "$v230311_1" "$v230311_2" "$v230311_3" "$v230311_4"
    echo -e "Fixing $VULN 2/2"
fi

####################################################################################################
VULN=V-230339
# Rule Title: RHEL 8 must ensure account lockouts persist.
# Notes: Setting non-default faillock directory
v230339_1="/etc/security/faillock.conf"
v230339_2="dir ="
v230339_3=`grep "$v230339_2" "$v230339_1" | awk -F "=" '{print $2}' | awk -F " " '{print $1}'`
v230339_4="/var/log/faillock"
comTest=`grep "$v230339_2" "$v230339_1" | head -c1`
if [ "$comTest" == "#" ]
then
    stigRemComment "$v230339_1" "$v230339_2"
    echo -e "Fixing $VULN"
fi
grep -q "$v230339_4" "$v230339_1"
if ! [ $? -eq 0 ]
then
    vLinNum=`grep -n "$v230339_2" "$v230339_1" | awk -F ":" '{print $1}'`
    sed -i "${vLinNum}s/run/log/" "$v230339_1"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-230341
# Rule Title: RHEL 8 must prevent system messages from being presented when three unsuccessful logon attempts occur.
# Notes: Uncommenting the 'silent' option
v230341_1="/etc/security/faillock.conf"
v230341_2="silent"
comTest=`grep "$v230341_2" "$v230341_1" | head -c1`
if [ "$comTest" == "#" ]
then
    stigRemComment "$v230341_1" "$v230341_2"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-230343
# Rule Title: RHEL 8 must log user name information when unsuccessful logon attempts occur.
# Notes: Uncommenting the 'audit' option
v230343_1="/etc/security/faillock.conf"
v230343_2="audit"
comTest=`grep "$v230343_2" "$v230343_1" | head -c1`
if [ "$comTest" == "#" ]
then
    stigRemComment "$v230343_1" "$v230343_2"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-230348
# Rule Title: RHEL 8 must enable a user session lock until that user re-establishes access using established identification and authentication procedures for command line sessions.
# Notes: Adding bind lock keycombination
v230348_1="/etc/tmux.conf"
v230348_2="bind X lock-session"
if ! grep -q "$v230348_2" "$v230348_1"
then
    stigAddLine "$v230348_1" "$v230348_2" 
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-230438
# Rule Title: Successful/unsuccessful uses of the init_module and finit_module system calls in RHEL 8 must generate an audit record.
# Notes: Repacing 2 lines per STIG
v230438_1="/etc/audit/audit.rules"
v230438_2="-a always,exit -F arch=b32 -S finit_module -S init_module -F auid>=1000 -F auid!=unset -F key=modules"
v230438_3="-a always,exit -F arch=b64 -S finit_module -S init_module -F auid>=1000 -F auid!=unset -F key=modules"
v230438_4="-a always,exit -F arch=b32 -S init_module,finit_module -F auid>=1000 -F auid!=unset -k module_chng"
v230438_5="-a always,exit -F arch=b64 -S init_module,finit_module -F auid>=1000 -F auid!=unset -k module_chng"
if grep -q -- "$v230438_2" "$v230438_1"
then
    vLinNum=`grep -n -- "$v230438_2" "$v230438_1" | awk -F ":" '{print $1}'`
#    stigRemLine "$v230438_1" "$v230438_2"
#    stigAddLine "$v230438_1" "$v230438_4"
    sed -i "${vLinNum}s/$v230438_2/$v230438_4/" "$v230438_1"
    echo -e "Fixing $VULN 1/2"
fi
if grep -q -- "$v230438_3" "$v230438_1"
then
    vLinNum=`grep -n -- "$v230438_3" "$v230438_1" | awk -F ":" '{print $1}'`
#    stigRemLine "$v230438_1" "$v230438_3"
#    stigAddLine "$v230438_1" "$v230438_5"
    sed -i "${vLinNum}s/$v230438_3/$v230438_5/" "$v230438_1"
    echo -e "Fixing $VULN 2/2"
fi

####################################################################################################
VULN=V-230466
# Rule Title: Successful/unsuccessful modifications to the faillock log file in RHEL 8 must generate an audit record.
# Notes: Add audit logging to /etc/audit/audit.rules
v230466_1="/etc/audit/audit.rules"
v230466_2="-w /var/log/faillock -p wa -k logins"
if ! grep -q -- "$v230466_2" "$v230466_1"
then
    stigAddLine "$v230466_1" "$v230466_2"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-230484
# Rule Title: RHEL 8 must securely compare internal information system clocks at least every 24 hours with a server synchronized to an authoritative time source, such as the United States Naval Observatory (USNO) time servers, or a time server designated for the appropriate DoD network (NIPRNet/SIPRNet), and/or the Global Positioning System (GPS).
# Notes: Setting chrony configuration.
v230484_1="/etc/chrony.conf"
v230484_2="pool 2.rhel.pool.ntp.org iburst maxpoll 16"
v230484_3="server ntp2 iburst minpoll 4 maxpoll 5 prefer"
v230484_4="server ntp1 iburst minpoll 4 maxpoll 5"
if grep -q -- "$v230484_2" "$v230484_1"
then
    stigRemLine "$v230484_1" "$v230484_2"
    stigAddLine "$v230484_1" "$v230484_3"
    stigAddLine "$v230484_1" "$v230484_4"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-230546
# Rule Title: RHEL 8 must restrict usage of ptrace to descendant  processes.
# Notes: Correcting ptrace value in 2 subordinate locations.
v230546_1="/usr/lib/sysctl.d/10-default-yama-scope.conf"
v230546_2=""
v230546_3="kernel.yama.ptrace_scope = 0"
v230546_4="kernel.yama.ptrace_scope = 1"
grep -q -- "$v230546_4" "$v230546_1"
if ! [ $? -eq 0 ]
then
    stigModString "$v230546_1" "$v230546_2" "$v230546_3" "$v230546_4"
    echo -e "Fixing $VULN 1/2"
fi
v230546_1="/lib/sysctl.d/10-default-yama-scope.conf"
grep -q -- "$v230546_4" "$v230546_1"
if ! [ $? -eq 0 ]
then
    stigModString "$v230546_1" "$v230546_2" "$v230546_3" "$v230546_4"
    echo -e "Fixing $VULN 2/2"
fi

####################################################################################################
VULN=V-244519
# Rule Title: RHEL 8 must display a banner before granting local or remote access to the system via a graphical user logon.
# Notes: Setting graphical security banner.
v244519_1="/etc/dconf/db/local.d/01-banner-message"
if ! [ -f "$v244519_1" ]
then
    touch "$v244519_1"
    cat >> "$v244519_1" <<EOF
[org/gnome/login-screen]

banner-message-enable=true
EOF
    dconf update
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-244521
# Rule Title: RHEL 8 operating systems booted with United Extensible Firmware Interface (UEFI) must require a unique superusers name upon booting into single-user mode and maintenance.
# Notes: Grub root user must be unique
v244521_1a="/boot/efi/EFI/rocky/grub.cfg"
v244521_1b="/etc/grub.d/01_users"
v244521_2='set superusers="root"'
v244521_3="root"
v244521_4="groot"
if grep -qm 1 "$v244521_2" "$v244521_1a"
then
    sed -i "${vLinNum}s/$v244521_3/$v244521_4/" "$v244521_1b"
    sleep 3
    grub2-mkconfig -o "$v244521_1a"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-244524
# Rule Title: The RHEL 8 pam_unix.so module must be configured in the system-auth file to use a FIPS 140-2 approved cryptographic hashing algorithm for system authentication.
# Notes: Adding sha512 to pam_unix.so
v244524_1="/etc/pam.d/system-auth"
v244524_2="password    sufficient                                   pam_unix.so yescrypt shadow  use_authtok"
v244524_3="sha512"
if ! grep -q -- "$v244524_3" "$v244524_1"
then
    stigAddString "$v244524_1" "$v244524_2" "$v244524_3"
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-244536
# Rule Title: RHEL 8 must disable the user list at logon for graphical user interfaces.
# Notes: Disabling Gnome user list
v244536_1="/etc/dconf/db/local.d/02-login-screen"
if ! [ -f "$v244536_1" ]
then
    touch "$v244536_1"
    cat >> "$v244536_1" <<EOF
[org/gnome/login-screen]
disable-user-list=true
EOF
    dconf update
    echo -e "Fixing $VULN"
fi

####################################################################################################
VULN=V-250315
# Rule Title: RHEL 8 systems, versions 8.2 and above, must configure SELinux context type to allow the use of a non-default faillock tally directory.
# Notes: Creating non-default faillock log directory and setting default SELinux context
v250315_1="/var/log/faillock"
if ! [ -d "$v250315_1" ]
then
    mkdir "$v250315_1"
    semanage fcontext -a -t faillog_t "/var/log/faillock(/.*)?" &> /dev/null
    restorecon -R -v "$v250315_1" &> /dev/null
    echo -e "Fixing $VULN"
fi

####################################################################################################
echo -e "\n\n# U # Global cleanup here!\n"

echo -e "\n# U # End of Script!\n"
####################################################################################################

# UNCLASSIFIED #
