import { deleteSync } from 'del';

import { build } from './grails-builder.js';
import { paths } from './paths.js';

const options = {
    outputDir:   './plugin/grails-app/views/console/',
    relativeDir: './plugin/src/main/resources/public',
    webDir:      './plugin/src/main/resources/public/console/',
    faviconWrap: path => `<link rel="icon" type="image/png" href="\${resource(file: '${path}')}" />`,
    jsWrap:      path => `<script type="text/javascript" src="\${resource(file: '${path}')}" ></script>`,
    cssWrap:     path => `<link rel="stylesheet" media="screen" href="\${resource(file: '${path}')}" />`,
    paths:       paths
};

export const grailsCleanTask = (cb) => {
    deleteSync([
        './plugin/src/main/resources/public/**/*',
        './plugin/grails-app/views/console/_*.gsp',
    ]);
    cb();
};

export const grailsDebugTask = () => {
    return build(true, options);
};

export const grailsReleaseTask = () => {
    return build(false, options);
};
