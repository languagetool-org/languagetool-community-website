<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title>LanguageTool Community</title>
		<meta name="layout" content="main" />
		<g:javascript library="prototype" />
    </head>
    <body>

        <div class="dialog" style="margin-left:20px;width:60%;">
        
            <br /><br />
            
            <g:link controller="rule" action="list">Browse Rules</g:link>
            
            <br /><br />

            <p><strong>Check Rules</strong></p>
            
            <div style="margin-left:15px">
            
            <g:render template="/languageSelection"/>
            
            <ul>
	            <g:each in="${matches}" var="match">
	                <li class="errorList">${match.getMessage()}:<br/>
	                   <span class="exampleSentence">${match.getErrorContext().
	                    replaceAll("<err>", "<span class='error'>").replaceAll("</err>", "</span>")}</span>
	                    <br />
	                    
                        <g:remoteLink controller="corpusMatch" action="markUseful"
                            id="${match.id}">Mark error message as useful</g:remoteLink>
                        &nbsp;
                        <g:remoteLink controller="corpusMatch" action="markUseless"
                            id="${match.id}">Mark error message as useless/incorrect</g:remoteLink>
	                    <br/>
	                    <g:link url="${match.sourceURI}">Visit Wikipedia page</g:link>
	                </li>
	            </g:each>
	            <g:if test="${matches.size() == 0}">
	               <li>Sorry, no example error messages found in the database for language '${langCode}'</li>
	            </g:if>
            </ul>
            
            <br/>
            <g:link controller="homepage" params="[lang:params.lang]">Show other examples</g:link>
                 
            </div>
                   
            <!-- 
            <pre>
            TODO:
            -show POS tags or error sentences
            -personal settings of existing rules -> export
            -create your own rules + make them public or not (public by default)
            -submit incorrect sentences
            -support false friend rules
            -support spell checking?!
            </pre>
             -->
        </div>
    </body>
</html>