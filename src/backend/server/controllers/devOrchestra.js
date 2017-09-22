/**
 * Copyright 2017 - Present Kreshnik Gunga

 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at

 * http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

import BaseCtrl from './base';

const send = require('koa-send');

const execSync = require('child_process').execSync;

const fs = require('fs');

const devOrchestraConfig = '/vagrant/devOrchestra/devOrchestra.conf.json';

export default class DevOrchestraCtrl extends BaseCtrl {
    index() {
        return (ctx, next) => {
             ctx.body = this.getdevOrchestraConfigFileContent();
        };
    }

    show() {
        return (ctx, next) => {
            let project = this.getProject(ctx.params.id)
            ctx.body = project;
        };
    }

    save() {
        return (ctx, next) => {
            this.savedevOrchestraConfigFile(ctx.request.body);
            ctx.body = ctx.request.body;
        }
    }

    runAllProjects() {
        return this.runProjects(false);
    }

    runAutoStartProjects() {
        return this.runProjects(true);
    }

    runProjects(onlyAutoStart) {
        return (ctx, next) => {
            let configuration = this.getdevOrchestraConfigFileContent();
            let results = {};
            if (configuration && configuration.projects) {
                configuration.projects.forEach((project) => {
                    if (onlyAutoStart === true) {
                        if (project.autoStart === false) {
                            return;// old style continue
                        }
                    }
                    let result = this.executeProjectCommands(project.name);
                    results[project.name] = result;
                });
            }
            ctx.body = JSON.stringify(results);
        }
    }

    executeCommands() {
        return (ctx, next) => {
            console.log('executeCommands invoked with parameter: ', ctx.params.id);
            ctx.body = this.executeProjectCommands(ctx.params.id);
        }
    }

    executeProjectCommands(projectId) {
        let project = this.getProject(projectId);
        let result = 'No project defined with name: ' + projectId;
        if (project) {
            console.log('Project found');
            let commands = project.commands || [];
            let scriptArgs = [project.screenName, project.restartScreen === true, "'" + commands.join(';') + "'"].join(' ').trim();
            console.log('path');
            let inotifyPath = null, regex = null, eventsString = null;
            if (project.inotify && project.inotify.path && project.inotify.regex && project.inotify.events) {
                let events = project.inotify.events;
                eventsString = [events.delete === true?'-e delete':null
                                    , events.create === true? '-e create': null
                                    , events.modify === true? '-e modify':null
                                    , events.move === true? '-e move':null].filter(value => value != null).join(' ').trim();
                inotifyPath = ["'", project.inotify.path, "'"].join('').trim();
                regex = "'" + project.inotify.regex + "'";
            }
            let scriptArguments = [scriptArgs];
            if (inotifyPath != null) {
                scriptArguments.push(inotifyPath);
                scriptArguments.push(regex);
                scriptArguments.push("'" + eventsString + "'");
            }
            console.log('invoking executeCommands.sh with arguments: ', scriptArguments.join(' ').trim());
            result = execSync('./executeCommands.sh ' + scriptArguments.join(' ').trim()).toString();
        }
        return result;
    }

    getProject(id) {
        let projects = this.getdevOrchestraConfigFileContent().projects || [];
        let project = projects.filter((project) => project.name === id).pop();
        return project;
    }

    getdevOrchestraConfigFileContent() {
        let configuration = fs.readFileSync(devOrchestraConfig, 'utf8');
        console.log(configuration);
        if (configuration && configuration.trim() !== '') {
            let projects = JSON.parse(configuration);
            if (projects && !projects.projects) {
                projects.projects = [];
            }
            return projects;
        }
        return {"projects": []};
    }

    savedevOrchestraConfigFile(jsonObject) {
        require('fs').writeFileSync(devOrchestraConfig, JSON.stringify(jsonObject), (error) => {if (error) throw error;});
    }
}