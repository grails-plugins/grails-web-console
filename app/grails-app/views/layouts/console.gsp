<!doctype html>
<html>
<head>
  <%-- Supplies the console's four replaceable libraries from this app's own
       asset-pipeline build, with grails.plugin.console.webjars.enabled = false
       and the matching exclusions in build.gradle. CodeMirror is not listed:
       it is ES-module-only and always comes from the plugin's import map.
       Ahead of <g:layoutHead/> so the console's stylesheets win the cascade and
       jQuery is defined before its bundle runs. --%>
  <asset:stylesheet href="webjars/bootstrap/%/dist/css/bootstrap.css"/>
  <asset:stylesheet href="webjars/bootstrap-icons/%/font/bootstrap-icons.css"/>
  <asset:stylesheet href="webjars/jquery-ui/%/dist/themes/base/jquery-ui.css"/>
  <asset:javascript src="webjars/jquery/%/dist/jquery.js"/>
  <asset:javascript src="webjars/jquery-ui/%/dist/jquery-ui.js"/>
  <asset:javascript src="webjars/bootstrap/%/dist/js/bootstrap.bundle.js"/>
  <g:layoutHead/>
</head>
<body>
<g:layoutBody/>
</body>
</html>
