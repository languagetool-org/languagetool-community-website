<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title><g:message code="ltc.home.check.title"/></title>
		<meta name="layout" content="main" />
    </head>
    <body>

        <div class="body">
          
            <h1><g:message code="ltc.home.check.title"/></h1>

            <g:if test="${language?.hasVariant()}">
                <p class="warn"><b>Hint:</b> Note that spell checking will only work when you select a language
                    plus its variant,<br/>e.g. "English (US)" instead of just "English".</p>
            </g:if>
        
            <g:if test="${session.user}">
	            <g:if test="${disabledRules && disabledRules.size() > 0}">
	                <p><g:message code="ltc.home.check.rules.inactive" args="${[disabledRules.size()]}"/>
	                <g:link controller="rule" action="list" params="[lang: params.lang.encodeAsHTML()]"><g:message code="ltc.home.check.rules.config.link"/></g:link></p>
	            </g:if>
	            <g:else>
	            	<p><g:message code="ltc.home.check.rules.active"/>
	                <g:link controller="rule" action="list" params="[lang: params.lang.encodeAsHTML()]"><g:message code="ltc.home.check.rules.config.link"/></g:link></p>
	            </g:else>
            </g:if>
            <br/>
            
            <g:if test="${autoLangDetectionWarning}">
              <div class="warn"><g:message code="ltc.home.check.detection.warning" args="${[detectedLang]}"/></div>
            </g:if>
            <g:if test="${autoLangDetectionFailure}">
              <div class="warn"><g:message code="ltc.home.check.detection.failure" args="${[languages]}"/></div>
            </g:if>

            <g:render template="/ruleMatches"/>
            
            <br />
            <p><g:message code="ltc.home.check.again"/></p>
        
            <g:form method="post">
                <g:textArea name="text" value="${params.text}" rows="5" cols="80" />
                <br />
                <g:actionSubmit action="checkText" value="${message(code:'ltc.home.check.text')}"/>
                &nbsp;&nbsp;&nbsp;Language:
                <select name="lang">
                    <g:each in="${languages}" var="lang">
                        <g:set var="codeWithCountry" value="${lang.countryVariants?.size() == 1 && lang.countryVariants[0] != 'ANY' ? lang.shortName + '-' +lang.countryVariants[0] : lang.shortName}"/>
                        <g:set var="selected" value="${language.getShortNameWithVariant() == codeWithCountry ? 'selected' : ''}"/>
                        <g:if test="${!lang.hasVariant()}">
                            <option ${selected} value="${codeWithCountry}">${lang.name}</option>
                        </g:if>
                    </g:each>
                </select>
            </g:form>
        
        </div>
        
    </body>
</html>