<%@page import="java.util.regex.Pattern; org.languagetool.rules.patterns.PatternRule; org.languagetool.Language" %>

<ul>
    <g:set var="maxMatches" value="${100}"/>
    <g:hiddenField name="replMaximum" value="${ruleApplications.size()}"/>
    <g:each in="${ruleApplications}" var="application" status="i">
        <g:if test="${i < maxMatches}">

            <li class="errorList">
                <g:set var="ruleMatch" value="${application.getRuleMatch()}"/>
                <g:set var="rule" value="${ruleMatch.getRule()}"/>
                <g:set var="startMarker" value="${application.getErrorMarkerStart()}"/>
                <g:set var="startPos" value="${application.getOriginalText().indexOf(startMarker)}"/>
                <g:set var="endMarker" value="${application.getErrorMarkerEnd()}"/>
                <g:set var="endPos" value="${application.getOriginalText().indexOf(endMarker) - startMarker.length()}"/>
                <g:if test="${rule instanceof PatternRule}">
                    <g:link controller="rule" action="show" id="${rule.getId()}"
                            params="${[lang: lang, subId: rule.getSubId()]}">${ruleMatch.getMessage().
                    replace('<suggestion>', '<span class=\'correction\'>').replace('</suggestion>', '</span>')}</g:link>
                </g:if>
                <g:else>
                    <g:link controller="rule" action="show" id="${rule.getId()}"
                            params="${[lang: lang]}">${rule.getDescription()}</g:link>
                </g:else>
                <br/>

                ${application.getOriginalErrorContext(40)}<br/>
                <g:set var="matcher" value="${spanPattern.matcher(application.getCorrectedErrorContext(40))}"/>

                <g:set var="replacement" value="${'<input id=\'repl' + i + '\' type=\'text\' value=\'$1\' />'}"/>
                <g:hiddenField name="repl${i}Start" value="${startPos}"/>
                <g:hiddenField name="repl${i}End" value="${endPos}"/>
                <g:set var="newCorrectionText" value="${matcher.replaceAll(replacement)}"/>
                <g:if test="${!application.hasRealReplacement()}">
                    <g:set var="replacementCss" value="replacementWarning"/>
                </g:if>
                <g:else>
                    <g:set var="replacementCss" value=""/>
                </g:else>

                <span class="${replacementCss}">&hellip;${newCorrectionText}&hellip;</span>
            </li>

        </g:if>
        <g:elseif test="${i == maxMatches}">
            <div class="warn">More than ${maxMatches} possible errors found, stopping</div>
        </g:elseif>
        <g:else>
            <%-- nothing --%>
        </g:else>
    </g:each>
</ul>
