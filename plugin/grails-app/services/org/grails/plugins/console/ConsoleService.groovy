package org.grails.plugins.console

import groovy.util.logging.Slf4j
import org.codehaus.groovy.control.CompilerConfiguration
import grails.core.GrailsApplication
import org.grails.core.artefact.DomainClassArtefactHandler

import java.nio.charset.StandardCharsets

@Slf4j
class ConsoleService {

    GrailsApplication grailsApplication

    private Set<String> cachedDomainClassNames
    private DomainImports cachedDomainImports

    /**
     * @param code Groovy code to execute
     * @param autoImportDomains if <code>true</code>, adds imports for each domain class
     * @return an Evaluation
     */
    Evaluation eval(String code, boolean autoImportDomains, request) {
        log.trace "eval() code: $code"

        ByteArrayOutputStream baos = new ByteArrayOutputStream()
        PrintStream out = new PrintStream(baos)

        Evaluation evaluation = new Evaluation()

        Console console = new Console()

        long startTime = System.currentTimeMillis()
        try {
            DomainImports imports = autoImportDomains ? domainImports() : new DomainImports()
            Binding binding = createBinding(request, out, console, imports)
            CompilerConfiguration configuration = createConfiguration(imports)

            GroovyShell groovyShell = new GroovyShell(grailsApplication.classLoader, binding, configuration)
            evaluation.result = groovyShell.evaluate code
        } catch (Throwable t) {
            evaluation.exception = t
        }

        evaluation.totalTime = System.currentTimeMillis() - startTime

        evaluation.console = console
        evaluation.output = baos.toString(StandardCharsets.UTF_8.name())
        evaluation
    }

    private Binding createBinding(request, PrintStream out, Console console, DomainImports imports) {
        Binding binding = new Binding([
                session          : request.session,
                request          : request,
                ctx              : grailsApplication.mainContext,
                grailsApplication: grailsApplication,
                config           : grailsApplication.config,
                out              : out,
                console          : console
        ])
        imports.unimported.each { String simpleName, Map<String, String> candidates ->
            binding.setVariable simpleName, new AmbiguousDomainName(simpleName, candidates)
        }
        binding
    }

    private static CompilerConfiguration createConfiguration(DomainImports imports) {
        CompilerConfiguration configuration = new CompilerConfiguration()
        if (imports.aliases) {
            configuration.addCompilationCustomizers new DomainImportCustomizer(imports.aliases)
        }
        configuration
    }

    /**
     * Domain imports for the current set of domain classes, computed once per set. Grails can add or
     * drop artefacts on reload, so the cache is keyed on the class names rather than assumed stable;
     * recomputing only when that set changes also keeps the ambiguity logging to once per change
     * instead of once per script.
     */
    private synchronized DomainImports domainImports() {
        Collection<Class> domainClasses = grailsApplication.getArtefacts(DomainClassArtefactHandler.TYPE)*.clazz
        Set<String> names = domainClasses*.name as Set
        if (names != cachedDomainClassNames) {
            cachedDomainImports = resolveImports(domainClasses)
            cachedDomainClassNames = names
        }
        cachedDomainImports
    }

    /**
     * Works out how each domain class should be reachable from a script.
     *
     * A domain class whose simple name is unique is imported under that simple name, as always.
     *
     * When several domain classes share a simple name -- e.g. com.foo.User and com.bar.User, which
     * is common as soon as an app has a couple of plugins -- they cannot all be imported as `User`.
     * Groovy rejects the duplicate alias with "The name User is already declared", and because the
     * imports are part of the compiler configuration this failed *every* script in such an app,
     * whatever it contained.
     *
     * Ambiguous classes are instead imported under a package-qualified alias built from the fewest
     * trailing package segments that tell them apart: com.foo.User and com.bar.User become FooUser
     * and BarUser.
     *
     * The bare name additionally follows the usual Grails precedence rule -- an application's own
     * artefact overrides a plugin's -- but only when that yields a single unambiguous winner: if
     * exactly one candidate belongs to the application, it keeps the bare name. When every candidate
     * comes from a plugin (two plugins each contributing a Topic, say) there is no principled winner,
     * so the bare name is not imported at all rather than silently binding to whichever plugin
     * happened to load first. This is a console with write access, and quietly resolving to the
     * wrong entity can mean updating the wrong collection. Those names are reported in
     * {@link DomainImports#unimported} so the caller can bind an {@link AmbiguousDomainName} and give
     * the script a message naming the alternatives.
     *
     * Note that artefact registration order cannot stand in for that precedence: plugin domain
     * classes are registered before the application's own, so "first registered" is very nearly the
     * opposite of the intended rule.
     */
    protected static DomainImports resolveImports(Collection<Class> domainClasses) {
        Map<String, List<Class>> bySimpleName = domainClasses.groupBy { it.simpleName }

        // Every simple name is reserved, including the ambiguous ones that end up unimported: a
        // generated alias must never collide with some other domain class's own name.
        Set<String> taken = new HashSet<String>(bySimpleName.keySet())
        DomainImports imports = new DomainImports()

        bySimpleName.each { String simpleName, List<Class> classes ->
            if (classes.size() == 1) {
                imports.aliases[simpleName] = classes[0].name
                return
            }

            Map<String, String> qualified = qualifiedAliases(simpleName, classes, taken)
            imports.aliases.putAll qualified
            taken.addAll qualified.keySet()

            List<Class> fromApplication = classes.findAll { !pluginProvided(it) }
            if (fromApplication.size() == 1) {
                imports.aliases[simpleName] = fromApplication[0].name
                log.debug 'auto-import: {} is ambiguous ({}); the application class {} keeps the bare name, others imported as {}',
                        simpleName, classes*.name, fromApplication[0].name, qualified.keySet()
            } else {
                imports.unimported[simpleName] = candidatesOf(classes, qualified)
                log.debug 'auto-import: {} is ambiguous ({}) with no application class to prefer; imported as {}',
                        simpleName, classes*.name, qualified.keySet()
            }

            if (qualified.size() < classes.size()) {
                log.warn 'auto-import: {} of the {} domain classes named {} could not be given a distinct alias; refer to those by their full names',
                        classes.size() - qualified.size(), classes.size(), simpleName
            }
        }

        imports
    }

    /**
     * Whether a class was contributed by a plugin rather than the application itself.
     *
     * Grails stamps @GrailsPlugin onto plugin artefacts at compile time; application classes carry
     * no such annotation. The annotation is read directly rather than through
     * GrailsPluginManager.getPluginForClass(), because that method also resolves the stamped name
     * against the registered plugins and returns null when the two disagree -- a plugin whose
     * stamped name differs from its descriptor name is then indistinguishable from an application
     * class, which is exactly the distinction being drawn here.
     *
     * The stamp is applied by a Groovy AST transform during the plugin's own build, so a plugin
     * artefact that was not built that way -- a plain Java domain class, say -- reads as an
     * application class. That only matters when such a class is the *sole* unstamped candidate for a
     * name: every other candidate is then positively stamped, so the outcome is one deterministic
     * plugin class rather than a load-order-dependent one.
     */
    private static boolean pluginProvided(Class clazz) {
        clazz.getAnnotation(grails.plugins.metadata.GrailsPlugin) != null
    }

    /**
     * Aliases for one group of same-named classes. Widens from one trailing package segment outwards
     * -- CommunityTopic, then PixotoCommunityTopic, and so on -- and returns as soon as every class
     * in the group has a distinct, unclaimed alias. If no depth manages that, the best partial result
     * is returned: a class that cannot be given a distinct alias costs only itself, not the whole
     * group.
     */
    private static Map<String, String> qualifiedAliases(String simpleName, List<Class> classes, Set<String> taken) {
        List<List<String>> segments = classes.collect { packageSegments(it) }
        Map<String, String> best = [:]

        for (int depth = 1; depth <= (segments*.size().max() ?: 0); depth++) {
            List<String> candidates = segments.collect { qualifier(it, depth) + simpleName }

            Map<String, String> usable = [:]
            candidates.eachWithIndex { String alias, int i ->
                if (candidates.count(alias) == 1 && !taken.contains(alias)) {
                    usable[alias] = classes[i].name
                }
            }

            if (usable.size() == classes.size()) {
                return usable
            }
            if (usable.size() > best.size()) {
                best = usable
            }
        }

        best
    }

    /**
     * Every candidate for an ambiguous name, mapped to the alias it was imported under -- or to null
     * where {@link #qualifiedAliases} could not generate one. The unaliased candidates have to be
     * carried too: the ambiguity message is the only place a script is told they exist, and telling
     * someone to fall back to the fully qualified name while withholding that name is no help.
     */
    private static Map<String, String> candidatesOf(List<Class> classes, Map<String, String> qualified) {
        Map<String, String> aliasByClassName = qualified.collectEntries { String alias, String className ->
            [(className): alias]
        }
        classes.collectEntries { Class clazz -> [(clazz.name): aliasByClassName[clazz.name]] }
    }

    private static String qualifier(List<String> segments, int depth) {
        segments.takeRight(Math.min(depth, segments.size()))*.capitalize().join()
    }

    private static List<String> packageSegments(Class clazz) {
        int lastDot = clazz.name.lastIndexOf('.')
        lastDot < 0 ? [] : clazz.name.substring(0, lastDot).tokenize('.')
    }

    /** How the domain classes are reachable from a script. */
    protected static class DomainImports {

        /** Import alias -> fully qualified class name. */
        Map<String, String> aliases = [:]

        /**
         * Simple names that stayed unimported because several domain classes claim them, mapped to
         * every candidate for the name: fully qualified class name -> the alias it was imported
         * under, or null where none could be generated.
         */
        Map<String, Map<String, String>> unimported = [:]
    }
}
