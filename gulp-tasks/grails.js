import { deleteSync } from 'del';

import { build } from './grails-builder.js';
import { paths } from './paths.js';

// Emits a GSP expression resolving the webjar version actually on the runtime
// classpath, with the plugin's build-time version as the fallback
const webjarVersionExpression = webjar =>
    `\${org.grails.plugins.console.WebjarVersions.version('${webjar.name}') ?: '${webjar.defaultVersion}'}`;

const options = {
    outputDir:   './plugin/grails-app/views/console/',
    relativeDir: './plugin/src/main/resources/public',
    webDir:      './plugin/src/main/resources/public/console/',
    faviconWrap: path => `<link rel="icon" type="image/png" href="\${resource(file: '${path}')}" />`,
    jsWrap:      path => `<script type="text/javascript" src="\${resource(file: '${path}')}" ></script>`,
    cssWrap:     path => `<link rel="stylesheet" media="screen" href="\${resource(file: '${path}')}" />`,
    webjarJsWrap:  webjar => `<script type="text/javascript" src="\${request.contextPath}/webjars/${webjar.name}/${webjarVersionExpression(webjar)}/${webjar.file}" ></script>`,
    webjarCssWrap: webjar => `<link rel="stylesheet" media="screen" href="\${request.contextPath}/webjars/${webjar.name}/${webjarVersionExpression(webjar)}/${webjar.file}" />`,
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
