export const timestamp = new Date().getTime();

const vendorCssAssets = [
    {
        src: './node_modules/bootstrap/dist/css/bootstrap.min.css',
        publicPath: '/vendor/bootstrap/css/bootstrap.min.css',
    },
    {
        src: './web/vendor/font-awesome-4.7.0/css/font-awesome.css',
        publicPath: '/vendor/font-awesome-4.7.0/css/font-awesome.css',
    },
    {
        src: './web/vendor/codemirror-5.65.18/lib/codemirror.css',
        publicPath: '/vendor/codemirror-5.65.18/lib/codemirror.css',
    },
    {
        src: './web/vendor/codemirror-5.65.18/theme/lesser-dark.css',
        publicPath: '/vendor/codemirror-5.65.18/theme/lesser-dark.css',
    },
    {
        src: './web/vendor/jquery-layout/css/jquery.layout.css',
        publicPath: '/vendor/jquery-layout/css/jquery.layout.css',
    },
    {
        src: './web/vendor/jquery-ui-1.14.1/jquery-ui.min.css',
        publicPath: '/vendor/jquery-ui-1.14.1/jquery-ui.min.css',
    },
];

const vendorJsAssets = [
    {
        src: './web/vendor/js/libs/jquery.min.js',
        publicPath: '/vendor/js/libs/jquery.min.js',
    },
    {
        src: './web/vendor/js/libs/jquery-migrate.min.js',
        publicPath: '/vendor/js/libs/jquery-migrate.min.js',
    },
    {
        src: './web/vendor/jquery-ui-1.14.1/jquery-ui.min.js',
        publicPath: '/vendor/jquery-ui-1.14.1/jquery-ui.min.js',
    },
    {
        src: './node_modules/bootstrap/dist/js/bootstrap.bundle.min.js',
        publicPath: '/vendor/bootstrap/js/bootstrap.bundle.min.js',
    },
    {
        src: './web/vendor/js/libs/underscore-min.js',
        publicPath: '/vendor/js/libs/underscore-min.js',
    },
    {
        src: './web/vendor/js/libs/backbone-min.js',
        publicPath: '/vendor/js/libs/backbone-min.js',
    },
    {
        src: './web/vendor/js/libs/backbone.radio.min.js',
        publicPath: '/vendor/js/libs/backbone.radio.min.js',
    },
    {
        src: './web/vendor/js/libs/backbone.marionette.min.js',
        publicPath: '/vendor/js/libs/backbone.marionette.min.js',
    },
    {
        src: './web/vendor/js/libs/handlebars.runtime.min.js',
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
        src: './web/vendor/codemirror-5.65.18/lib/codemirror.js',
        publicPath: '/vendor/codemirror-5.65.18/lib/codemirror.js',
    },
    {
        src: './web/vendor/codemirror-5.65.18/mode/groovy/groovy.js',
        publicPath: '/vendor/codemirror-5.65.18/mode/groovy/groovy.js',
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
    },
    test: [
        './js/tests/**.js'
    ],
};
