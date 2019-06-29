<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title><g:message code="ltc.suggestion.title"/></title>
    <meta name="layout" content="main" />
</head>
<body>

<div class="body">

    <div class="dialog">

        <h1><g:message code="ltc.suggestion.head"/></h1>

        <p style="margin-bottom: 8px"><g:message code="ltc.suggestion.intro"/></p>
    
        <g:form action="suggestWord" method="post">
            <g:hiddenField name="word" value="${params.word.encodeAsHTML()}"/>
            <g:hiddenField name="languageCode" value="${language.getShortCode().encodeAsHTML()}"/>
            <g:if test="${request.getHeader('referer') != null}">
                <g:hiddenField name="referer" value="${request.getHeader('referer')}"/>
            </g:if>

            <table>
                <tr>
                    <td style="width:80px"><g:message code="ltc.suggestion.language"/></td>
                    <td>${i18nLanguage.encodeAsHTML()}</td>
                </tr>
                <tr>
                    <td><g:message code="ltc.suggestion.word"/></td>
                    <td><span style="font-family: monospace; font-size: x-large">${params.word?.encodeAsHTML()}</span></td>
                </tr>
                <g:if test="${email}">
                    <tr>
                        <td style="padding-top: 8px"><g:message code="ltc.suggestion.email"/></td>
                        <td>
                            <g:textField size="50" autofocus="autofocus" name="email"/><br/>
                            <span class="metaInfo"><g:message code="ltc.suggestion.email.hint"/></span>
                        </td>
                    </tr>
                </g:if>
                <tr>
                    <td></td>
                    <td><a target="_blank" href="https://www.google.com/search?q=${URLEncoder.encode(params.word, 'UTF-8')}"><g:message code="ltc.suggestion.google"/></a></td>
                </tr>
                <tr>
                    <td></td>
                    <td><g:submitButton name="submit" value="${message(code:'ltc.suggestion.submit')}"/></td>
                </tr>
            </table>
            
        </g:form>

    </div>

</div>

</body>
</html>
