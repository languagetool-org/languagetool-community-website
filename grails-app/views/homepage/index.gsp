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
                    <td class="homepageArea">LanguageTool</td>
                    <td></td>
                    <td class="homepageArea">LanguageTool &amp; Wikipedia</td>
                </tr>
                <tr>
                    <td width="45%">

                        <h2 class="firstHeadline"><g:link controller="homepage" action="simpleCheck" params="[lang: lang]"><g:message code="ltc.home.check.fallback.short.title"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.home.check.text.explain"/>
                        </div>

                        <h2><g:link controller="rule" action="list" params="[lang: lang]"><g:message code="ltc.browse.rules"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.browse.explain"/>
                        </div>

                        <h2><g:link controller="ruleEditor" params="[lang: lang]"><g:message code="ltc.editor.title.short"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.editor.explain"/>
                        </div>

                    </td>
                    <td width="10%"></td>
                    <td width="45%">

                        <h2 class="firstHeadline"><g:link controller="wikiCheck" params="[lang: lang]"><g:message code="ltc.wiki.check"/></g:link></h2>

                        <div class="mainPart">
                            <p><g:message code="ltc.wiki.check.explain"/></p>
                        </div>

                        <h2><g:link controller="corpusMatch" action="list" params="[lang: lang]"><g:message code="ltc.check.results"/></g:link></h2>

                        <div class="mainPart">
                            <p><g:message code="ltc.check.explain.short"/></p>
                        </div>

                        <h2><g:link controller="feedMatches" action="list" params="[lang: lang]"><g:message code="ltc.feed.matches.title"/></g:link></h2>

                        <div class="mainPart">
                            <p>
                                <g:message code="ltc.feed.matches.explain.short"/>
                                <g:message code="ltc.feed.matches.not.available"/>
                            </p>
                        </div>

                    </td>
                </tr>
            </table>

        </div>

        </div>
        
    </body>
</html>