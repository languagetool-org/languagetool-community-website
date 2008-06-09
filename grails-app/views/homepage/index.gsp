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
        
            <g:render template="/languageSelection"/>

            <p><strong>Check Rules' Results</strong></p>
            
            <div class="mainPart">
            
            <p>We use LanguageTool on Wikipedia data to test which rules work well and which need
            more work. Please vote on LanguageTool's results. If there's a real error you're encouraged
            to fix it in Wikipedia, but note that the check may not be up-to-date and the error may
            have been fixed already.</p>
            
            <p>Random selection of LanguageTool results when run on Wikipedia:</p>
            
            <br/>
            <g:render template="/corpusMatches"/>
            
            </div>

            <br />
            
            <g:link controller="rule" action="list" params="[lang: params.lang?.encodeAsHTML()]">Browse Rules</g:link>
            
            <div class="mainPart">
                LanguageTool uses rules to detect errors. Each rule represents one or more potential
                errors in the text to check. Have a look and configure all rules of all languages here.
            </div>
            

            <br />
            <p><strong>Run LanguageTool</strong></p>

            <div class="mainPart">

            <g:form method="post">
                <input type="hidden" name="lang" value="${params.lang?.encodeAsHTML()}"/>
            
                <g:textArea name="text" value="${textToCheck}" rows="5" cols="80" />
                <br />
                <g:actionSubmit action="checkText" value="Check Text"/>
                
            </g:form>
            
            <g:if test="${!session.user}">
                Note that you can log in to activate and deactivate only those
                rules that are important to you.
            </g:if>
            
            </div>

            <div class="lthomepage">
                <strong>Visit the LanguageTool homepage at
                <a href="http://www.languagetool.org">www.languagetool.org</a> and
                download LanguageTool as an extension for
                <a href="http://www.openoffice.org">OpenOffice.org</a></strong>
            </div>
                   
        </div>

        </div>
        
    </body>
</html>