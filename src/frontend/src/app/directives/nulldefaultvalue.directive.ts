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

import {NgControl} from "@angular/forms";
import {Directive, ElementRef, HostListener} from "@angular/core";

@Directive({
  selector: 'input[nullValue]'
})
export class NullDefaultValueDirective {
  constructor(private elementRef: ElementRef, private control: NgControl) {}

  @HostListener('input', ['$event.target'])
  onEvent(targetElement: HTMLInputElement){
    this.control.viewToModelUpdate((targetElement.value === '') ? null : targetElement.value);
  }
}
