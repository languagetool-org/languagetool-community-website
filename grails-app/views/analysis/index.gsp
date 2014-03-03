<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title><g:message code="ltc.analysis.title"/></title>
        <meta name="layout" content="main" />
        <g:render template="script"/>
    </head>
    <body>

        <div class="body">

        <g:render template="/languageSelection"/>
            
        <div class="dialog">

            <h1><g:message code="ltc.analysis.head"/></h1>
            
            <p><g:message code="ltc.analysis.intro"/></p>

            <g:render template="textForm"/>
            
        </div>

        </div>
        
    </body>
</html>