#!/bin/env bash
####################################################################################################
# Created by: Eddie Carswell
# Updated by: williamt31
# Updated on: 240927
# Notes     : Script to download and install DOD root certs
# Comments  : Lines I modified from source prepended with '#$'
# Source    : https://gist.github.com/AfroThundr3007730/ba99753dda66fc4abaf30fb5c0e5d012
# Import DoD root certificates into linux CA store
# Version 0.3.0 updated 20240304
# SPDX-License-Identifier: GPL-3.0-or-later
####################################################################################################
if [[ $EUID -ne 0 ]]
    then
    exec sudo /bin/bash "$0" "$@"
fi
echo -e "\n# U # Begin execution of :${0##*/} script!\n"
####################################################################################################
# U # Global variables set here #
#DATE=$(date '+%y%m%d')
####################################################################################################
# U # Global functions set here #
write-log () {
    # -t <TAG> -p Priority 1-5 "${0##*/}" <-- logs script name with statement "$2"
    echo -e "\n${0##*/}\t$2\n" | tee >(systemd-cat -t SCRIPT -p "$1")
}
# U # Begin processing #
####################################################################################################
add_dod_certs() {
    local cert certdir file form tmpdir update dodRootCertsDir dodRootCertsFile #$ bundle url
    # Location of bundle from DISA site
    #$ url='https://public.cyber.mil/pki-pke/pkipke-document-library/'
    #$ bundle=$(curl -s $url | awk -F '"' 'tolower($2) ~ /dod.zip/ {print $2}')
    #bundle=https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_DoD.zip
    dodRootCertsDir="https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip"
    dodRootCertsFile="unclass-certificates_pkcs7_DoD.zip"

    # Set cert directory and update command based on OS
    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ $ID      =~ (fedora|rhel|centos) ||
          $ID_LIKE =~ (fedora|rhel|centos) ]]; then
        certdir=/etc/pki/ca-trust/source/anchors
        update='update-ca-trust'
    elif [[ $ID      =~ (debian|ubuntu|mint) ||
            $ID_LIKE =~ (debian|ubuntu|mint) ]]; then
        certdir=/usr/local/share/ca-certificates
        update='update-ca-certificates'
    else
        certdir=$1
        update=$2
    fi

    if [[ -z $certdir || -z $update ]]; then
        printf 'Unable to autodetect OS using /etc/os-release.\n'
        printf 'Please provide CA certificate directory and update command.\n'
        printf 'Example: %s /cert/store/location update-cmd\n' "${0##*/}"
        exit 1
    fi

    # Extract the bundle
    tmpdir=$(mktemp -d)
    echo "$tmpdir"
    #$ wget -qP "$tmpdir" "$bundle"
    wget -qP "$tmpdir" "$dodRootCertsDir/$dodRootCertsFile"
    #$ unzip -qj "$tmpdir"/"${bundle##*/}" -d "$tmpdir"
    unzip -qj "$tmpdir/$dodRootCertsFile" -d "$tmpdir"

    # Check for existence of PEM or DER format p7b.
    for file in "$tmpdir"/*_dod_{pem,der}.p7b; do
        # Iterate over glob instead of testing directly (SC2144)
        if [[ -f $file ]]; then form=${file%.*}; form=${form##*_}; break; fi
    done

    # Convert the PKCS#7 bundle into individual PEM files
    openssl pkcs7 -print_certs -inform "$form" -in "$file" |
        awk -v d="$tmpdir" 'BEGIN {c=0} /subject=/ {c++} {print > d "/cert." c ".pem"}'

    # Rename the files based on the CA name
    for cert in "$tmpdir"/cert.*.pem; do
        mv "$cert" "$certdir"/"$(openssl x509 -noout -subject -in "$cert" |
            awk -F '(=|= )' '{gsub(/ /, "_", $NF); print $NF}')".crt
    done

    # Remove temp files and update certificate stores
    rm -fr "$tmpdir"
    $update
    trust list | grep DOD
}

# Only execute if not being sourced
write-log "5" "Installing DOD Root Certificates"
[[ ${BASH_SOURCE[0]} == "$0" ]] && add_dod_certs "$@"
