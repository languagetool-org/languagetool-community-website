<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title>LanguageTool Community</title>
		<meta name="layout" content="main" />
		<g:javascript library="prototype" />
    </head>
    <body>

        <div class="body">

        <div class="dialog">
        
            <br /><br />
            
            <g:link controller="rule" action="list">Browse Rules</g:link>
            
            <br /><br />

            <p><strong>Check Rules</strong></p>
            
            <p>We use LanguageTool on Wikipedia data to test which rules work well and which need
            more work. Please vote on LanguageTool's results. If there's a real error you're encouraged
            to fix it in Wikipedia, but note that the check may not be up-to-date and the error may
            have been fixed already.</p>
            
            <div style="margin-left:15px">
            
            <g:render template="/languageSelection"/>
            
            <ul>
	            <g:each in="${matches}" var="matchInfo" status="i">
	                <li class="errorList">${matchInfo.match.getMessage()}:<br/>
	                   <span class="exampleSentence">${matchInfo.match.getErrorContext().
	                    replaceAll("<err>", "<span class='error'>").replaceAll("</err>", "</span>")}</span>
	                    <br />
	                    
	                    <g:if test="${session.user}">
	                        <g:if test="${matchInfo.opinion == CorpusMatchController.NEGATIVE_OPINION}">
	                           [voted as useless]
	                        </g:if>
	                        <g:elseif test="${matchInfo.opinion == CorpusMatchController.POSITIVE_OPINION}">
                               [voted as useful]
	                        </g:elseif>
	                        <g:else>
	                            <div id="opinion_${i}">
	                                <g:remoteLink controller="corpusMatch" action="markUseful" update="opinion_${i}"
	                                    id="${matchInfo.match.id}">Mark error message as useful</g:remoteLink>
	                                <br />
	                                <g:remoteLink controller="corpusMatch" action="markUseless" update="opinion_${i}"
	                                    id="${matchInfo.match.id}">Mark error message as useless/incorrect</g:remoteLink>
	                            </div>
	                        </g:else>
	                    </g:if>
                        <g:else>
	                       <g:link controller="user" action="login">Login to vote on this message</g:link>
	                    </g:else>
	                    <p align="right">
                            <g:link url="${matchInfo.match.sourceURI}">Visit Wikipedia page</g:link>
	                    </p>
	                </li>
	            </g:each>
	            <g:if test="${matches.size() == 0}">
	               <li>Sorry, no example error messages found in the database for language '${langCode}'</li>
	            </g:if>
            </ul>
            
            <g:if test="${matches.size() > 0}">
	            <br/>
	            <g:link controller="homepage" params="[lang:params.lang]">Show other examples</g:link>
            </g:if>
                 
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
        
        </div>
        
    </body>
</html>