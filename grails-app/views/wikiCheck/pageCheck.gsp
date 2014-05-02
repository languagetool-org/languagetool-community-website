<%@page import="org.languagetool.*" %>
<%@page import="org.languagetool.tools.StringTools" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title><g:message code="ltc.wikicheck.title"/></title>
    <meta name="layout" content="main" />
    <meta name="robots" content="noindex" />
    <script type="text/javascript" src="${resource(dir:'js/prototype',file:'prototype.js')}"></script>
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
        function copyText(errorId, targetId) {
            var errorDiv = $(errorId);
            $(targetId).value = errorDiv.innerHTML.replace(/&lt;/g, "<").replace(/&gt;/g, ">")
                    .replace(/&amp;/g, "&").replace(/&quot;/g, '"').replace(/&apos;/g, "'");
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

        <g:render template="backLink" model="${[langCode: langCode]}"/>

        <h1><g:message code="ltc.wikicheck.headline"/></h1>

        <g:render template="urlBox"/>

        <br />

        <g:if test="${result}">

            <h2 style="margin-top:10px;margin-bottom:10px"><g:message code="ltc.wikicheck.result.headline"/></h2>

            <p><g:message code="ltc.wikicheck.result.url"/> <a href="${realUrl.encodeAsHTML()}">${realUrl.encodeAsHTML()}</a> (<a href="${realEditUrl.encodeAsHTML()}"><g:message code="ltc.wikicheck.result.edit"/></a>)</p>

            <p class="warn"><g:message code="ltc.wikicheck.beta.warning"/></p>

            <br />

            <g:if test="${appliedRuleMatches.size() > 0}">
                <form action="${wikipediaSubmitUrl}" method="POST" onsubmit="applyChangesToHiddenField()" target="_blank">
                    <!-- see http://www.mediawiki.org/wiki/Manual:Parameters_to_index.php -->
                    <g:hiddenField name="Title" value="${wikipediaTitle}"/>
                    <g:hiddenField name="wpAntiSpam" value=""/>
                    <!--<g:hiddenField name="baseRevId" value=""/>-->
                    <g:hiddenField name="altBaseRevId" value="0"/>
                    <g:hiddenField name="undidRev" value="0"/>
                    <g:hiddenField name="wpSection" value=""/>
                    <g:hiddenField name="wpStarttime" value="${formatDate(format: 'yyyyMMddHHmmss')}"/>
                    <g:hiddenField name="wpEdittime" value="${result.lastEditTimestamp.replaceAll('[TZ:-]', '')}"/>
                    <g:hiddenField name="wpScrolltop" value="0"/>
                    <g:hiddenField name="oldId" value="0"/>
                    <g:hiddenField name="format" value="text/x-wiki"/>
                    <g:hiddenField name="model" value="wikitext"/>
                    <g:if test="${grailsApplication.config.wikipedia.summary.link.containsKey(lang)}">
                        <g:set var="wikipediaLink" value="${grailsApplication.config.wikipedia.summary.link[lang]}:"/>
                    </g:if>
                    <g:else>
                        <g:set var="wikipediaLink" value="LanguageTool:"/>
                    </g:else>
                    <g:hiddenField name="wpSummary" value="${wikipediaLink} ${message(code: 'ltc.wikicheck.summary.preset')}"/>
                    <g:hiddenField name="wpDiff" value="yes"/>
                    <g:hiddenField name="wpMinoredit" value="1"/>
                    <!-- this will be modified at submit: -->
                    <g:hiddenField name="wpTextbox1" value="${result.getOriginalWikiMarkup()}"/>
                    <!-- always keep the original text so the browser's back button doesn't mess it up: -->
                    <g:hiddenField name="origWpTextbox1" value="${result.getOriginalWikiMarkup()}"/>
                    <g:hiddenField name="wpEditToken" value="+\\"/>

                    <g:render template="/ruleMatchDiffs"/>

                    <table class="wikiCheckTable">
                        <tr>
                            <td width="41%"></td>
                            <td width="57%"></td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <g:submitButton style="margin-bottom: 10px" name="${message(code:'ltc.wikicheck.submit.button')}"/>
                                <br/>
                                <g:message code="ltc.wikicheck.submit.warning"/>
                                <br/>
                                <a href="${realEditUrl.encodeAsHTML()}"><g:message code="ltc.wikicheck.result.edit.manually"/></a>
                            </td>
                        </tr>
                    </table>
                </form>
            </g:if>
            <g:else>
                <g:message code="ltc.no.rule.matches" args="${[Language.getLanguageForShortName(params.lang)]}"/>
            </g:else>

            <g:if test="${result.internalErrorCount > 0}">
                <p class="warn">
                    <g:message code="ltc.wikicheck.missing.matches" args="${[result.internalErrorCount]}"/>
                    <g:link action="showErrors" params="${[url:realUrl, disabled:params.disabled, lang:params.lang]}"><g:message code="ltc.wikicheck.missing.matches.link"/></g:link>
                </p>
            </g:if>

            <br /><br />
            <g:render template="disabledRulesHint"/>
        </g:if>

        <g:render template="/languageToolVersion"/>

    </div>

</div>

</body>
</html>