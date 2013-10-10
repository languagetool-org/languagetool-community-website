<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title><g:message code="ltc.home.title"/> (${language})</title>
        <meta name="layout" content="main" />
    </head>
    <body>

        <div class="body">

        <g:render template="/languageSelection"/>

        <div class="dialog">
            
            <p style="margin-bottom: 15px"><g:message code="ltc.home.intro"/></p>

            <br />
            <h2><g:link controller="rule" action="list" params="[lang: params.lang?.encodeAsHTML()]"><g:message code="ltc.browse.rules"/></g:link></h2>
            
            <div class="mainPart">
                <g:message code="ltc.browse.explain"/>
            </div>


            <br />
            <h2><g:link controller="wikiCheck" params="[lang: params.lang ? params.lang : 'en']"><g:message code="ltc.wiki.check"/></g:link></h2>


            <br />
            <h2><g:link controller="corpusMatch" action="list" params="[lang: params.lang ? params.lang : 'en']"><g:message code="ltc.check.results"/></g:link></h2>
            
            <div class="mainPart">
            
            <p><g:message code="ltc.check.explain"/></p>
            
            <p><g:message code="ltc.check.random.selection"/></p>
            
            <br/>
            <g:render template="/corpusMatches"/>
            
            </div>

            <br />

            <div class="lthomepage">
                <g:message code="ltc.home.links"/>
            </div>
                   
        </div>

        </div>
        
    </body>
</html>