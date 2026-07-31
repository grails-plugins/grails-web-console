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

// The import map must carry a concrete version per specifier, so each is resolved
// from the runtime classpath. A module missing from the classpath yields an empty
// version and a broken URL, which only happens when the app has excluded the
// dependency — the same situation in which it would 404 whatever we wrote.
const importMapEntry = m =>
    `    "${m.specifier}": "\${request.contextPath}/webjars/${m.webjar}/\${org.grails.plugins.console.WebjarVersions.version('${m.webjar}')}/${m.file}"`;

const moduleShim = modules => [
    '<script type="importmap">',
    '{',
    '  "imports": {',
    modules.map(importMapEntry).join(',\n'),
    '  }',
    '}',
    '</script>',
    '<script type="module">',
    '  import { EditorState, Compartment } from "@codemirror/state"',
    '  import { EditorView, keymap, lineNumbers, highlightActiveLine, highlightActiveLineGutter } from "@codemirror/view"',
    '  import { defaultKeymap, history, historyKeymap, indentWithTab } from "@codemirror/commands"',
    '  import { StreamLanguage, bracketMatching, indentUnit, syntaxHighlighting, defaultHighlightStyle, HighlightStyle } from "@codemirror/language"',
    '  import { tags } from "@lezer/highlight"',
    '  import { groovy } from "@codemirror/legacy-modes/mode/groovy"',
    '  import { oneDark } from "@codemirror/theme-one-dark"',
    '  // the classic console bundle reads this on jQuery ready, which is after',
    '  // deferred module scripts have run',
    '  window.CM6 = { EditorState, EditorView, Compartment, keymap, lineNumbers,',
    '      highlightActiveLine, highlightActiveLineGutter, defaultKeymap, history,',
    '      historyKeymap, indentWithTab, StreamLanguage, bracketMatching, indentUnit,',
    '      syntaxHighlighting, defaultHighlightStyle, HighlightStyle, tags, groovy, oneDark }',
    '</script>',
].join('\n');

const options = {
    outputDir:   './plugin/grails-app/views/console/',
    relativeDir: './plugin/src/main/resources/public',
    webDir:      './plugin/src/main/resources/public/console/',
    faviconWrap: path => `<link rel="icon" type="image/png" href="\${resource(file: '${path}')}" />`,
    jsWrap:      path => `<script type="text/javascript" src="\${resource(file: '${path}')}" ></script>`,
    cssWrap:     path => `<link rel="stylesheet" media="screen" href="\${resource(file: '${path}')}" />`,
    webjarJsWrap:  webjar => `<script type="text/javascript" src="\${request.contextPath}/webjars/${webjar.name}/${webjarVersionExpression(webjar)}/${webjar.file}" ></script>`,
    webjarCssWrap: webjar => `<link rel="stylesheet" media="screen" href="\${request.contextPath}/webjars/${webjar.name}/${webjarVersionExpression(webjar)}/${webjar.file}" />`,
    moduleShim,
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
