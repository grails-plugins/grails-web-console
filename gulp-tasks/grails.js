import { deleteSync } from 'del';

import { build } from './grails-builder.js';
import { paths } from './paths.js';

// Emits a GSP expression resolving the webjar version actually on the runtime
// classpath. Webjars carrying a build-time version fall back to it; the ones the
// Grails BOM manages have none, and resolution can only fail when the app has
// excluded the dependency outright — in which case the link would 404 whatever
// version it named.
const webjarVersionExpression = webjar => webjar.defaultVersion
    ? `\${org.grails.plugins.console.WebjarVersions.version('${webjar.name}') ?: '${webjar.defaultVersion}'}`
    : `\${org.grails.plugins.console.WebjarVersions.version('${webjar.name}')}`;

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
