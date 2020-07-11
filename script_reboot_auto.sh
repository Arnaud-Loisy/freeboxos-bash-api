#!/bin/bash
source /home/freebox/freeboxos_bash_api.sh
Logfile=/var/log/freebox-bash-api.log
MY_APP_ID="BACHE"
MY_APP_TOKEN="gGri1hD2xSejQHyoXoIFp3F6e+8JG9WRLPi3CNYpE65774wokVXcdqGPFkNfhvLG"
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"
answer=$(call_freebox_api '/connection/xdsl/')
snr=`dump_json_keys_values "$answer" | grep down.snr_10 | awk {'print $3'}`
debit=`dump_json_keys_values "$answer" | grep down.rate | awk {'print $3'}`
answer=$(call_freebox_api '/lan/browser/pub/ether-00:1d:7d:00:XX:XX/')
PC_is_up=`dump_json_keys_values "$answer" | grep result.reachable | awk {'print $3'}`
if [ $snr -gt 50 ] && [ $debit -lt 1900 ]  && [ !PC_is_up ]; then
        echo "`date +"%m-%d-%Y %H:%M"` - SNR_10 : $snr Debit : $debit PC_is_UP : $PC_is_up" >> $Logfile
        echo "`date +"%m-%d-%Y %H:%M"` - Reboot de la boiboite!" >> $Logfile
        sleep 10
        reboot_freebox
else
        echo "`date +"%m-%d-%Y %H:%M"` - SNR_10 : $snr Débit : $debit PC_is_UP : $PC_is_up" >> $Logfile
        echo "`date +"%m-%d-%Y %H:%M"` - RAF Gros" >> $Logfile
fi
