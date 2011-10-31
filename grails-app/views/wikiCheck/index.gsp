<%@page import="org.languagetool.*" %>
<%@page import="de.danielnaber.languagetool.tools.StringTools" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title>LanguageTool Wikipedia Check</title>
        <meta name="layout" content="main" />
        <meta name="robots" content="noindex" />
    </head>
    <body>

        <div class="body">

        <div class="dialog">
        
            <h1>LanguageTool WikipediaQuickCheck (Beta-Version)</h1>
            
            <p>
            Hier können Wikipedia-URLs mit <a href="http://www.languagetool.org">LanguageTool</a> geprüft werden.
            Bisher werden nur URLs der deutschsprachigen Wikipedia akzeptiert.  
            </p>
             
            <g:form action="index" method="get">
                Wikipedia URL: <input style="width:350px" name="url" value="${url?.encodeAsHTML()}"/>
                <input type="submit" value="Run LanguageTool"/>
            </g:form>
            <g:link action="index" params="${[url: 'http://de.wikipedia.org/wiki/Benutzer_Diskussion:Dnaber']}">Beispiel</g:link>
                        
            <br /><br />
            
            <g:if test="${result}">
                <br />
                <h2>Ergebnis</h2>
                
                <p>Geprüfte URL: <a href="${url.encodeAsHTML()}">${url.encodeAsHTML()}</a></p>
                
                <br />
                
                <g:render template="/ruleMatches"/>
                
                <br /><br />
                <p>Folgende LanguageTool-Regel sind noch nicht aktiviert, da sie meist wegen der noch sehr unzureichenden
                Text-Extraktion zu viele Fehlermeldungen liefern:</p>
                <g:each in="${disabledRuleIds}" var="ruleId">
                    <a href="http://community.languagetool.org/rule/show/${ruleId}?lang=de">${ruleId}</a>
                </g:each>
            </g:if>       
            
        </div>
        
        </div>
        
    </body>
</html>