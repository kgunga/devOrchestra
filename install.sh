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

install_with_apt_on_demand()
{
    if [ "$(type -p $1 && echo no)" = "no" ]; then
        echo "$1 not available, installing it"
        sudo apt-get install "$1"
        echo "$1 installed"
    else
        echo "$1 available, proceeding"
    fi
}

install_with_npm_on_demand()
{
    if [ "$(type -p $1 && echo no)" = "no" ]; then
        echo "$1 not available, installing it"
        npm install -g "$1"
        echo "$1 installed"
    else
        echo "$1 available, proceeding"
    fi
}

install_with_apt_on_demand 'git'

install_with_apt_on_demand 'python'

install_with_apt_on_demand 'cutils'

install_with_apt_on_demand 'findutils'

install_with_apt_on_demand 'mawk'

install_with_apt_on_demand 'curl'

install_with_apt_on_demand 'wget'

install_with_apt_on_demand 'build-essential'

install_with_apt_on_demand 'libssl-dev'

install_with_apt_on_demand 'screen'

install_with_apt_on_demand 'inotifywait'

install_with_apt_on_demand 'figlet'



if [ "$(type -p npm && echo no)" = "no" ]; then
    echo "nvm (node package manager) not available, installing it"
    git clone git://github.com/creationix/nvm.git ~/.nvm
    echo source /.nvm/nvm.sh >> ~/.bashrc
    echo "nvm installed"
else
    echo "npm available, proceeding"
fi

if [ "$(type -p node && echo no)" = "no" ]; then
    echo "node not available, installing it"
    nvm install node
    echo "node installed"
else
    echo "node available, proceeding"
fi

install_with_npm_on_demand 'nodemon'

install_with_npm_on_demand 'angular-cli'


CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p $CURRENT_DIR/scripts
mkdir -p $CURRENT_DIR/scripts/logs

cp $CURRENT_DIR/puppet/modules/baseconfig/files/*sh $CURRENT_DIR/scripts/
chmod +x $CURRENT_DIR/scripts/*sh

if [ "$(grep -wc "$CURRENT_DIR/scripts/on-system-up.sh" /etc/rc.local)" -eq "0" ]; then
    sudo sed -i "/exit/ i sudo -u vagrant $CURRENT_DIR/scripts/on-system-up.sh" /etc/rc.local
    if [ "$(grep -wc "$CURRENT_DIR/scripts/on-system-up.sh" /etc/rc.local)" -eq "0" ]; then
        echo "sudo -u vagrant $CURRENT_DIR/scripts/on-system-up.sh" | sudo tee -a /etc/rc.local
    fi
fi

DEV_ORCHESTRA_CONF_DIR='/vagrant/devOrchestra'

mkdir -p $DEV_ORCHESTRA_CONF_DIR

if [ ! -f $DEV_ORCHESTRA_CONF_DIR/devOrchestra.conf.json ]; then
    echo '{"projects":[]}' > $DEV_ORCHESTRA_CONF_DIR/devOrchestra.conf.json
fi

echo 'Add the following lines into your Vagrantfile'

echo "Port for DevOrchestra Back-End"
echo config.vm.network "forwarded_port", guest: 8400, host: 8400
echo
echo "DevOrchestra UI"
echo config.vm.network "forwarded_port", guest: 3000, host: 3000
echo
echo "DevOrchestra Web-Terminal"
echo config.vm.network "forwarded_port", guest: 8401, host: 8401
echo
echo

echo "Synchronize your projects under /home/vagrant"
echo
echo "Example"
echo
echo "config.vm.synced_folder "./src/project", "/home/vagrant/project", id: "unique-id", type: "rsync", rsync__exclude: [".git/","node_modules/","dist/"]"
echo
echo "And to keep auto deployment up, run vagrant rsync-auto"

echo
echo
echo "Restart virtual machine and you are ready to you devOrchestra"
echo
