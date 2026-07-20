package org.grails.plugins.console

import spock.lang.Specification

class WebjarVersionsSpec extends Specification {

    void 'resolves the classpath version of the bundled webjars'() {
        expect: 'the runtimeOnly webjars are visible on the test runtime classpath'
        WebjarVersions.version('bootstrap') ==~ /\d+\.\d+\.\d+.*/
        WebjarVersions.version('bootstrap-icons') ==~ /\d+\.\d+\.\d+.*/
    }

    void 'returns null for a webjar that is not on the classpath'() {
        expect:
        WebjarVersions.version('no-such-webjar') == null
    }
}
