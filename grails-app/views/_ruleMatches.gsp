<%@page import="org.languagetool.tools.ContextTools; org.languagetool.rules.patterns.PatternRule; org.languagetool.Language" %>

<ul>
    <g:set var="maxMatches" value="${100}"/>
    <g:each in="${matches}" var="matchInfo" status="i">
        <g:if test="${i < maxMatches}">

            <li class="errorList">
                ${matchInfo.getMessage().replaceAll("<suggestion>", "<span class='correction'>").replaceAll("</suggestion>", "</span>")}

                <g:if test="${!hideRuleLink}">
                    <g:set var="langParam" value="${language?.getShortNameWithCountryAndVariant() ? language.getShortNameWithCountryAndVariant() : lang}"/>
                    <g:if test="${matchInfo.getRule() instanceof PatternRule}">
                        <g:link controller="rule" action="show" id="${matchInfo.getRule().getId()}"
                        params="${[lang: langParam, subId: matchInfo.getRule().getSubId()]}"><span class="additional"><g:message code="ltc.check.visit.rule"/></span></g:link>
                    </g:if>
                    <g:else>
                        <g:link controller="rule" action="show" id="${matchInfo.getRule().getId()}"
                        params="${[lang: langParam]}"><span class="additional"><g:message code="ltc.check.visit.rule"/></span></g:link>
                    </g:else>
                </g:if>

               <br/>
               <g:set var="css" value="${matchInfo.getRule().isSpellingRule() ? 'spellingError' : 'error'}"/>
                <%
                  ContextTools contextTools =  new ContextTools();
                  contextTools.setContextSize(100);
                  contextTools.setErrorMarkerStart("<span class='" + css + "'>");
                  contextTools.setErrorMarkerEnd("</span>");
                  contextTools.setEscapeHtml(true);
                %>
                <span class="exampleSentence">${contextTools.getContext(matchInfo.getFromPos(), matchInfo.getToPos(), textToCheck)}</span>
                <br />
            </li>

        </g:if>
        <g:elseif test="${i == maxMatches}">
            <div class="warn">More than ${maxMatches} possible errors found, stopping</div>
        </g:elseif>
        <g:else>
            <%-- nothing --%>
        </g:else>
    </g:each>
    <g:if test="${matches != null && matches.size() == 0 && params.lang && params.lang != 'auto'}">
       <li><g:message code="ltc.no.rule.matches" args="${[Language.getLanguageForShortName(params.lang)]}"/></li>
    </g:if>
    <g:elseif test="${matches != null && matches.size() == 0 && params.language && params.language != 'auto'}">
       <li><g:message code="ltc.no.rule.matches" args="${[Language.getLanguageForShortName(params.language)]}"/></li>
    </g:elseif>
</ul>
