
<%@ page import="org.languagetool.Language" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <script type="text/javascript" src="${resource(dir:'js/jquery',file:'jquery-1.7.1.js')}"></script>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.editor.title"/></title>
    </head>
    <body>

        <div class="body">

            <g:render template="/languageSelection"/>

            <p style="width:550px;margin:10px;text-align: right"><g:link action="expert"><g:message code="ltc.editor.advanced.mode"/></g:link></p>

            <h2>Please use <g:link controller="ruleEditor2">our new rule editor</g:link></h2>

        </div>
    </body>
</html>
