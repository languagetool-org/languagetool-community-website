<%@page import="java.util.regex.Pattern; org.languagetool.rules.patterns.PatternRule; org.languagetool.Language" %>

<ul>
    <g:set var="maxMatches" value="${100}"/>
    <g:hiddenField name="replMaximum" value="${Math.min(appliedRuleMatches.size(), maxMatches)}"/>
    <g:each in="${appliedRuleMatches}" var="appliedRuleMatch" status="i">
        <g:if test="${i < maxMatches}">

            <g:set var="ruleMatch" value="${appliedRuleMatch.getRuleMatch()}"/>
            <g:set var="rule" value="${ruleMatch.getRule()}"/>

            <table class="wikiCheckTable">
                <tr>
                    <td width="40%"></td>
                    <td width="60%"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <g:if test="${rule instanceof PatternRule}">
                            <g:link controller="rule" action="show" id="${rule.getId()}"
                                    params="${[lang: lang, subId: rule.getSubId()]}">${ruleMatch.getMessage().
                                    replace('<suggestion>', '<span class=\'correction\'>').replace('</suggestion>', '</span>')}</g:link>
                        </g:if>
                        <g:else>
                            <g:link controller="rule" action="show" id="${rule.getId()}"
                                    params="${[lang: lang]}">${ruleMatch.getMessage().replaceAll("<suggestion>", "<span class='correction'>").replaceAll("</suggestion>", "</span>")}</g:link>
                        </g:else>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: right">
                        <g:set var="firstApp" value="${appliedRuleMatch.getRuleMatchApplications().get(0)}"/>
                        &hellip;${firstApp.getOriginalErrorContext(50)
                            .encodeAsHTML()
                            .replace('&lt;span class=&quot;error&quot;&gt;', '</td><td><span id="error' + i + '" class="error">')
                            .replace('&lt;/span&gt;', '</span>')}&hellip;
                    </td>
                </tr>


                <tr>
                    <td></td>
                    <td>

                        <g:set var="suggestionsExists" value="${false}"/>
                        <g:each in="${appliedRuleMatch.getRuleMatchApplications()}" var="app">
                            <g:if test="${app.hasRealReplacement()}">
                                <g:set var="suggestionsExists" value="${true}"/>
                            </g:if>
                        </g:each>

                        <g:if test="${suggestionsExists}">
                            <input id="repl${i}" type="text" value="" placeholder="${message(code:'ltc.wikicheck.select.correction')}"/>
                        </g:if>
                        <g:else>
                            <input id="repl${i}" type="text" value="" placeholder="${message(code:'ltc.wikicheck.enter.correction')}"/>
                        </g:else>
                        <a href="#" onclick="return useNoSuggestion('repl${i}')"><g:message code="ltc.wikicheck.reset.correction"/></a> &nbsp;
                        <a href="#" onclick="return copyText('error${i}', 'repl${i}')"><g:message code="ltc.wikicheck.copy.text"/></a>
                        <ul>
                            <g:each in="${appliedRuleMatch.getRuleMatchApplications()}" var="app">
                                <g:if test="${app.hasRealReplacement()}">
                                    <g:set var="newCorrectionText" value="${app.getCorrectedErrorContext(10)}"/>
                                    <g:set var="spanStart" value="${newCorrectionText.indexOf(app.getErrorMarkerStart())}"/>
                                    <g:set var="spanEnd" value="${newCorrectionText.indexOf(app.getErrorMarkerEnd())}"/>
                                    <li><a href="#" onclick="return useSuggestion(this, 'repl${i}')">${newCorrectionText.substring(spanStart, spanEnd).replaceAll('<span.*?>', '').encodeAsHTML()}</a></li>
                                </g:if>
                            </g:each>
                            <%-- marker should be the same for all corrections, so we use the first one: --%>
                            <g:set var="startMarker" value="${firstApp.getErrorMarkerStart()}"/>
                            <g:set var="startPos" value="${firstApp.getOriginalText().indexOf(startMarker)}"/>
                            <g:set var="endMarker" value="${firstApp.getErrorMarkerEnd()}"/>
                            <g:set var="endPos" value="${firstApp.getOriginalText().indexOf(endMarker) - startMarker.length()}"/>
                            <g:hiddenField name="repl${i}Start" value="${startPos}"/>
                            <g:hiddenField name="repl${i}End" value="${endPos}"/>
                        </ul>

                    </td>
                </tr>
            </table>

        </g:if>
        <g:elseif test="${i == maxMatches}">
            <div class="warn"><g:message code="ltc.wikicheck.max.matches" args="${[maxMatches]}"/></div>
        </g:elseif>
        <g:else>
            <%-- nothing --%>
        </g:else>
    </g:each>
</ul>
