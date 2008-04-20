<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title>LanguageTool Community Evaluation</title>
		<meta name="layout" content="main" />
    </head>
    <body>

        <div class="body">

        <div class="dialog">
        
            <br />
            
            <p>Top results marked as useless:</p>
            
            <g:each var="result" in="${results}">
                ${result.counter} -- ${CorpusMatch.get(result.ruleId).errorContext}<br/>
            </g:each>

        </div>
        
        </div>
        
    </body>
</html>