package org.grails.plugins.console

import spock.lang.Specification

import java.util.regex.Pattern

/**
 * The CodeMirror webjars' POMs declare version ranges, so a build takes whatever was released last. One bare
 * import missing from the map makes the browser refuse the editor's whole module, and the console is a blank page.
 */
class ImportMapSpec extends Specification {

    private static final Pattern IMPORT = ~/(?m)^\s*(?:import|export)\b[^'";]*?\bfrom\s*['"]([^'"]+)['"]|^\s*import\s*['"]([^'"]+)['"]/

    private final Map<String, String> entries = new File('../gulp-tasks/paths.js').text
            .findAll(/specifier:\s*'([^']+)',\s*webjar:\s*'([^']+)',\s*file:\s*'([^']+)'/) { List<String> entry ->
                [entry[1], "META-INF/resources/webjars/${entry[2]}/${WebjarVersions.version(entry[2])}/${entry[3]}".toString()]
            }.collectEntries()

    void 'every entry names a file on the classpath'() {
        expect:
        entries.size() > 10
        entries.findAll { String specifier, String path -> !resource(path) } == [:]
    }

    void 'every bare specifier the modules import is in the map'() {
        expect:
        bareImports().findAll { String specifier, String importedBy -> !entries.containsKey(specifier) } == [:]
    }

    /** Each bare specifier reachable from the map's entries, with a file that imports it. */
    private Map<String, String> bareImports() {
        Map<String, String> bare = [:]
        Set<String> seen = [] as Set
        List<String> pending = entries.values().toList()
        while (pending) {
            String path = pending.pop()
            if (!seen.add(path)) continue
            resource(path).text.findAll(IMPORT) { List<String> match ->
                String specifier = match[1] ?: match[2]
                if (specifier.startsWith('.')) pending << new URI(path).resolve(specifier).toString()
                else bare[specifier] = path
            }
        }
        bare
    }

    private URL resource(String path) {
        getClass().classLoader.getResource(path)
    }
}
