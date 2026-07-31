<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Welcome to Grails</title>
</head>
<body>
<content tag="nav">
    <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Application Status <span class="caret"></span></a>
        <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="#">Environment: ${grails.util.Environment.current.name}</a></li>
            <li><a class="dropdown-item" href="#">App profile: ${grailsApplication.config.getProperty('grails.profile')}</a></li>
            <li><a class="dropdown-item" href="#">App version:
                <g:meta name="info.app.version"/></a>
            </li>
            <li role="separator" class="dropdown-divider"></li>
            <li><a class="dropdown-item" href="#">Grails version:
                <g:meta name="info.app.grailsVersion"/></a>
            </li>
            <li><a class="dropdown-item" href="#">Groovy version: ${GroovySystem.getVersion()}</a></li>
            <li><a class="dropdown-item" href="#">JVM version: ${System.getProperty('java.version')}</a></li>
            <li role="separator" class="dropdown-divider"></li>
            <li><a class="dropdown-item" href="#">Reloading active: ${grails.util.Environment.reloadingAgentEnabled}</a></li>
        </ul>
    </li>
    <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Artefacts <span class="caret"></span></a>
        <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="#">Controllers: ${grailsApplication.controllerClasses.size()}</a></li>
            <li><a class="dropdown-item" href="#">Domains: ${grailsApplication.domainClasses.size()}</a></li>
            <li><a class="dropdown-item" href="#">Services: ${grailsApplication.serviceClasses.size()}</a></li>
            <li><a class="dropdown-item" href="#">Tag Libraries: ${grailsApplication.tagLibClasses.size()}</a></li>
        </ul>
    </li>
    <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Installed Plugins <span class="caret"></span></a>
        <ul class="dropdown-menu dropdown-menu-right">
            <g:each var="plugin" in="${applicationContext.getBean('pluginManager').allPlugins}">
                <li><a class="dropdown-item" href="#">${plugin.name} - ${plugin.version}</a></li>
            </g:each>
        </ul>
    </li>
</content>

<div class="svg" role="presentation">
    <div class="grails-logo-container">
        <asset:image src="grails-cupsonly-logo-white.svg" class="grails-logo"/>
    </div>
</div>

<div id="content" role="main">
    <div class="container">
        <section class="row colset-2-its">
            <h1>Welcome to Grails</h1>

            <p>
                Congratulations, you have successfully started your first Grails application! At the moment
                this is the default page, feel free to modify it to either redirect to a controller or display
                whatever content you may choose. Below is a list of controllers that are currently deployed in
                this application, click on each to execute its default action:
            </p>

            <div id="controllers" role="navigation">
                <h2>Available Controllers:</h2>
                <ul>
                    <g:each var="c" in="${grailsApplication.controllerClasses.sort { it.fullName } }">
                        <li class="controller">
                            <g:link controller="${c.logicalPropertyName}">${c.fullName}</g:link>
                        </li>
                    </g:each>
                </ul>
            </div>
        </section>
    </div>
</div>

</body>
</html>
