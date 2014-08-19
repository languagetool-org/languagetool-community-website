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
            
        <g:set var="lang" value="${params.lang ? params.lang : 'en'}"/>

        <div class="dialog">
            
            <p style="margin-bottom: 15px"><g:message code="ltc.home.intro"/></p>

            <table style="border:0">
                <tr>
                    <td><h1>LanguageTool</h1></td>
                    <td></td>
                    <td><h1>Wikipedia</h1></td>
                </tr>
                <tr>
                    <td width="45%">

                        <h2 class="firstHeadline"><g:link controller="ruleEditor2" params="[lang: lang]"><g:message code="ltc.home.rule.editor.title"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.home.rule.editor.description"/>
                        </div>

                        <h2><g:link controller="rule" action="list" params="[lang: lang]"><g:message code="ltc.browse.rules"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.browse.explain"/>
                        </div>

                        <h2><g:link controller="analysis" params="[lang: lang]"><g:message code="ltc.home.analysis.title"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.home.analysis.explain"/>
                        </div>

                        <h2><g:link controller="homepage" action="simpleCheck" params="[lang: lang]"><g:message code="ltc.home.check.fallback.short.title"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.home.check.text.explain"/>
                        </div>

                    </td>
                    <td width="10%"></td>
                    <td width="45%">

                        <h2 class="firstHeadline"><g:link controller="wikiCheck" params="[lang: lang]"><g:message code="ltc.wiki.check.homepage"/></g:link></h2>

                        <div class="mainPart">
                            <p><g:message code="ltc.wiki.check.explain.homepage"/></p>
                        </div>

                    </td>
                </tr>
            </table>

            <div style="margin-left:8px;margin-top: 50px">
                <g:render template="/languageToolVersion"/>
            </div>

        </div>

        </div>
        
    </body>
</html>