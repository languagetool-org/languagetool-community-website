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
            
            <g:render template="/ruleMatches"/>
            
            <br />
            <p><g:message code="ltc.home.check.again"/></p>
        
            <g:form method="post">
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
            
                <g:textArea name="text" value="${textToCheck}" rows="5" cols="80" />
                <br />
                <g:actionSubmit action="checkText" value="${message(code:'ltc.home.check.text')}"/>
                
            </g:form>
        
        </div>
        
    </body>
</html>