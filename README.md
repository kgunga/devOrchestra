# devOrchestra

devOrchestra is an Open Source tool that provides simultaneous multiply project development within the same virtual box.
Also it auto deploys all changes.

## Tool structure

devOrchestra consists of two parts, front-end and backend. Also it uses a 3rd party tool (Wetty, https://github.com/krishnasrinivas/wetty) to provide terminal
access straight from browser to virtual box. devOrchestra currently supports Debian/Ubuntu virtual boxes.

Auto deployment for project file changes is implemented using inotifywait command line tool. inotifywait will monitor occurred file events
like delete, modify, create, and move.

devOrchestra also uses screen command line tool to open new session for each project. Also it will open three own screens that
are needed to run devOrchestra.

## Install

You can either make a script (Puppet/Ansible/other) to clone project directly into your virtual box or you can manually
install as follows:

1. git clone https://github.com/kgunga/devOrchestra.git
2. cd devOrchestra
3. chmod +x install.sh
4. ./install.sh
5. Follow instructions showed by installation script

### Vagrant configurations
The following ports must be forwared for devOrchestra:

```
# DevOrchestra Back-End
config.vm.network "forwarded_port", guest: 8400, host: 8400
# DevOrchestra UI
config.vm.network "forwarded_port", guest: 3000, host: 3000
# DevOrchestra Web-Terminal
config.vm.network "forwarded_port", guest: 8401, host: 8401
```

It is recommended to synchronize projects into /home/vagrant folder as the following example:

```
config.vm.synced_folder "/pat/hto/project1", "/home/vagrant/project1", id: "project1",
                    type: "rsync" ,
                    rsync__exclude: [".git/","node_modules/","dist/"],
                    rsync__auto: true

config.vm.synced_folder "/pat/hto/project2", "/home/vagrant/project2", id: "project2",
                      type: "rsync" ,
                      rsync__exclude: [".git/","node_modules/","dist/"],
                      rsync__auto: true
```

Vagrant will automatically synchronize the current folder (where Vagrantfile resides) into /vagrant. 
**Do not synchronize current folder into other folder name or other location.**

devOrchestra will generate **/vagrant/devOrchestra/devOrchestrsa.conf.json** configuration
file and it will use to orchestrate projects' development. Thus the file can be stored to repository and shared across 
version control system. Same configuration works for all development team members.

## Usage
After installation it is recommended to restart the virtual box. devOrchestra should start automatically when virtual box
is started up. devOrchestra has [Web interface](http://localhost:3000/). Click the link and the devOrchestra page will be
shown.

Web interface has a black bar which contains three buttons: Add project, Save, and Run projects. Also it contains field
for searching, but not yet implemented.

### Auto deploy project
1. Click Add project button
2. Give name for the project
3. Give regex for files to be auto deployed .i.e *.java, *.xml
4. Check all events: delete, modify, create, move
5. Give path to synchronized project i.e. /home/vagrant/project1
6. Check autoStart if project should be run at box start up
7. Click Add commands button
8. Give command to be send to project i.e. \\^C (stop project from running. Note! Cancel command must be escaped because it will be send from inotify-screen, otherwise escape is not required)
9. Click + button at commands panel
10. Give command to be send to project i.e. mvn clean install tomcat7:run
11. Click Done button
12. Click Save button to save all changes, otherwise changes will be lost

### Project without auto deployment
1. Click Add project
2. Click Remove inotify button (not neccessary)
3. Give name for the project
4. Click Add commands button
5. Give command to be executedt i.e. tail -f /var/logs/file.log
6. Click Done button
7. Click Save button to save all changes, otherwise changes will be lost

For each project devOrchestra shows a web terminal (Wetty). You can log in into virtual box and monitor project screen.
Please read manual of screen command line tool here [https://www.gnu.org/software/screen/manual/screen.html](https://www.gnu.org/software/screen/manual/screen.html).

Common commands for screen are:
* screen -ls // to list all running screens
* screen -r project1 // will log into screen with name project1
* cmd+a // will tell screen to take command, this shortcut is always pressed
* cmd+d // will leave screen without shutting down
* cmd+esc // will enable rolling within screen

Project can be removed by pressing Remove project button. Remember to save changes always.
Above each terminal panel resides a refresh button. This button starts new terminal session to virtual box.

If there is a need always to restart a project screen when running project commands, check restartScreen.

Run projects button runs all configured and saved commands of projects.

## License
devOrchestra is Open Source project under Apache Software License Version 2.0. Please read LICENSE file for license details.