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
import { Component, Input } from '@angular/core';
import { OnInit } from '@angular/core';
import { ProjectService } from './services/project.service';
import {Project} from "./model/project";
import {Inotify} from "./model/inotify";
import {Projects} from "./model/projects";


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements  OnInit{

  public projects: Projects = new Projects;

  private editing: Map<number, Project>;

  terminalLinks: Array<string>;

  saving: boolean = false;

  runningCommands: boolean = false;

  private terminalLink: string = 'http://localhost:8401/wetty/ssh/vagrant';

  constructor(private projectService: ProjectService) {}

  ngOnInit(): void { this.loadProjects(); }


  trackByIndex(index: number, value: number) {
    return index;
  }

  loadProjects(): void {
    this.projectService.getProjects().then(projects => {
      this.projects = projects;
      this.editing = new Map;
      this.terminalLinks = new Array;

      if (projects && projects.projects) {
        projects.projects.forEach((value, index, array) => {
          this.terminalLinks.push(this.terminalLink);
        });
      }
    });
  }

  isObject(value: any): boolean {
    return value !== null && ['Inotify', 'Object', 'Project', 'Projects'].indexOf(value.constructor.name) !== -1;
  }

  isArray(value: any): boolean {
    return value !== null && value.constructor.name === 'Array';
  }

  isBoolean(value: any): boolean {
    return value !== null && value.constructor.name === 'Boolean';
  }

  getInlineEditorType(value: any): string {
    let valueTypeName = value.constructor.name;
    return 'text';
  }

  isInEditMode(id:number): boolean {
    return this.editing[id];
  }

  toggleEditMode(id: number, project: Project): void {
    if (this.isInEditMode(id)) {
      project.screenName = project.name.trim().replace(/\s/g,'-')
      delete this.editing[id];
      return;
    }
    this.editing[id] = project;
  }

  isEditable(id: number, property: string, value: any): boolean {
    return this.isInEditMode(id) && property !== 'screenName' && !this.isArray(value) && !this.isObject(value);
  }

  handleInotify(project: Project): void {
    if (project.inotify) {
      delete project.inotify;
      return;
    }
    project.inotify = new Inotify();
  }

  handleCommands(project: Project): void {
    if (project.commands) {
      delete project.commands;
      return;
    }
    project.commands = new Array('');
  }

  addCommand(project: Project): void {
    project.commands.push('');
  }

  removeCommand(project: Project, index: number): void {
    project.commands.splice(index, 1);
  }

  moveUp(project: Project, index: number): void {
    if (index < 1 || project.commands.length <= index) {return;}
    let movable = project.commands.splice(index, 1);
    project.commands.splice(index - 1, 0, movable[0]);
  }

  moveDown(project: Project, index: number): void {
    if (index < 0 || project.commands.length <= index + 1) {return;}
    let movable = project.commands.splice(index + 1, 1);
    project.commands.splice(index, 0, movable[0]);
  }

  refreshTerminalConnection(index: number): void {
    let link = this.terminalLinks[index];
    if (link.charAt(link.length - 1) === '/') {
      this.terminalLinks[index] = link.substr(0, link.length - 1);
    } else {
      this.terminalLinks[index] += '/';
    }
  }

  addProject(): void {
    this.terminalLinks.push(this.terminalLink)
    this.projects.projects.push(new Project);
  }

  removeProject(index): void {
    this.projects.projects.splice(index, 1);
    this.terminalLinks.splice(index, 1);
  }

  saveProjects(): void {
    if (this.saving) {return;}
    this.saving = true;
    this.projectService.saveProjects(this.projects).then(response => {this.saving = false;});
  }

  runProjectCommands(project: Project): void {
    if (!project.name || project.name.trim() === '') {
      alert('Please specify project name first.');
    }

    if(this.runningCommands) {return;}
    this.runningCommands = true;

    this.projectService.runProjectCommands(project.name).then((response) => {this.runningCommands = false;});
  }

  runProjects(): void {
    this.projectService.runAllProjects();
  }
}
