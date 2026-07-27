package org.grails.plugins.console

import groovy.transform.CompileStatic

import java.util.concurrent.ConcurrentHashMap

/**
 * Resolves the version of a webjar actually present on the runtime classpath.
 *
 * The consuming application's dependency management (typically the grails-bom
 * platform) decides which webjar version wins Gradle's conflict resolution, so
 * links generated at plugin build time cannot assume the version this plugin
 * requested. The GSP fragments call this to build /webjars/&lt;name&gt;/&lt;version&gt;/
 * URLs that match whatever jar is really on the classpath, falling back to the
 * plugin's build-time default only when the metadata cannot be found.
 */
@CompileStatic
class WebjarVersions {

    private static final Map<String, String> CACHE = new ConcurrentHashMap<>()
    private static final String NOT_FOUND = ''

    static String version(String webjarName) {
        String cached = CACHE.computeIfAbsent(webjarName) { String name ->
            resolve(name) ?: NOT_FOUND
        }
        cached == NOT_FOUND ? null : cached
    }

    private static String resolve(String name) {
        // every org.webjars.npm artifact ships Maven metadata inside the jar
        URL url = WebjarVersions.classLoader.getResource(
                "META-INF/maven/org.webjars.npm/${name}/pom.properties")
        if (url == null) {
            return null
        }
        Properties props = new Properties()
        url.openStream().withCloseable { InputStream stream -> props.load(stream) }
        props.getProperty('version')
    }
}
