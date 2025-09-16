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
        // Skip console's CSRF validation if Spring Security CSRF is handling it
        def springCsrfToken = request.getAttribute('org.springframework.security.web.csrf.CsrfToken')

        if (actionName
                && csrfProtectionEnabled
                && !springCsrfToken  // Only validate console token if Spring Security CSRF is not present
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
