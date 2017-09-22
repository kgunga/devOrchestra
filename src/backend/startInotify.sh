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

source $LOGGER
logfile=$LOG_FILE

log "Screen to send commands to '$TO_SCREEN'";
log "Listening to '$PATH_TO_WATCH' with events '$INOTIFY_EVENTS' and file regex '$FILE_REGEX_PATTERN'";
log "Will execute commands $COMMANDS_TO_EXECUTE";

inotifywait $PATH_TO_WATCH -m -r $INOTIFY_EVENTS | while read path action file; do
    if [ $(echo "$file" | grep -Ei "$FILE_REGEX_PATTERN") ]; then
        IFS=';' read -ra COMMANDS <<< "$COMMANDS_TO_EXECUTE"
        for command in "${COMMANDS[@]}"; do
            # process "$i"
            screen -S "$TO_SCREEN" -X stuff "$command\n"
        done
    fi
done;