import { deleteSync } from 'del';

import { build } from './grails-builder.js';
import { paths } from './paths.js';

const options = {
    outputDir:   './grails6/plugin/grails-app/views/console/',
    relativeDir: './grails6/plugin/src/main/resources/public',
    webDir:      './grails6/plugin/src/main/resources/public/console/',
    faviconWrap: path => `<link rel="icon" type="image/png" href="\${resource(file: '${path}')}" />`,
    jsWrap:      path => `<script type="text/javascript" src="\${resource(file: '${path}')}" ></script>`,
    cssWrap:     path => `<link rel="stylesheet" media="screen" href="\${resource(file: '${path}')}" />`,
    paths:       paths
};

export const grails6CleanTask = (cb) => {
    deleteSync([
        './grails6/plugin/src/main/resources/public/**/*',
        './grails6/plugin/grails-app/views/console/_*.gsp',
    ]);
    cb();
};

export const grails6DebugTask = () => {
    return build(true, options);
};

export const grails6ReleaseTask = () => {
    return build(false, options);
};
