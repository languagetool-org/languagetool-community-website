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
                &nbsp;&nbsp;&nbsp;Language: <g:select name="lang" from="${languages}" optionKey="shortName" noSelection="${['auto':'auto-detect']}" value="${params.lang}"></g:select>
            </g:form>
        
        </div>
        
    </body>
</html>