#!/bin/bash

#Initialization of env.
source ../.env

log_path="$DAILYREPEATER_LOG_PATH"
day_pattern="$(LC_ALL=C date +"%a %b %d" | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2)) " " toupper(substr($2,1,1)) tolower(substr($2,2)) " " $3}')"
temp_s=""
start_pattern="The squelch is OPEN"
close_pattern="The squelch is CLOSED"
tgOPEN_pattern="Talker start on TG"
tgCLOSE_pattern="Talker stop on TG"
nQSO=0
nTOT=0
nMinuti=0
nSecondi=0
openSec=0
closeSec=0
CARRIER_DELAY=$DAILYREPEATER_CARRIER_DELAY
# Assigning a value to make sure it's interpreted as integer ^^

# First phase, extracting log blocks to $temp_s;
while IFS= read -r line; do
    if [[ "$line" =~ $day_pattern ]]; then
        if [[ "$line" =~ $start_pattern ]]; then
            temp_s+="$line"$'\n'
            while IFS= read -r line && [[ ! "$line" =~ $close_pattern ]]; do
                temp_s+="$line"$'\n'
            done
            temp_s+="$line"$'\n'$'\n'
        fi
    fi
done <"$log_path"

# Second phase, counting as appropriate.
while IFS= read -r line; do
    if [[ "$line" =~ $start_pattern ]]; then
        nTOT=$((nTOT + 1))
    fi
    if [[ "$line" =~ $tgOPEN_pattern ]]; then
        if [[ "$line" =~ ([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
            IFS=":" read -r hours mins secs <<<"${BASH_REMATCH[0]}"
            openSec=$((10#$hours * 3600 + 10#$mins * 60 + 10#$secs)) # Base 10 enforced for safety
        fi
        while IFS= read -r line && [[ ! "$line" =~ $close_pattern ]]; do
            if [[ "$line" =~ $tgCLOSE_pattern ]]; then
                if [[ "$line" =~ ([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
                    IFS=":" read -r hours mins secs <<<"${BASH_REMATCH[0]}"
                    closeSec=$((10#$hours * 3600 + 10#$mins * 60 + 10#$secs)) # Base 10 enforced for safety
                    if ((($closeSec - $openSec) >= $CARRIER_DELAY)); then
                        #echo $((($closeSec - $openSec) % 60)) debug -> print each "valid" QSOs, with delta greater than $CARRIER_DELAY
                        nQSO=$((nQSO + 1))
                        nMinuti=$(($nMinuti + $((($closeSec - $openSec) / 60))))
                        nSecondi=$(($nSecondi + $((($closeSec - $openSec) % 60))))
                    fi
                fi
            #Double tx handling
            elif [[ "$line" =~ $tgOPEN_pattern ]]; then
                nTOT=$((nTOT + 1))
                if [[ "$line" =~ ([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
                    IFS=":" read -r hours mins secs <<<"${BASH_REMATCH[0]}"
                    openSec=$((10#$hours * 3600 + 10#$mins * 60 + 10#$secs)) #base 10 enforced for safety
                fi
            fi
        done
    fi
done <<<"$temp_s"

#Results
echo "Minuti totali: "$nMinuti""
echo "Secondi totali: "$nSecondi""
echo "QSO/Portanti totali: $nQSO/$nTOT"
