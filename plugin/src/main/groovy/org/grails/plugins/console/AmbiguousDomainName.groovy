package org.grails.plugins.console

/**
 * Bound into the script's binding under a domain class simple name that more than one domain class
 * claims and that no single application class wins outright.
 *
 * Such a name cannot be auto-imported: two `import ... as User` entries are a compile error, and
 * picking one of the candidates silently would let a script reach the wrong entity. Leaving it
 * unbound is safe but unhelpful -- the script fails with a bare "No such property: User", which says
 * nothing about the alternatives. Binding this placeholder instead turns that dead end into a
 * message naming every candidate, with the alias each was imported under where one could be
 * generated. A candidate with no alias is still named: it is reachable by its full name, and that
 * name is what the message exists to supply.
 *
 * A script that resolves the name itself -- `import com.foo.User` at the top, or a local variable --
 * is unaffected: those bind at compile time and never consult the script binding.
 */
class AmbiguousDomainName extends GroovyObjectSupport {

    private final String name

    /** Fully qualified class name -> the alias it was imported under, or null if it has none. */
    private final Map<String, String> candidates

    AmbiguousDomainName(String name, Map<String, String> candidates) {
        this.name = name
        this.candidates = candidates
    }

    @Override
    Object getProperty(String property) {
        // Let Groovy's own plumbing through; anything else is the script touching the name.
        property in ['metaClass', 'class'] ? super.getProperty(property) : { throw ambiguous() }()
    }

    @Override
    void setProperty(String property, Object newValue) {
        throw ambiguous()
    }

    @Override
    Object invokeMethod(String method, Object args) {
        throw ambiguous()
    }

    @Override
    String toString() {
        message()
    }

    private GroovyRuntimeException ambiguous() {
        new GroovyRuntimeException(message())
    }

    private String message() {
        String options = candidates.collect { String className, String alias ->
            alias ? "$className (as $alias)" : className
        }.join(', ')
        "$name is ambiguous: more than one domain class is named $name, so it was not imported. " +
                "Use one of $options, or the fully qualified class name."
    }
}
