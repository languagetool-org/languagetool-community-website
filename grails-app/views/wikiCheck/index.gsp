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
            
            <p>
            <g:message code="ltc.wikicheck.intro"/>
            </p>
             
            <div style="margin-top:10px;margin-bottom:10px;">
                <g:form action="index" method="get">
                    <g:message code="ltc.wikicheck.url"/> <input style="width:350px" name="url" value="${url?.encodeAsHTML()}"/>
                    <input type="submit" value="${message(code:'ltc.wikicheck.check.page')}"/>
                </g:form>
            </div>

            <g:link action="index" params="${[url: message(code:'ltc.wikicheck.example.page.url'), lang: langCode]}"><g:message code="ltc.wikicheck.example.page"/></g:link>
                &middot; <g:link action="index" params="${[url: 'random:' + langCode, lang: langCode]}"><g:message code="ltc.wikicheck.random.page"/></g:link>

            <p style="margin-top: 10px">
            <g:message code="ltc.wikicheck.bookmarklet"/>
              <a href="javascript:(function(){%20window.open('http://community.languagetool.org/wikiCheck/index?url='+escape(location.href));%20})();"><g:message code="ltc.wikicheck.bookmarklet.link"/></a></p>


            <br />
            
            <g:if test="${result}">

                <h2 style="margin-top:10px;margin-bottom:10px"><g:message code="ltc.wikicheck.result.headline"/></h2>
                
                <p><g:message code="ltc.wikicheck.result.url"/> <a href="${realUrl.encodeAsHTML()}">${realUrl.encodeAsHTML()}</a> (<a href="${realEditUrl.encodeAsHTML()}"><g:message code="ltc.wikicheck.result.edit"/></a>)</p>
                
                <br />
                
                <g:render template="/ruleMatches"/>
                
                <br /><br />
                <div style="color:#555555;">
                    <g:message code="ltc.wikicheck.rules.intro"/>
                    <a style="color: #555555" href="javascript:toggleId('disabledRuleInfo');"><g:message code="ltc.wikicheck.rules.details"/></a>
                    <div id="disabledRuleInfo" style="margin-top: 5px; display: none;color:#444444;">
                        <g:message code="ltc.wikicheck.rules.message"/>
                        <g:each in="${disabledRuleIds}" var="ruleId" status="i">
                            <g:if test="${i > 0}">
                                &middot;
                            </g:if>
                            <a style="color:#444444;font-weight:normal" href="http://community.languagetool.org/rule/show/${ruleId.encodeAsURL()}?lang=${lang.encodeAsHTML()}">${ruleId.encodeAsHTML()}</a>
                        </g:each>
                        <div style="margin-top: 5px">
                            <g:message code="ltc.wikicheck.rules.activate.all.link" args="${['?url=' + params.url + '&amp;lang='+ params.lang + '&amp;disabled=none']}"/>
                        </div>
                    </div>
                </div>
            </g:if>

            <g:render template="/languageToolVersion"/>

        </div>
        
        </div>
        
    </body>
</html>