import fs from 'node:fs';

export const timestamp = new Date().getTime();

// Webjar versions are defined once in gradle.properties: the plugin declares the
// matching org.webjars.npm dependencies, and the build below writes /webjars/...
// links for them into the GSP fragments.
const gradleProperties = Object.fromEntries(
    fs.readFileSync('./gradle.properties', 'utf8')
        .split('\n')
        .filter(line => line.includes('=') && !line.trim().startsWith('#'))
        .map(line => line.split('=', 2).map(part => part.trim()))
);

const bootstrapVersion = gradleProperties.bootstrapVersion;
const bootstrapIconsVersion = gradleProperties.bootstrapIconsVersion;

// Assets served from the consuming app's webjar classpath rather than copied
// into the plugin's public resources. The generated GSP resolves the version
// present on the runtime classpath (the app's dependency management may pick a
// different one than this plugin requested); defaultVersion is only a fallback.
const webjars = {
    css: [
        { name: 'bootstrap', file: 'dist/css/bootstrap.min.css', defaultVersion: bootstrapVersion },
        { name: 'bootstrap-icons', file: 'font/bootstrap-icons.min.css', defaultVersion: bootstrapIconsVersion },
    ],
    js: [
        // jQuery first: the console's bundle expects it as a global. No
        // defaultVersion — the Grails BOM manages this one, so there is no
        // build-time version here to fall back to.
        { name: 'jquery', file: 'dist/jquery.min.js' },
        { name: 'bootstrap', file: 'dist/js/bootstrap.bundle.min.js', defaultVersion: bootstrapVersion },
    ],
};

const vendorCssAssets = [
    {
        src: './node_modules/codemirror/lib/codemirror.css',
        publicPath: '/vendor/codemirror/lib/codemirror.css',
    },
    {
        src: './node_modules/codemirror/theme/lesser-dark.css',
        publicPath: '/vendor/codemirror/theme/lesser-dark.css',
    },
    {
        src: './web/vendor/jquery-layout/css/jquery.layout.css',
        publicPath: '/vendor/jquery-layout/css/jquery.layout.css',
    },
    {
        src: './node_modules/jquery-ui/dist/themes/base/jquery-ui.min.css',
        publicPath: '/vendor/jquery-ui/jquery-ui.min.css',
    },
];

// Copied alongside the vendor css/js but never linked from the GSP fragments
// (referenced relatively from the css they belong to)
const vendorStaticAssets = [
    {
        src: './node_modules/jquery-ui/dist/themes/base/images/*',
        publicPath: '/vendor/jquery-ui/images/*',
    },
];

const vendorJsAssets = [
    {
        src: './node_modules/jquery-ui/dist/jquery-ui.min.js',
        publicPath: '/vendor/jquery-ui/jquery-ui.min.js',
    },
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
    {
        src: './web/vendor/js/plugins/jquery.selector-polyfill.js',
        publicPath: '/vendor/js/plugins/jquery.selector-polyfill.js',
    },
    {
        src: './web/vendor/jquery-layout/js/jquery.layout-latest.min.js',
        publicPath: '/vendor/jquery-layout/js/jquery.layout-latest.min.js',
    },
    {
        src: './web/vendor/js/plugins/jquery.hotkeys.js',
        publicPath: '/vendor/js/plugins/jquery.hotkeys.js',
    },
    {
        src: './node_modules/codemirror/lib/codemirror.js',
        publicPath: '/vendor/codemirror/lib/codemirror.js',
    },
    {
        src: './node_modules/codemirror/mode/groovy/groovy.js',
        publicPath: '/vendor/codemirror/mode/groovy/groovy.js',
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
        staticAssets: vendorStaticAssets,
        webjars,
    },
    test: [
        './js/tests/**.js'
    ],
};
