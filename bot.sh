#!/bin/ksh
BOT_VERSION="0.2.0-alpha"

#Initialization of env.
. ./.env

last_update_id=$(cat "$BOT_LAST_UPDATE_FILE")                            #Read last message ID.
echo "Bot active. Latest ID: "$last_update_id". Version: "$BOT_VERSION"" #Info line.

#Send daily stats image function
sendDaily() {
    vnstati -d -i "$BOT_INTERFACE_NAME" -o dailyStats.png
    curl -s -X POST "https://api.telegram.org/bot"$BOT_TOKEN"/sendPhoto" \
        -F "chat_id=$BOT_CHAT_ID" \
        -F "photo=@dailyStats.png"
}

sendRepeaterLogDaily() {
    curl -s -X POST "https://api.telegram.org/bot"$BOT_TOKEN"/sendMessage" \
        -F "chat_id=$BOT_CHAT_ID" \
        -F "text=$(cd ./dailyRepeater && bash ./counter.sh)"
}

#Resync messages
reSync() {
    chat=$(curl -s -X GET "https://api.telegram.org/bot"$BOT_TOKEN"/getUpdates?offset=""$last_update_id" 2>/dev/null)
    last_update_id=$(($(echo "$chat" | jq -r '.result[-1].update_id') + 1))
}

#Update last message ID after iteration
updateId() {
    last_update_id=$(($(echo "$chat" | jq -r '.result[-1].update_id') + 1))
    echo "$last_update_id" >"$BOT_LAST_UPDATE_FILE"
}

#Main program.
reSync #Resync so to wait for last_update_id + 1 before starting while loop.
while true; do
    #Get updates from last_update_id after having resynced.
    chat=$(curl -s -H "Content-Type: application/json" -X GET "https://api.telegram.org/bot"$BOT_TOKEN"/getUpdates?offset=$last_update_id" 2>/dev/null)

    #Manage message/s and answer to /dailyStats
    echo "$chat" | jq -c '.result[]' | while read -r msgI; do
        msg=$(echo "$msgI" | jq -r '.message.text')
        username=$(echo "$msgI" | jq -r '.message.from.username')
        if [[ "$msg" == "/dailyStats" ]]; then
            sendDaily >/dev/null
        elif [[ "$msg" == "/dailyRepeater" ]]; then
            sendRepeaterLogDaily >/dev/null
        fi
        echo "LOG [UTC $(date -u '+%d-%m-%Y %H:%M:%S')] - User: @"$username" - Command: "$msg"" >>bot.log
        updateId
    done
    sleep "$BOT_SLEEPTIME"
done
