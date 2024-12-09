package org.grails.plugins.console

import grails.plugins.*

class WebConsoleGrailsPlugin extends Plugin {

    // the version or versions of Grails the plugin is designed for
    def grailsVersion = "7.0.0-SNAPSHOT > *"

    // resources that are excluded from plugin packaging
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]

    String title = 'Web Console Plugin'
    def author = "Your name"
    def authorEmail = ""
    String description = 'A web-based Groovy console for interactive runtime application management and debugging'

    def profiles = ['web']

    // URL to the plugin's documentation
    String documentation = 'https://github.com/grails-plugins/grails-web-console/blob/6.0.x/README.md'

    String license = 'APACHE'
    def developers = [
            [name: 'Siegfried Puchbauer', email: 'siegfried.puchbauer@gmail.com'],
            [name: 'Mingfai Ma', email: 'mingfai.ma@gmail.com'],
            [name: 'Burt Beckwith', email: 'burt@burtbeckwith.com'],
            [name: 'Matt Sheehan', email: 'mr.sheehan@gmail.com'],
            [name: 'Sachin Verma', email: 'v.sachin.v@gmail.com']
    ]
    def issueManagement = [system: 'github', url: 'https://github.com/grails-plugins/grails-web-console/issues']
    def scm = [url: 'https://github.com/grails-plugins/grails-web-console']


    Closure doWithSpring() {
        {->
            consoleConfig(ConsoleConfig, config, 'grails.plugin.console')
        }
    }

    void doWithDynamicMethods() {
        // TODO Implement registering dynamic methods to classes (optional)
    }

    void doWithApplicationContext() {
        config.merge(['config.grails.assets.plugin.console.excludes': ['**/*']])

        ConsoleUtil.initJsonConfig()
    }

    void onChange(Map<String, Object> event) {
        // TODO Implement code that is executed when any artefact that this plugin is
        // watching is modified and reloaded. The event contains: event.source,
        // event.application, event.manager, event.ctx, and event.plugin.
    }

    void onConfigChange(Map<String, Object> event) {
        // TODO Implement code that is executed when the project configuration changes.
        // The event is the same as for 'onChange'.
    }

    void onShutdown(Map<String, Object> event) {
        // TODO Implement code that is executed when the application shuts down (optional)
    }
}
