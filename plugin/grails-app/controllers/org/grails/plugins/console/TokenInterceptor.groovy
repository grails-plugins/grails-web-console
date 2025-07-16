package org.grails.plugins.console

import grails.artefact.Interceptor
import org.springframework.beans.factory.annotation.Value

class TokenInterceptor implements Interceptor {

    @Value('${grails.plugin.console.csrfProtectionEnabled:true}')
    boolean csrfProtectionEnabled

    TokenInterceptor() {
        match(controller: 'console').excludes(action: 'index')
    }

    boolean before() {
        if (actionName
                && csrfProtectionEnabled
                && (!session['CONSOLE_CSRF_TOKEN'] || request.getHeader('X-CSRFToken') != session['CONSOLE_CSRF_TOKEN'])) {
            response.status = 403
            response.writer.println "CSRF token doesn't match. Please refresh the page."
            return false
        }
        true
    }

    boolean after() { true }

    void afterView() {}
}
