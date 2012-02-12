<%@page import="org.languagetool.*" %>
<%@page import="org.languagetool.tools.StringTools" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title>Proofreading Wikipedia Pages - LanguageTool WikiCheck</title>
        <meta name="layout" content="main" />
        <meta name="robots" content="noindex" />
    </head>
    <body>

        <div class="body">

        <div class="dialog">
        
            <h1>LanguageTool WikiCheck</h1>
            
            <p>
            Use this form to check Wikipedia pages with <a href="http://www.languagetool.org">LanguageTool</a>:
            </p>
             
            <div style="margin-top:10px;margin-bottom:10px;">
                <g:form action="index" method="get">
                    Wikipedia URL: <input style="width:350px" name="url" value="${url?.encodeAsHTML()}"/>
                    <input type="submit" value="Check Page"/>
                </g:form>
            </div>

            <g:link action="index" params="${[url: 'http://en.wikipedia.org/wiki/User_talk:Dnaber']}">English example</g:link>
                &middot; <g:link action="index" params="${[url: 'http://de.wikipedia.org/wiki/Benutzer_Diskussion:Dnaber']}">German example</g:link>
                &middot; <g:link action="index" params="${[url: 'random:en']}">Random English page</g:link>
                &middot; <g:link action="index" params="${[url: 'random:de']}">Random German page</g:link>

            <p style="margin-top: 10px">
            Bookmark and call on any Wikipedia page to check it:
              <a href="javascript:(function(){%20window.open('http://community.languagetool.org/wikiCheck/index?url='+escape(location.href));%20})();">WikiCheck Bookmarklet</a></p>


            <br />
            
            <g:if test="${result}">

                <h2 style="margin-top:10px;margin-bottom:10px">Result</h2>
                
                <p>URL: <a href="${realUrl.encodeAsHTML()}">${realUrl.encodeAsHTML()}</a></p>
                
                <br />
                
                <g:render template="/ruleMatches"/>
                
                <br /><br />
                <div style="color:#888888;">
                    Some LanguageTool rules are not activated because they cause too many false alarms:
                    <g:each in="${disabledRuleIds}" var="ruleId">
                        <a style="color:#888888;font-weight:normal" href="http://community.languagetool.org/rule/show/${ruleId.encodeAsURL()}?lang=${lang.encodeAsHTML()}">${ruleId.encodeAsHTML()}</a>
                    </g:each>
                </div>
            </g:if>
            
            <div style="margin-top:10px;color:#888888">LanguageTool Version: ${JLanguageTool.VERSION} from ${(new JLanguageTool(Language.DEMO)).getBuildDate()}</div>
            
        </div>
        
        </div>
        
    </body>
</html>