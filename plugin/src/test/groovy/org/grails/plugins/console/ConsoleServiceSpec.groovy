package org.grails.plugins.console

import grails.core.GrailsApplication
import grails.core.GrailsClass
import grails.testing.services.ServiceUnitTest
import org.grails.core.artefact.DomainClassArtefactHandler
import org.springframework.mock.web.MockHttpServletRequest
import spock.lang.Ignore
import spock.lang.Specification

class ConsoleServiceSpec extends Specification implements ServiceUnitTest<ConsoleService> {

    def request = new MockHttpServletRequest()

    void 'eval'() {
        given:
        String code = '''
			String s = "abc"
			println s.reverse()
        '''.trim()

        when:
        Evaluation result = service.eval(code, false, request)

        then:
        result.output.trim() == 'cba'
    }

    void 'eval with exception'() {
        given:
        String code = '''
			String s = null
			println s.reverse()
        '''.trim()

        when:
        Evaluation result = service.eval(code, false, request)

        then:
        result.exception.message.contains 'Cannot invoke method reverse() on null object'
    }

    void 'eval with config'() {
        given:
        grailsApplication.config.testing = 'test-val'
        String code = 'println config.testing'

        when:
        Evaluation result = service.eval(code, false, request)

        then:
        result.output.trim() == 'test-val'
    }

    void 'unambiguous domain classes are imported under their simple name'() {
        expect:
        ConsoleService.resolveImports([java.util.List, java.util.Map]).aliases == [
                List: 'java.util.List',
                Map : 'java.util.Map'
        ]
    }

    void 'domain classes that share a simple name are given package-qualified aliases'() {
        when:
        ConsoleService.DomainImports imports = ConsoleService.resolveImports([java.util.Date, java.sql.Date, java.util.List])

        then: 'the bare name is not imported -- neither candidate wins it'
        !imports.aliases.containsKey('Date')

        and: 'each candidate is reachable under a package-qualified alias'
        imports.aliases['UtilDate'] == 'java.util.Date'
        imports.aliases['SqlDate'] == 'java.sql.Date'

        and: 'the bare name is reported so the caller can explain itself'
        imports.unimported['Date'] == ['java.util.Date': 'UtilDate', 'java.sql.Date': 'SqlDate']

        and: 'unambiguous classes are unaffected'
        imports.aliases['List'] == 'java.util.List'
    }

    void 'the qualifier widens until the aliases are distinct'() {
        given: 'two classes sharing both a simple name and their innermost package'
        List<Class> classes = [cls('one.thing', 'Widget'), cls('two.thing', 'Widget')]

        when:
        Map<String, String> aliases = ConsoleService.resolveImports(classes).aliases

        then: 'one segment would collide on ThingWidget, so a second is added'
        aliases.keySet() == ['OneThingWidget', 'TwoThingWidget'] as Set
    }

    void 'a generated alias never shadows a real domain class name'() {
        given: 'a class already named SqlDate, plus an ambiguous Date'
        List<Class> classes = [java.util.Date, java.sql.Date, cls('other', 'SqlDate')]

        when:
        Map<String, String> aliases = ConsoleService.resolveImports(classes).aliases

        then: 'the real SqlDate keeps the name and java.sql.Date is qualified further'
        aliases['SqlDate'] == 'other.SqlDate'
        aliases['JavaSqlDate'] == 'java.sql.Date'
        aliases['JavaUtilDate'] == 'java.util.Date'
    }

    void 'a class that cannot be aliased costs only itself, not its whole group'() {
        given: 'a default-package class, which has no segments to qualify with'
        List<Class> classes = [cls(null, 'Gadget'), cls('com.plugin', 'Gadget')]

        when:
        ConsoleService.DomainImports imports = ConsoleService.resolveImports(classes)

        then: 'the class that can be qualified still gets its alias'
        imports.aliases['PluginGadget'] == 'com.plugin.Gadget'

        and: 'the one that cannot is simply absent -- previously the whole group was dropped'
        imports.aliases.values().every { it != 'Gadget' }

        and: 'but it is still named as a candidate, since the message has to account for it'
        imports.unimported['Gadget'] == ['Gadget': null, 'com.plugin.Gadget': 'PluginGadget']
    }

    void 'the ambiguity message names candidates that could not be aliased'() {
        given: 'two User classes whose only possible aliases are both taken by real domain classes'
        service.grailsApplication = stubApplication(
                cls('a', 'User'), cls('b', 'User'), cls('com.app', 'AUser'), cls('com.app', 'BUser'))

        when: 'a script uses the ambiguous bare name'
        Evaluation result = service.eval('User.count()', true, request)

        then: 'it still reports the ambiguity'
        result.exception.message.contains 'User is ambiguous'

        and: 'and names both candidates -- neither has an alias, so the message was previously empty'
        result.exception.message.contains 'a.User'
        result.exception.message.contains 'b.User'
    }

    void 'eval compiles with auto-import when domain classes share a simple name'() {
        given: 'an app whose domain classes collide on simple name, as multi-plugin apps do'
        service.grailsApplication = stubApplication(java.util.Date, java.sql.Date)

        when: 'any script at all is evaluated with auto-import on'
        Evaluation result = service.eval('"hello"', true, request)

        then: 'it compiles -- previously this failed with "The name Date is already declared"'
        result.exception == null
        result.result == 'hello'
    }

    void 'an ambiguous bare name reports its alternatives instead of failing anonymously'() {
        given: 'two plugins contributing a Topic, so the bare name is not imported'
        service.grailsApplication = stubApplication(
                pluginClass('com.community', 'Topic'), pluginClass('com.knowledge', 'Topic'))

        when: 'a script uses the ambiguous bare name'
        Evaluation result = service.eval('Topic.count()', true, request)

        then: 'the failure names both candidates and the aliases they were imported under'
        result.exception.message.contains 'Topic is ambiguous'
        result.exception.message.contains 'com.community.Topic (as CommunityTopic)'
        result.exception.message.contains 'com.knowledge.Topic (as KnowledgeTopic)'
    }

    void 'a qualified alias resolves to the right class at runtime'() {
        given:
        service.grailsApplication = stubApplication(
                pluginClass('com.community', 'Topic'), pluginClass('com.knowledge', 'Topic'))

        when:
        Evaluation result = service.eval('CommunityTopic.name', true, request)

        then:
        result.exception == null
        result.result == 'com.community.Topic'
    }

    void 'the bare name goes to the application class, per Grails precedence'() {
        given: 'a plugin User and the application own User'
        Class pluginUser = pluginClass('com.plugin', 'User')
        Class appUser = cls('com.app', 'User')

        when:
        ConsoleService.DomainImports imports = ConsoleService.resolveImports([pluginUser, appUser])

        then: 'the application class wins the bare name, as it would for views or beans'
        imports.aliases['User'] == 'com.app.User'

        and: 'both remain reachable under a qualified alias, and nothing is left unexplained'
        imports.aliases['AppUser'] == 'com.app.User'
        imports.aliases['PluginUser'] == 'com.plugin.User'
        imports.unimported.isEmpty()
    }

    void 'the bare name is not imported when every candidate is plugin-provided'() {
        given: 'two plugins each contributing a Topic, with no application class to prefer'
        List<Class> classes = [pluginClass('com.community', 'Topic'), pluginClass('com.knowledge', 'Topic')]

        when:
        ConsoleService.DomainImports imports = ConsoleService.resolveImports(classes)

        then: 'there is no principled winner, so the bare name stays out'
        !imports.aliases.containsKey('Topic')
        imports.unimported.containsKey('Topic')

        and:
        imports.aliases['CommunityTopic'] == 'com.community.Topic'
        imports.aliases['KnowledgeTopic'] == 'com.knowledge.Topic'
    }

    void 'the bare name is not imported when several candidates are application classes'() {
        given: 'two application classes sharing a simple name'
        List<Class> classes = [cls('com.app.one', 'Thing'), cls('com.app.two', 'Thing')]

        when:
        ConsoleService.DomainImports imports = ConsoleService.resolveImports(classes)

        then: 'preferring either would be arbitrary'
        !imports.aliases.containsKey('Thing')
        imports.aliases.keySet() == ['OneThing', 'TwoThing'] as Set
    }

    void 'a script may import a candidate that did not win the bare name'() {
        given: 'the application Topic holds the bare name'
        service.grailsApplication = stubApplication(pluginClass('com.community', 'Topic'), cls('com.app', 'Topic'))

        when: 'the script imports the plugin one instead -- the natural way to reach it'
        Evaluation result = service.eval('import com.community.Topic\nTopic.name', true, request)

        then: 'the script own import wins; it used to fail with "The name Topic is already declared"'
        result.exception == null
        result.result == 'com.community.Topic'
    }

    void 'a script may re-import a class that was auto-imported anyway'() {
        given:
        service.grailsApplication = stubApplication(cls('com.app', 'Gadget'))

        when:
        Evaluation result = service.eval('import com.app.Gadget\nGadget.name', true, request)

        then:
        result.exception == null
        result.result == 'com.app.Gadget'
    }

    void 'a script may import a name that was left unimported as ambiguous'() {
        given: 'two plugin Topics, so the bare name carries the placeholder'
        service.grailsApplication = stubApplication(
                pluginClass('com.community', 'Topic'), pluginClass('com.knowledge', 'Topic'))

        when:
        Evaluation result = service.eval('import com.knowledge.Topic\nTopic.name', true, request)

        then: 'the class import shadows the placeholder at compile time'
        result.exception == null
        result.result == 'com.knowledge.Topic'
    }

    void 'auto-imported names still work alongside a script own import'() {
        given:
        service.grailsApplication = stubApplication(cls('com.app', 'Gadget'), cls('com.app', 'Widget'))

        when: 'the script imports one of them explicitly'
        Evaluation result = service.eval('import com.app.Gadget\nGadget.name + " " + Widget.name', true, request)

        then: 'the other is still auto-imported'
        result.exception == null
        result.result == 'com.app.Gadget com.app.Widget'
    }

    private GrailsApplication stubApplication(Class... domainClasses) {
        Stub(GrailsApplication) {
            getArtefacts(DomainClassArtefactHandler.TYPE) >> (domainClasses.collect { Class domain ->
                Stub(GrailsClass) { getClazz() >> domain }
            } as GrailsClass[])
            getClassLoader() >> TEST_LOADER
            getMainContext() >> null
            getConfig() >> grailsApplication.config
        }
    }

    private static final GroovyClassLoader TEST_LOADER = new GroovyClassLoader()

    private static Class cls(String packageName, String name) {
        TEST_LOADER.parseClass(packageName ? "package $packageName; class $name {}" : "class $name {}")
    }

    /** A class carrying the @GrailsPlugin stamp the Grails compiler adds to plugin artefacts. */
    private static Class pluginClass(String packageName, String name) {
        TEST_LOADER.parseClass(
                "package $packageName\n" +
                "@grails.plugins.metadata.GrailsPlugin(name = 'somePlugin', version = '1.0')\n" +
                "class $name {}")
    }
}
