export const timestamp = new Date().getTime();

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
        base: './web',
        css: [
            '/vendor/bootstrap/css/bootstrap.min.css',
            '/vendor/font-awesome-4.7.0/css/font-awesome.css',
            '/vendor/codemirror-5.65.18/lib/codemirror.css',
            '/vendor/codemirror-5.65.18/theme/lesser-dark.css',
            '/vendor/jquery-layout/css/jquery.layout.css',
            '/vendor/jquery-ui-1.14.1/jquery-ui.min.css',
        ],
        js: [
            '/vendor/js/libs/jquery.min.js',
            '/vendor/js/libs/jquery-migrate.min.js',
            '/vendor/jquery-ui-1.14.1/jquery-ui.min.js',
            '/vendor/bootstrap/js/bootstrap.min.js',
            '/vendor/js/libs/underscore-min.js',
            '/vendor/js/libs/backbone-min.js',
            '/vendor/js/libs/backbone.radio.min.js',
            '/vendor/js/libs/backbone.marionette.min.js',
            '/vendor/js/libs/handlebars.runtime.min.js',
            '/vendor/js/plugins/jquery.selector-polyfill.js',
            '/vendor/jquery-layout/js/jquery.layout-latest.min.js',
            '/vendor/js/plugins/jquery.hotkeys.js',
            '/vendor/codemirror-5.65.18/lib/codemirror.js',
            '/vendor/codemirror-5.65.18/mode/groovy/groovy.js',
        ],
    },
    test: [
        './js/tests/**.js'
    ],
};
