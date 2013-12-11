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

            <table style="border:0">
                <tr>
                    <td class="homepageArea">LanguageTool</td>
                    <td></td>
                    <td class="homepageArea">LanguageTool &amp; Wikipedia</td>
                </tr>
                <tr>
                    <td width="45%">

                        <h2 class="firstHeadline"><g:link controller="homepage" action="simpleCheck" params="[lang: params.lang?.encodeAsHTML()]"><g:message code="ltc.home.check.fallback.short.title"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.home.check.text.explain"/>
                        </div>

                        <h2><g:link controller="rule" action="list" params="[lang: params.lang?.encodeAsHTML()]"><g:message code="ltc.browse.rules"/></g:link></h2>

                        <div class="mainPart">
                            <g:message code="ltc.browse.explain"/>
                        </div>

                    </td>
                    <td width="10%"></td>
                    <td width="45%">

                        <h2 class="firstHeadline"><g:link controller="wikiCheck" params="[lang: params.lang ? params.lang : 'en']"><g:message code="ltc.wiki.check"/></g:link></h2>

                        <div class="mainPart">
                            <p><g:message code="ltc.wiki.check.explain"/></p>
                        </div>

                        <h2><g:link controller="corpusMatch" action="list" params="[lang: params.lang ? params.lang : 'en']"><g:message code="ltc.check.results"/></g:link></h2>

                        <div class="mainPart">
                            <p><g:message code="ltc.check.explain.short"/></p>
                        </div>

                    </td>
                </tr>
            </table>

        </div>

        </div>
        
    </body>
</html>