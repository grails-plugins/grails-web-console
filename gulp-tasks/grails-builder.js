'use strict';

import gulp from 'gulp';
import concat from 'gulp-concat';
import merge from 'merge-stream';
import mkdirp from 'mkdirp';
import path from 'node:path';

import wrapPath from './wrap-path.js'

export const build = (isDebug, options) => {
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

    return merge([
        gulp.src(appSrc),
        gulp.src('./web/img/**/*', { base: './web/' }),
        gulp.src([
            './web/vendor/**/*',
            '!./web/vendor/bootstrap{,/**}',
        ], { base: './web/' }),
        ...externalAssetStreams,
    ])
        .pipe(gulp.dest(options.webDir))
        .on('end', async () => {
            await mkdirp(options.outputDir);

            gulp.src([options.paths.favicon].map(path => options.webDir + path))
                .pipe(wrapPath(options.relativeDir, options.faviconWrap))
                .pipe(concat('_favicon.gsp'))
                .pipe(gulp.dest(options.outputDir));

            gulp.src(jsSrc)
                .pipe(wrapPath(options.relativeDir, options.jsWrap))
                .pipe(concat('_js.gsp'))
                .pipe(gulp.dest(options.outputDir));

            gulp.src(cssSrc)
                .pipe(wrapPath(options.relativeDir, options.cssWrap))
                .pipe(concat('_css.gsp'))
                .pipe(gulp.dest(options.outputDir));
        });
};
