package org.grails.plugins.console

import grails.artefact.Interceptor
import grails.util.Environment

class EnabledInterceptor implements Interceptor {

    def consoleConfig

    EnabledInterceptor() {
        match(controller: 'console')
    }

    boolean before() {
        def enabled = consoleConfig.enabled
        if (!(enabled instanceof Boolean)) {
            enabled = Environment.current == Environment.DEVELOPMENT
        }
        enabled
    }

    boolean after() { true }

    void afterView() {
        // no-op
    }
}
