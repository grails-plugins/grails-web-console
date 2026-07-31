<%@ page import="grails.converters.JSON" %>
<%@ page scriptletCodec="none" %>
<!doctype html>
<html>

<head>
  <g:set var="webjarsEnabled" value="${grailsApplication.config.getProperty('grails.plugin.console.webjars.enabled', Boolean, true)}" />
  <title>Grails Debug Console</title>
  <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
  <g:render template="favicon" />
  <g:if test="${webjarsEnabled}"><g:render template="webjarsCss" /></g:if>
  <%-- Always rendered: the import map and module shim are how the console loads
       CodeMirror 6 at all, not a library a host application could already have.
       An app cannot substitute these with asset tags, so they sit outside the
       opt-out, and the codemirror webjars must not be excluded. --%>
  <g:render template="webjarsModules" />
  <g:render template="css" />
  
  <meta name="layout" content="${grailsApplication.config['grails.plugin.console.layout'] ?: 'console-plugin-layout'}"/>
</head>

<body style="visibility: hidden">

<div id="header"></div>
<div id="main-content-wrapper" class="full-height">
  <div id="main-content"></div>
  <div id="health-region" class="full-height d-none"></div>
</div>
<g:if test="${webjarsEnabled}"><g:render template="webjarsJs" /></g:if>
<g:render template="js" />

<script type="text/javascript" charset="utf-8">
  jQuery(function($){
    App.start(<%= json as JSON %>);
  });
</script>

</body>
</html>
