#!/bin/bash
###########################################################################
# Created by: Williamt31
# Created on: 20230127
# Version: 2210.2
# Purpose: Wrapper script for the Evaluate-STIG script from_
# https://spork.navsea.navy.mil/nswc-crane-division/evaluate-stig
###########################################################################
# Auto elevation catch.
if [[ $EUID -ne 0 ]]
then
    exec sudo /bin/bash "$0" "$@"
fi
############################## Begin Variables ##############################
IMPHOST=$(hostname -s)
SCANDATE=$(date +%Y%m)
SCANPATH="<Location to upload results to network share>"
ANSWERFILES="<Path to Answer Files>"
EXECARGS="--ScanType Unclassified --ApplyTattoo --AnswerKey $ANSWERFILES"
EXECPATH="<Set network path to 'Evaluate-STIG' files here>"
############################## Begin Functions ##############################
# Function to create a montly folder for scan results.
createScanPath(){
    if [ ! -e "$SCANPATH/$SCANDATE" ]
    then
        mkdir "$SCANPATH/$SCANDATE"
    fi
}
# Function to execute Evaluate-STIG
execEvaluateSTIG(){
$EXECPATH/Evaluate-STIG_Bash.sh $EXECARGS
}
# Function to upload results to network share.
uploadScanResults(){
    if [ $? -eq 0 ]
    then
        cp -R "/opt/STIG_Compliance/*" "$SCANPATH/$SCANDATE/"
        if [ $? -eq 0 ]
        then
            echo "Results copied to $SCANPATH/$SCANDATE/$IMPHOST"
        fi
    else
        echo "Scan did not complete successfully, investigate"
        exit 1
    fi
}
# Menu to set what to scan
PS3="Select Operation: "
menu(){
echo "
#######################
# Select What to Scan #
#######################"
select opt in "CentOS 7" "Firefox" "Both" "Quit"
do
    case $opt in
        "CentOS 7") selectSTIG="CentOS7"
        ;;

        "Firefox") selectSTIG="Firefox"
        ;;

        "Both") selectSTIG="Firefox,CentOS7"
        ;;

        "Quit") exit
        ;;

    esac
done
}
############################## Begin Main Oper ##############################
menu
createScanPath
execEvaluateSTIG
uploadScanResults
