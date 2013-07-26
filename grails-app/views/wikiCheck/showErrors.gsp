<%@page import="org.languagetool.*" %>
<%@page import="org.languagetool.tools.StringTools" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title><g:message code="ltc.wikicheck.title"/></title>
    <meta name="layout" content="main" />
    <meta name="robots" content="noindex" />
    <script type="text/javascript">
        function toggleId(divId) {
            if (document.getElementById(divId).style.display == 'block') {
                document.getElementById(divId).style.display='none';
            } else {
                document.getElementById(divId).style.display='block';
            }
        }
    </script>
</head>
<body>

<div class="body">

    <g:render template="/languageSelection"/>

    <div class="dialog">

        <h1><g:message code="ltc.wikicheck.headline"/></h1>

        <g:render template="urlBox"/>

        <br />

        <g:if test="${result}">

            <h2 style="margin-top:10px;margin-bottom:10px"><g:message code="ltc.wikicheck.result.headline"/></h2>

            <p><g:message code="ltc.wikicheck.result.url"/> <a href="${realUrl.encodeAsHTML()}">${realUrl.encodeAsHTML()}</a> (<a href="${realEditUrl.encodeAsHTML()}"><g:message code="ltc.wikicheck.result.edit"/></a>)</p>

            <br />

            <g:render template="/ruleMatches"/>

            <br /><br />
            <g:render template="disabledRulesHint"/>
        </g:if>

        <g:render template="/languageToolVersion"/>

    </div>

</div>

</body>
</html>