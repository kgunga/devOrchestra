#!/bin/bash
#  Copyright 2017 - Present Kreshnik Gunga

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at

#      http://www.apache.org/licenses/LICENSE-2.0

#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# script arguments: $1 = screen name, $2  = restart screen = true/false, $3 = commands with semicolon separated,
# $4 = path to listen, $5 = file name regex, $6 = inotify events, $7 = restart second screen
logger="/home/vagrant/devOrchestra/scripts/log.sh"
source $logger

logfile="/home/vagrant/devOrchestra/scripts/logs/executeCommands.log"

rm -rf "$logfile"

log "Starting executeCommands script";

ScreenRunning="$(ps -ef | grep "dmS $1 bash" | grep -v grep | wc -l)"

if [ "$2" = "true" ]; then
    ps aux | grep "dmS $1 bash" | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
    result=$(screen -wipe)
    log "Screens wiped: $result"
    sleep 2
    ScreenRunning=0
fi

if [ "$ScreenRunning" -eq "0" ]; then
    log "Screen '$1' is not running, starting new one" ;
    screen -dmS $1 bash -c "echo screen '$1' started ; exec bash"
else
    log "Screen '$1' is running";
fi

log "Executing screen commands: $3";

IFS=';' read -ra COMMANDS <<< "$3"

inotifyScreenName="$1-inotify-screen"
INOTIFY_SCREEN_ID=$(ps aux | grep "dmS $inotifyScreenName bash" | grep -v grep | awk '{print $2}')

if [ ! -z "$4" ]; then
    log "inotify parameters given: $4, $5, $6";
    TO_SCREEN_ID=$(ps aux | grep "dmS $1 bash" | grep -v grep | awk '{print $2}')

    if [ -z "$INOTIFY_SCREEN_ID" ]; then
        log "Starting '$inotifyScreenName' screen";
        screen -dmS "$inotifyScreenName" bash -c "echo $inotifyScreenName started; exec bash"
        sleep 2
        else
        log "Stopping inotifywait from listening file changes";
        screen -S "$inotifyScreenName" -X stuff "^C\n"
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # commands must be executed when starting from first time
    for command in "${COMMANDS[@]}"; do
        log "Sending to screen '$1' command '$command'"
        # process "$i"
        screen -S "$TO_SCREEN_ID.$1" -X stuff "$command\n"
    done

    screen -S "$inotifyScreenName" -X stuff "export RESTART_TO_SCREEN='$7'\n"
    screen -S "$inotifyScreenName" -X stuff "export TO_SCREEN_NAME='$1'\n"


    screen -S "$inotifyScreenName" -X stuff "export LOGGER='$logger'\n"
    screen -S "$inotifyScreenName" -X stuff "export LOG_FILE='$logfile'\n"

    screen -S "$inotifyScreenName" -X stuff "export PATH_TO_WATCH='$4'\n"
    screen -S "$inotifyScreenName" -X stuff "export COMMANDS_TO_EXECUTE='$3'\n"
    screen -S "$inotifyScreenName" -X stuff "export FILE_REGEX_PATTERN='$5'\n"
    screen -S "$inotifyScreenName" -X stuff "export INOTIFY_EVENTS='$6'\n"
    screen -S "$inotifyScreenName" -X stuff "export TO_SCREEN='$TO_SCREEN_ID.$1'\n"
    screen -S "$inotifyScreenName" -X stuff ". $SCRIPT_DIR/startInotify.sh\n"

    else
        # stop inotify screen if is running
        if [ ! -z "$INOTIFY_SCREEN_ID" ]; then
            ps aux | grep "dmS $inotifyScreenName bash" | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
            screen -wipe
        fi
        for command in "${COMMANDS[@]}"; do
            log "Sending to screen '$1' command '$command'"
            # process "$i"
            screen -S $1 -X stuff "$command\n"
        done
fi



