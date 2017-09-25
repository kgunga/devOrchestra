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

DEV_ORCHESTRA_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"

# Util script for logging
SCRIPT_DIR="$DEV_ORCHESTRA_HOME/scripts"
source "$SCRIPT_DIR/log.sh"

[ -f "$logfile" ] && rm "$logfile"

log "starting developing screens"

# Start devOrchestra UI

ps aux | grep "dmS devOrchestra-frontend-screen bash" | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
screen -wipe
screen -dmS devOrchestra-frontend-screen bash -c "cd $DEV_ORCHESTRA_HOME/frontend; source ~/.nvm/nvm.sh && npm install && npm start; exec bash;"

ps aux | grep "dmS devOrchestra-backend-screen bash" | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
screen -wipe
screen -dmS devOrchestra-backend-screen bash -c "cd $DEV_ORCHESTRA_HOME/backend; source ~/.nvm/nvm.sh &&  npm install && npm start; exec bash;"

# Strart wetty (web-Terminal)
ps aux | grep "dmS wetty-server-screen bash" | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
screen -wipe
screen -dmS wetty-server-screen bash -c "cd $DEV_ORCHESTRA_HOME/wetty; source ~/.nvm/nvm.sh && npm install && node app.js -p 8401; exec bash;"

# Start all projectes marked as autoStart = true
until $(curl --output /dev/null --silent --head --fail http://localhost:8400/projects); do
    log "Backend not yet up, waiting"
    sleep 5
done

curl --output /dev/null --silent --head --fail http://localhost:8400/projects/runAutoStartProjects

log "developing screens started"