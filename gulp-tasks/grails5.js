import { deleteSync } from 'del';

import { build } from './grails-builder.js';
import { paths } from './paths.js';

const options = {
    outputDir:   './grails5/plugin/grails-app/views/console/',
    relativeDir: './grails5/plugin/src/main/resources/static',
    webDir:      './grails5/plugin/src/main/resources/static/console/',
    faviconWrap: path => `<link rel="icon" type="image/png" href="\${resource(file: '${path}')}" />`,
    jsWrap:      path => `<script type="text/javascript" src="\${resource(file: '${path}')}" ></script>`,
    cssWrap:     path => `<link rel="stylesheet" media="screen" href="\${resource(file: '${path}')}" />`,
    paths:       paths
};

export const grails5CleanTask = (cb) => {
    deleteSync([
        './grails5/plugin/src/main/resources/static/**/*',
        './grails5/plugin/grails-app/views/console/_*.gsp',
    ]);
    cb();
};

export const grails5DebugTask = () => {
    return build(true, options);
};

export const grails5ReleaseTask = () => {
    return build(false, options);
};
