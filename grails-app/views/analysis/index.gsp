<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title><g:message code="ltc.analysis.title"/></title>
        <meta name="layout" content="main" />
    </head>
    <body>

        <div class="body">

        <g:render template="/languageSelection"/>
            
        <div class="dialog">

            <h1><g:message code="ltc.analysis.head"/></h1>
            
            <p><g:message code="ltc.analysis.intro"/></p>
            
            <g:form style="margin-top: 8px" action="analyzeText" method="post">
                <g:hiddenField name="lang" value="${language.shortName}"/>
                <g:textArea name="text" rows="5" cols="70" maxlength="1000" autofocus="autofocus" value="${textToCheck}" />
                <br/>
                <g:submitButton name="submit" value="${message(code:'ltc.analysis.submit')}"/>
            </g:form>

        </div>

        </div>
        
    </body>
</html>