export const timestamp = new Date().getTime();

// Assets served from the consuming app's webjar classpath rather than copied
// into the plugin's public resources. Every version is resolved from the runtime
// classpath at render time, since the consuming app's dependency management —
// the grails-bom platform manages all three — decides which one actually wins.
const webjars = {
    css: [
        { name: 'bootstrap', file: 'dist/css/bootstrap.min.css' },
        { name: 'bootstrap-icons', file: 'font/bootstrap-icons.min.css' },
    ],
    js: [
        // jQuery first: the console's bundle expects it as a global
        { name: 'jquery', file: 'dist/jquery.min.js' },
        { name: 'bootstrap', file: 'dist/js/bootstrap.bundle.min.js' },
    ],
};

// CodeMirror 6 ships ES modules with bare import specifiers and no browser
// global, so it cannot be loaded with a plain script tag. index.gsp emits an
// import map pinning each specifier to its /webjars/ URL, then a module shim
// that imports what the editor needs and hangs it on window.CM6 for the classic
// bundle. Module scripts are deferred but run before DOMContentLoaded, so CM6 is
// defined by the time App.start() fires on jQuery ready.
//
// Versions are resolved from the classpath at render time, so none are pinned
// here. The first six are declared in plugin/build.gradle; the rest arrive
// transitively and are listed because the import map must cover every bare
// specifier the graph resolves, not just the ones the shim names.
const moduleWebjars = [
    { specifier: '@codemirror/state',                     webjar: 'codemirror__state',           file: 'dist/index.js' },
    { specifier: '@codemirror/view',                      webjar: 'codemirror__view',            file: 'dist/index.js' },
    { specifier: '@codemirror/commands',                  webjar: 'codemirror__commands',        file: 'dist/index.js' },
    { specifier: '@codemirror/language',                  webjar: 'codemirror__language',        file: 'dist/index.js' },
    { specifier: '@codemirror/theme-one-dark',            webjar: 'codemirror__theme-one-dark',  file: 'dist/index.js' },
    { specifier: '@codemirror/legacy-modes/mode/groovy',  webjar: 'codemirror__legacy-modes',    file: 'mode/groovy.js' },
    { specifier: '@lezer/common',                         webjar: 'lezer__common',               file: 'dist/index.js' },
    { specifier: '@lezer/highlight',                      webjar: 'lezer__highlight',            file: 'dist/index.js' },
    { specifier: '@lezer/lr',                             webjar: 'lezer__lr',                   file: 'dist/index.js' },
    { specifier: '@marijn/find-cluster-break',            webjar: 'marijn__find-cluster-break',  file: 'src/index.js' },
    { specifier: 'style-mod',                             webjar: 'style-mod',                   file: 'src/style-mod.js' },
    { specifier: 'crelt',                                 webjar: 'crelt',                       file: 'index.js' },
    { specifier: 'w3c-keyname',                           webjar: 'w3c-keyname',                 file: 'index.js' },
];

const vendorCssAssets = [
];

const vendorJsAssets = [
    {
        src: './node_modules/underscore/underscore-min.js',
        publicPath: '/vendor/js/libs/underscore-min.js',
    },
    {
        src: './node_modules/backbone/backbone-min.js',
        publicPath: '/vendor/js/libs/backbone-min.js',
    },
    {
        src: './node_modules/backbone.radio/build/backbone.radio.min.js',
        publicPath: '/vendor/js/libs/backbone.radio.min.js',
    },
    {
        src: './node_modules/backbone.marionette/lib/backbone.marionette.min.js',
        publicPath: '/vendor/js/libs/backbone.marionette.min.js',
    },
    {
        src: './node_modules/handlebars/dist/handlebars.runtime.min.js',
        publicPath: '/vendor/js/libs/handlebars.runtime.min.js',
    },
];

export const paths = {
    favicon: 'img/grails.logo.png',

    app: {
        css: {
            debug: [
                '/css/**/*.css'
            ],
            release: [
                `/css/app.${timestamp}.css`
            ],
        },
        js: {
            debug: [
                '/js/templates.js', '/js/app/app.js', '/js/app/*/**/*.js'
            ],
            release: [
                `/js/app.${timestamp}.js`
            ],
        },
    },
    vendor: {
        css: vendorCssAssets.map(asset => asset.publicPath),
        js: vendorJsAssets.map(asset => asset.publicPath),
        cssAssets: vendorCssAssets,
        jsAssets: vendorJsAssets,
        webjars,
        moduleWebjars,
    },
    test: [
        './js/tests/**.js'
    ],
};
