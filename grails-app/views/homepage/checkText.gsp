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