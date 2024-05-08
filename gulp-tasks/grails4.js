import { deleteSync } from 'del';

import { build } from './grails-builder.js';
import { paths } from './paths.js';

const options = {
    outputDir:   './grails4/plugin/grails-app/views/console/',
    relativeDir: './grails4/plugin/src/main/resources/static',
    webDir:      './grails4/plugin/src/main/resources/static/console/',
    faviconWrap: path => `<link rel="icon" type="image/png" href="\${resource(file: '${path}')}" />`,
    jsWrap:      path => `<script type="text/javascript" src="\${resource(file: '${path}')}" ></script>`,
    cssWrap:     path => `<link rel="stylesheet" media="screen" href="\${resource(file: '${path}')}" />`,
    paths:       paths
};

export const grails4CleanTask = (cb) => {
    deleteSync([
        './grails4/plugin/src/main/resources/static/**/*',
        './grails4/plugin/grails-app/views/console/_*.gsp',
    ]);
    cb();
};

export const grails4DebugTask = () => {
    return build(true, options);
};

export const grails4ReleaseTask = () => {
    return build(false, options);
};
