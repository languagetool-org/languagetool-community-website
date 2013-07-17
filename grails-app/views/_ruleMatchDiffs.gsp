<%@page import="java.util.regex.Pattern; org.languagetool.rules.patterns.PatternRule; org.languagetool.Language" %>

<ul>
    <g:set var="maxMatches" value="${100}"/>
    <g:hiddenField name="replMaximum" value="${ruleApplications.size()}"/>
    <g:each in="${ruleApplications}" var="application" status="i">
        <g:if test="${i < maxMatches}">

            <g:set var="ruleMatch" value="${application.getRuleMatch()}"/>
            <g:set var="rule" value="${ruleMatch.getRule()}"/>
            <g:set var="startMarker" value="${application.getErrorMarkerStart()}"/>
            <g:set var="startPos" value="${application.getOriginalText().indexOf(startMarker)}"/>
            <g:set var="endMarker" value="${application.getErrorMarkerEnd()}"/>
            <g:set var="endPos" value="${application.getOriginalText().indexOf(endMarker) - startMarker.length()}"/>

            <table class="wikiCheckTable" style="width:1000px;padding:0;margin-bottom:15px;border-style:none">
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
                                    params="${[lang: lang]}">${rule.getDescription()}</g:link>
                        </g:else>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: right">
                        &hellip;${application.getOriginalErrorContext(50)
                                .replace('<span ', '</td><td><span ')
                                .replace('</span>', '</span>')}&hellip;
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td>
                        <g:set var="newCorrectionText" value="${application.getCorrectedErrorContext(10)}"/>
                        <g:set var="spanStart" value="${newCorrectionText.indexOf(application.getErrorMarkerStart())}"/>
                        <g:set var="spanEnd" value="${newCorrectionText.indexOf(application.getErrorMarkerEnd())}"/>
                        <g:if test="${application.hasRealReplacement()}">
                            <input id="repl${i}" type="text" value="" placeholder="${message(code:'ltc.wikicheck.select.correction')}"/>
                            <br/>
                            <ul>
                                <li><a href="#" onclick="return useNoSuggestion('repl${i}')"><g:message code="ltc.wikicheck.do.not.apply.any.suggestion"/></a><br/></li>
                                <li><a href="#" onclick="return useSuggestion(this, 'repl${i}')">${newCorrectionText.substring(spanStart, spanEnd).replaceAll('<span.*?>', '')}</a></li>
                            </ul>
                        </g:if>
                        <g:else>
                            <input id="repl${i}" type="text" value="" placeholder="${message(code:'ltc.wikicheck.enter.correction')}"/>
                        </g:else>
                        <g:hiddenField name="repl${i}Start" value="${startPos}"/>
                        <g:hiddenField name="repl${i}End" value="${endPos}"/>
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
