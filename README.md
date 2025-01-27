# RepeaterBOT - 0.2.0-alpha

## Introduction 👋

RepeaterBOT is a telegram bot created to facilitate the management of ham radio repeaters, especially the digital ones, with resource usage in mind and code simplicity.

By using shell scripting, with `ksh`\* the bot is able to run on bare minimum software, without the need of complex interpreters, therefore saving as much space as possible, which sometimes is critical on repeater setups.

##### \* Certain functions do NOT use `ksh`: `/dailyRepeater` _currently_ uses `bash` instead.

## Requirements 🛠️

### 1. Prerequisites

In order to run the bot properly make sure to have the following software installed:

- **`curl`** -> HTTP/S requests.

- **`ksh`** -> Shell interpreter.

- **`jq`** -> JSON parsing.

- **`vnstat`** -> Monitors the traffic of network interfaces and gathers data.\*

- **`vnstati`** -> Generates images based off _vnstat_'s collected data.
- **`svxlink`** -> Allows the usage of the `/dailyRepeater` command.\*\*

Most likely you will be running a Debian-based Linux distribution, so here you go a quick install&run command:

    sudo apt install curl ksh jq vnstat vnstati
    sudo systemctl enable --now vnstat

##### \*allow `vnstat` to run for a couple of minutes before trying to get the statistics.

##### \* Requires manual installation, as it is NOT provided directly via common Linux distributions repositories.

### 2. Update ID requirement

Next, make sure to populate the `LAST_UPDATE_FILE` directive in the `.env.example` file with the _latest_ `update_id` from the Telegram API reachable at: https://api.telegram.org/botTOKEN/getUpdates \*

##### \*make sure to replace "botTOKEN" with your token from [@BotFather](https://t.me/botfather).

## Advices 📢

Given the development stage of the bot, it is suggested to run it behind a Linux `screen` to keep it working in the background.

## Features ⭐

As of the [current version](https://semver.org/), 0.2.0-alpha, the bot offers:

- **Efficient space and performance**: Thanks to `ksh` and its light-weight nature as opposed to the most known but resource-hungrier `bash`. The entire bot uses around 3.3MB of RAM.\*

- **Logging**: Logs all _commands_ sent to it in a file specified within `.env.example`.

- **Interface statistics**: Specific, daily, network interface monitoring with image generation via the bot command `/dailyStats`.
- **Repeater QSOs statistics**: Current day [SvxLink](https://www.svxlink.org/) log parsing via the bot command `/dailyRepeater`.

##### \* Resident Set Size(RSS) value in a non-swap enabled system.
