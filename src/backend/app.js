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

import Koa from 'koa';
import { router, settings } from './config';

const app    = new Koa(),
    logger = require('koa-morgan'),
    moment = require('moment'),
    serve = require('koa-static'),
    mount = require('koa-mount'),
    cors = require('koa2-cors'),
    bodyParser = require('koa-body-parser');

// set logger
logger.token('date', format => {
    const clf = 'DD/MMM/YYYY:HH:mm:ss ZZ';
    return moment(format._startTime).format(clf);
});

app.use(logger('combined'));

// error handler
app.use(async (ctx, next) => {
    try {
        await next();
} catch(err) {
    ctx.body = { message: err.message };
    ctx.status = err.status || 500;
}
});

// routing
app.use(cors({origin: '*'}))
    .use(bodyParser())
    .use(router.routes())
    .use(router.allowedMethods())
    .use(serve('public'))
    .use(mount('/public', app))
    ;

module.exports = app;