<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title><g:message code="ltc.suggestion.thanks.title"/></title>
    <meta name="layout" content="main" />
</head>
<body>

<div class="body">

    <div class="dialog">

        <h1><g:message code="ltc.suggestion.thanks.head"/></h1>

        <p><g:message code="ltc.suggestion.thanks.text"/></p>

        <g:if test="${params.languageCode?.startsWith("de")}">
            <p>Hier ist die Liste
                <a href="https://github.com/languagetool-org/languagetool/blob/master/languagetool-language-modules/de/src/main/resources/org/languagetool/resource/de/hunspell/ignore.txt">aller bisher hinzugefügten Wörter</a>.
            </p>
        </g:if>

        <br/>
        <p><a href="https://languagetool.org"><g:message code="ltc.suggestion.thanks.link"/></a></p>
    
    </div>

</div>

</body>
</html>
