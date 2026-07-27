package org.grails.plugins.console

import org.codehaus.groovy.ast.ClassHelper
import org.codehaus.groovy.ast.ClassNode
import org.codehaus.groovy.ast.ModuleNode
import org.codehaus.groovy.classgen.GeneratorContext
import org.codehaus.groovy.control.CompilePhase
import org.codehaus.groovy.control.SourceUnit
import org.codehaus.groovy.control.customizers.CompilationCustomizer

/**
 * Adds the domain class imports, skipping any name the script imports for itself.
 *
 * ImportCustomizer cannot be used for this: it adds its imports unconditionally, so a script that
 * imports a different class under a name the auto-import already claimed -- `import com.foo.User`
 * where com.bar.User holds the bare name -- fails to compile with "The name User is already
 * declared". That is precisely what a user reaches for when they want the candidate that did not win
 * the bare name, so it has to keep working.
 *
 * Importing the *same* class the auto-import chose is harmless either way; Groovy accepts an alias
 * pointing at the class it already points at.
 */
class DomainImportCustomizer extends CompilationCustomizer {

    private final Map<String, String> aliases

    DomainImportCustomizer(Map<String, String> aliases) {
        super(CompilePhase.CONVERSION)
        this.aliases = aliases
    }

    @Override
    void call(SourceUnit source, GeneratorContext context, ClassNode classNode) {
        ModuleNode module = source.AST
        if (!module) {
            return
        }

        // Recomputed per call rather than cached: this runs once per class in the module, and the
        // imports added by an earlier pass must count as declared on the next one.
        Set<String> declared = module.imports*.alias as Set

        aliases.each { String alias, String className ->
            if (!declared.contains(alias)) {
                module.addImport alias, ClassHelper.make(className)
            }
        }
    }
}
