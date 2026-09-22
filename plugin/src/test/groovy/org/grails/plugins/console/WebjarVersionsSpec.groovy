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

    void 'a url carries the classpath version under the context path'() {
        when:
        String url = WebjarVersions.url('/app', 'bootstrap', 'dist/css/bootstrap.min.css')

        then:
        url == "/app/webjars/bootstrap/${WebjarVersions.version('bootstrap')}/dist/css/bootstrap.min.css"
    }

    void 'a missing webjar has no url, so the caller can leave the tag out'() {
        expect:
        WebjarVersions.url('/app', 'no-such-webjar', 'dist/index.js') == null
    }

    void 'a build-time version stands in when the classpath has none'() {
        expect:
        WebjarVersions.url('', 'no-such-webjar', 'dist/index.js', '6.7.4') ==
                '/webjars/no-such-webjar/6.7.4/dist/index.js'

        and: 'the classpath still wins where it answers'
        WebjarVersions.url('', 'bootstrap', 'dist/index.js', '1.0.0') ==
                "/webjars/bootstrap/${WebjarVersions.version('bootstrap')}/dist/index.js"
    }

    void 'the default base is the app context path'() {
        expect:
        WebjarVersions.baseUrl(contextPath) == expected

        where:
        contextPath || expected
        '/app'      || '/app/webjars'
        ''          || '/webjars'
        null        || '/webjars'
    }
}
