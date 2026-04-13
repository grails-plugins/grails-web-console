'use strict';

import { deleteSync } from 'del';
import { execFile } from 'node:child_process';
import gulp from 'gulp';
import coffee from 'gulp-coffee';
import concat from 'gulp-concat';
import declare from 'gulp-declare';
import gulpHandlebars from 'gulp-handlebars';
import gulpLess from 'gulp-less';
import Handlebars from 'handlebars';
import cleanCss from 'gulp-clean-css';
import wrap from 'gulp-wrap';

import { grailsCleanTask, grailsDebugTask, grailsReleaseTask } from './gulp-tasks/grails.js';
import { paths, timestamp } from './gulp-tasks/paths.js';

export const clean = (cb) => {
    deleteSync('./build');
    cb();
};

export const templates = () => {
    return gulp.src('./web/templates/**/*.hbs')
        .pipe(gulpHandlebars({
            handlebars: Handlebars
        }))
        .pipe(wrap('Handlebars.template(<%= contents %>)'))
        .pipe(declare({
            namespace: 'JST',
            processName: filePath => filePath.replace(/^.*web\/templates\//, '').replace(/\.js$/, '')
        }))
        .pipe(concat('templates.js'))
        .pipe(gulp.dest('./build/debug/js/'));
};

const coffeeApp = () => {
    return gulp.src('./web/app/**/*.coffee')
        .pipe(coffee({bare: false, join: false}).on('error', error => console.error(error)))
        .pipe(gulp.dest('./build/debug/js/app/'));
};

const coffeeSpec = () => {
    return gulp.src('./web/spec/**/*.coffee')
        .pipe(coffee({bare: false, join: false}).on('error', error => console.error(error)))
        .pipe(gulp.dest('./build/spec/'));
};

export const less = () => {
    return gulp.src('./web/styles/**/*.less')
        .pipe(gulpLess())
        .pipe(gulp.dest('./build/debug/css/'));
};

export const concatJsTask = () => {
    return gulp.src(paths.vendor.jsAssets.map(asset => asset.src)
        .concat(paths.app.js.debug.map(path => './build/debug' + path))
    )
        .pipe(concat(`app.${timestamp}.js`))
        .pipe(gulp.dest('./build/release/js/'));
};

const concatCssTask = () => {
    return gulp.src(paths.app.css.debug.map(path => './build/debug' + path))
        .pipe(cleanCss({ keepBreaks: true }))
        .pipe(concat(`app.${timestamp}.css`))
        .pipe(gulp.dest('./build/release/css/'));
};

const testTask = () => {
    return new Promise((resolve, reject) => {
        execFile(process.execPath, ['./run-jasmine-jsdom.cjs'], { cwd: process.cwd() }, (error, stdout, stderr) => {
            if (stdout) {
                process.stdout.write(stdout);
            }

            if (stderr) {
                process.stderr.write(stderr);
            }

            if (error) {
                reject(error);
                return;
            }

            resolve();
        });
    });
};

export const test = gulp.series(clean, templates, coffeeApp, coffeeSpec, testTask);

export const watch = (cb) => {
    gulp.watch(['./web/**/*', 'gulpfile.js'], gulp.series(debugAll));
    cb();
};

export const debug = gulp.series(clean, templates, coffeeApp, less);
export const release = gulp.series(debug, concatJsTask, concatCssTask);

export const concatJs = gulp.series(debug, concatJsTask);
export const concatCss = gulp.series(debug, concatCssTask);

export const grailsClean = gulp.series(grailsCleanTask);
export const grailsDebug = gulp.series(debug, grailsCleanTask, grailsDebugTask);
export const grailsRelease = gulp.series(release, grailsCleanTask, grailsReleaseTask);

export const debugAll = gulp.series(grailsDebugTask);
export const releaseAll = gulp.series(grailsReleaseTask);
export const cleanAll = gulp.series(clean, grailsCleanTask);

//gulp.task('default', ['build']);
