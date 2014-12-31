<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <g:if test="${matches}">
            <g:set var="title" value="${message(code:'ltc.home.check.title')}"/>
        </g:if>
        <g:else>
            <g:set var="title" value="${message(code:'ltc.home.check.fallback.title')}"/>
        </g:else>
        <title>${title}</title>
        <meta name="layout" content="main" />
    </head>
    <body>

        <div class="body">
          
            <h1>${title}</h1>

            <g:if test="${language?.hasVariant() && !language?.getShortNameWithCountryAndVariant().contains("-")}">
                <p class="warn"><b>Hint:</b> Note that spell checking will only work when you select a language
                    plus its variant,<br/>e.g. "English (US)" instead of just "English".</p>
            </g:if>

            <g:if test="${!matches}">
                <g:message code="ltc.home.check.text.intro" args="${['http://languagetool.org']}" />
            </g:if>
        
            <g:render template="/ruleMatches"/>
            
            <br />
        
            <g:form method="post">
                <g:textArea name="text" value="${params.text}" rows="5" cols="80" />
                <br />
                <g:actionSubmit action="checkText" value="${message(code:'ltc.home.check.text')}"/>
                &nbsp;&nbsp;&nbsp;Language:
                <select name="language">
                    <g:each in="${languages}" var="lang">
                        <g:set var="codeWithCountry" value="${lang.countries?.size() == 1 && lang.countries[0] != 'ANY' ? lang.shortName + '-' + lang.countries[0] : lang.shortName}"/>
                        <g:set var="iteratedLangName" value="${language?.getShortNameWithCountryAndVariant()}"/>
                        <g:if test="${iteratedLangName == 'eo-ANY'}">
                            <g:set var="iteratedLangName" value="eo"/>
                        </g:if>
                        <g:set var="selected" value="${iteratedLangName == codeWithCountry ? 'selected' : ''}"/>
                        <option ${selected} value="${codeWithCountry}">${lang.name}</option>
                    </g:each>
                </select>
            </g:form>
        
        </div>
        
    </body>
</html>