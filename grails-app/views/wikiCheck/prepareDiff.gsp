<%@page import="org.languagetool.*" %>
<%@page import="org.languagetool.tools.StringTools" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title><g:message code="ltc.wikicheck.title"/></title>
        <g:javascript library="prototype" />
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
            function useSuggestion(item, id) {
                var suggestionField = $(id);
                suggestionField.value = item.firstChild.data;
                return false;
            }
            function useNoSuggestion(id) {
                var suggestionField = $(id);
                suggestionField.value = "";
                return false;
            }
            function applyChangesToHiddenField() {
                var origTextBox = $('origWpTextbox1');
                var textBox = $('wpTextbox1');
                // use the original text, otherwise everything will mess up once the user uses the back
                // button and makes more changes:
                textBox.value = origTextBox.value;
                var modifiedText = textBox.value;
                var i;
                var prevStartPos = -1;
                for (i = $('replMaximum').value - 1; i >= 0; i--) {  // backwards, as we modify the text
                    var startPos = parseInt($('repl' + i + "Start").value);
                    var endPos = parseInt($('repl' + i + "End").value);
                    var replacement = $('repl' + i).value;
                    if (replacement == "") {
                        continue;
                    }
                    if (prevStartPos != -1 && endPos >= prevStartPos) {
                        //console.log("Skipping overlap! (" + replacement + ") for " + startPos + "/" + endPos + ": " + endPos + ">=" +  prevStartPos);
                        prevStartPos = startPos;
                        continue;
                    }
                    prevStartPos = startPos;
                    var origText = modifiedText.substring(startPos, endPos);
                    //console.log(i + ". applying change from " + startPos + " to " + endPos + ": '" + origText + "' => '" + replacement + "'");
                    //modifiedText = modifiedText.substring(0, startPos) + "##" + replacement + "##" + modifiedText.substring(endPos);
                    modifiedText = modifiedText.substring(0, startPos) + replacement + modifiedText.substring(endPos);
                }
                textBox.value = modifiedText;
                //console.log(textBox.value);
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
                <g:form action="prepareDiff" method="get">
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

                <p class="warn"><g:message code="ltc.wikicheck.beta.warning"/></p>
                
                <br />

                <g:if test="${ruleApplications.size() > 0}">
                    <form action="${wikipediaSubmitUrl}" method="POST" onsubmit="applyChangesToHiddenField()">
                        <g:hiddenField name="Title" value="${wikipediaTitle}"/>
                        <g:hiddenField name="wpAntiSpam" value=""/>
                        <!--<g:hiddenField name="baseRevId" value=""/>-->
                        <g:hiddenField name="altBaseRevId" value="0"/>
                        <g:hiddenField name="undidRev" value="0"/>
                        <g:hiddenField name="wpSection" value=""/>
                        <g:hiddenField name="wpStarttime" value=""/>
                        <g:hiddenField name="wpEdittime" value=""/>
                        <g:hiddenField name="wpScrolltop" value="0"/>
                        <g:hiddenField name="oldId" value="0"/>
                        <g:hiddenField name="format" value="text/x-wiki"/>
                        <g:hiddenField name="model" value="wikitext"/>
                        <g:hiddenField name="wpSummary" value=""/>
                        <g:hiddenField name="wpDiff" value="yes"/>
                        <g:hiddenField name="wpMinoredit" value="1"/>
                        <!-- this will be modified at submit: -->
                        <g:hiddenField name="wpTextbox1" value="${result.getOriginalWikiMarkup()}"/>
                        <!-- always keep the original text so the browser's back button doesn't mess it up: -->
                        <g:hiddenField name="origWpTextbox1" value="${result.getOriginalWikiMarkup()}"/>
                        <g:hiddenField name="wpEditToken" value="+\\"/>

                        <g:render template="/ruleMatchDiffs"/>
                        <g:submitButton name="${message(code:'ltc.wikicheck.submit.button')}"/>
                        <g:message code="ltc.wikicheck.submit.warning"/>
                    </form>
                </g:if>
                <g:else>
                    <g:message code="ltc.no.rule.matches" args="${[Language.getLanguageForShortName(params.lang)]}"/>
                </g:else>

                <g:if test="${result.internalErrorCount > 0}">
                    <p class="warn">
                        <g:message code="ltc.wikicheck.missing.matches" args="${[result.internalErrorCount]}"/>
                        <g:link action="index" params="${[url:params.url, disabled:params.disabled]}"><g:message code="ltc.wikicheck.missing.matches.link"/></g:link>
                    </p>
                </g:if>

                <br /><br />
                <div style="color:#555555;">
                    <g:message code="ltc.wikicheck.rules.intro"/>
                    <a style="color: #555555" href="javascript:toggleId('disabledRuleInfo');">Details</a>.
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