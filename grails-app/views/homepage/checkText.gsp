<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>Results of your text check</title>
		<meta name="layout" content="main" />
    </head>
    <body>

        <div class="body">
        
            <h1>Test results</h1>
        
            <g:if test="${session.user}">
	            <g:if test="${disabledRules && disabledRules.size() > 0}">
	                <p>Note that you have disabled ${disabledRules.size()} rules
	                in your configuration.
	                <g:link controller="rule" action="list" params="[lang: params.lang.encodeAsHTML()]">Browse
	                the rules</g:link> to activate/deactivate rules.</p>
	            </g:if>
	            <g:else>
	                <p>All rules are activated.
	                <g:link controller="rule" action="list" params="[lang: params.lang.encodeAsHTML()]">Browse
	                the rules</g:link> to deactivate rules that are not useful for you.</p>
	            </g:else>
            </g:if>
            <br/>
            
            <g:render template="/ruleMatches"/>
            
            <br />
            <p>Check again:</p>
        
            <g:form method="post">
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
            
                <g:textArea name="text" value="${textToCheck}" rows="5" cols="80" />
                <br />
                <g:actionSubmit action="checkText" value="Check Text"/>
                
            </g:form>
        
        </div>
        
    </body>
</html>