<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title>LanguageTool Community</title>
		<meta name="layout" content="main" />
    </head>
    <body>

        <h1 style="margin-left:20px;">LanguageTool Community</h1>

        <div class="dialog" style="margin-left:20px;width:60%;">
        
            <br /><br />
            
            <g:link controller="rule" action="list">Browse Rules</g:link>
            
            <br /><br />

            <p><strong>Check Rules</strong></p>
            
            <div style="margin-left:15px">
            
            <br/>
            <g:each var="lang" in="${languages}">
                <g:if test="${params.lang == lang.shortName}">
                    ${lang.getName()}
                </g:if>
                <g:else>
                    <g:link params="[lang:lang.getShortName()]">${lang.getName()}</g:link>
                </g:else>               
            </g:each>
            <br/><br/>
            
            <ul>
	            <g:each in="${matches}" var="match">
	                <li>${match.getMessage()}:<br/>
	                   <span class="exampleSentence">${match.getErrorContext().
	                    replaceAll("<err>", "<span class='error'>").replaceAll("</err>", "</span>")}</span>
	                    <br />
	                    <g:link url="${match.sourceURI}">Visit Wikipedia page</g:link>
	                </li>
	            </g:each>
	            <g:if test="${matches.size() == 0}">
	               <li>Sorry, no example error messages found in the database for language '${langCode}'</li>
	            </g:if>
            </ul>
            
            <br/>
            <g:link controller="homepage" params="[lang:params.lang]">Show more examples</g:link>
                 
            </div>
                   
            <!-- 
            <pre>
            TODO:
            -personal settings of existing rules -> export
            -login
            -create your own rules + make them public or not (public by default)
            -submit incorrect sentences
            -support false friend rules
            -support spell checking?!
            </pre>
             -->
        </div>
    </body>
</html>