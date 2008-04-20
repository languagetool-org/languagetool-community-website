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
            
            <g:link controller="rule" action="list" params="[lang: params.lang.encodeAsHTML()]">Browse Rules</g:link>
            
            <br /><br />

            <p><strong>Check Rules</strong></p>
            
            <p>We use LanguageTool on Wikipedia data to test which rules work well and which need
            more work. Please vote on LanguageTool's results. If there's a real error you're encouraged
            to fix it in Wikipedia, but note that the check may not be up-to-date and the error may
            have been fixed already.</p>
            
            <div style="margin-left:15px">
            
            <g:render template="/languageSelection"/>
            
            <g:render template="/corpusMatches"/>
            
            <g:if test="${matches.size() > 0}">
	            <br/>
	            <g:link controller="homepage" params="[lang:params.lang.encodeAsHTML()]">Show other examples</g:link>
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