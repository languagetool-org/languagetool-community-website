<%@page import="org.languagetool.*" %>
<%@page import="org.languagetool.tools.StringTools" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title><g:message code="ltc.wikicheck.title"/></title>
    <meta name="layout" content="main" />
</head>
<body>

<div class="body">

    <g:render template="/languageSelection"/>

    <div class="dialog">
    
        <h1>LanguageTool WikiCheck</h1>
    
        <p>Note: we have moved our Wikipedia checks to Wikimedia Tool Labs, a server cluster provided by the Wikimedia Foundation.
        These links will get you there. (June 2014)</p>

        <!--old links for testing: <g:link action="pageCheck" params="[lang: lang.getShortName()]"><g:message code="ltc.wiki.check"/></g:link>, <g:link controller="feedMatches" action="list" params="[lang: lang.getShortName()]"><g:message code="ltc.feed.matches.title"/></g:link>-->
    
        <h2 class="firstHeadline"><a href="http://tools.wmflabs.org/languagetool/pageCheck/index?lang=${lang.getShortName()}"><g:message code="ltc.wiki.check"/></a></h2>
    
        <div class="mainPart">
            <p><g:message code="ltc.wiki.check.explain"/></p>
        </div>
    
        <h2><a href="http://tools.wmflabs.org/languagetool/feedMatches/list?lang=${lang.getShortName()}"><g:message code="ltc.feed.matches.title"/></a></h2>
    
        <div class="mainPart">
            <p>
                <g:message code="ltc.feed.matches.explain.short"/>
                <g:message code="ltc.feed.matches.not.available"/>
            </p>
        </div>

        <!--
        <h2><g:link controller="corpusMatch" action="list" params="[lang: lang.getShortName()]"><g:message code="ltc.check.results"/></g:link></h2>
    
        <div class="mainPart">
            <p><g:message code="ltc.check.explain.short"/></p>
        </div>-->

    </div>

</div>

</body>
</html>