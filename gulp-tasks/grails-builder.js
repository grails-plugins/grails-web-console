'use strict';

import gulp from 'gulp';
import concat from 'gulp-concat';
import { mkdirp } from 'mkdirp';
import path from 'node:path';
import { finished } from 'node:stream/promises';

import wrapPath from './wrap-path.js'

// Resolve once the stream has finished writing all of its output to disk.
// gulp.dest only emits 'end' after each file has been flushed, so we drain the
// readable side (to avoid backpressure stalling it) and wait for it to end.
const written = (stream) => {
    stream.resume();
    return finished(stream);
};

export const build = async (isDebug, options) => {
    let appSrc, jsSrc, cssSrc;
    if (isDebug) {
        appSrc = './build/debug/**/*';
        jsSrc = options.paths.vendor.js.concat(options.paths.app.js.debug).map(path => options.webDir + path);
        cssSrc = options.paths.vendor.css.concat(options.paths.app.css.debug).map(path => options.webDir + path);
    } else {
        appSrc = './build/release/**/*';
        jsSrc = options.paths.app.js.release.map(path => options.webDir + path);
        cssSrc = options.paths.vendor.css.concat(options.paths.app.css.release).map(path => options.webDir + path);
    }

    const externalAssetStreams = [
        ...(options.paths.vendor.cssAssets || []),
        ...(options.paths.vendor.jsAssets || []),
    ].filter(asset => asset.src.startsWith('./node_modules/')).map(asset => {
        const destination = path.join(options.webDir, path.posix.dirname(asset.publicPath));
        return gulp.src(asset.src, { base: path.dirname(asset.src) })
            .pipe(gulp.dest(destination));
    });

    // Copy all web assets first and wait until they are fully written, since
    // the GSP fragments below read the copied files back from disk. Each source
    // is copied as its own pipeline (rather than a single merged stream) so we
    // can reliably await completion of every write.
    await Promise.all([
        written(gulp.src(appSrc).pipe(gulp.dest(options.webDir))),
        written(gulp.src('./web/img/**/*', { base: './web/' }).pipe(gulp.dest(options.webDir))),
        written(gulp.src([
            './web/vendor/**/*',
            '!./web/vendor/bootstrap{,/**}',
        ], { base: './web/' }).pipe(gulp.dest(options.webDir))),
        ...externalAssetStreams.map(written),
    ]);

    await mkdirp(options.outputDir);

    await Promise.all([
        written(gulp.src([options.paths.favicon].map(path => options.webDir + path))
            .pipe(wrapPath(options.relativeDir, options.faviconWrap))
            .pipe(concat('_favicon.gsp'))
            .pipe(gulp.dest(options.outputDir))),

        written(gulp.src(jsSrc)
            .pipe(wrapPath(options.relativeDir, options.jsWrap))
            .pipe(concat('_js.gsp'))
            .pipe(gulp.dest(options.outputDir))),

        written(gulp.src(cssSrc)
            .pipe(wrapPath(options.relativeDir, options.cssWrap))
            .pipe(concat('_css.gsp'))
            .pipe(gulp.dest(options.outputDir))),
    ]);
};
