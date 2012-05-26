<%@page import="org.languagetool.rules.patterns.PatternRule; org.languagetool.Language" %>

<ul>
    <g:each in="${matches}" var="matchInfo" status="i">
        <li class="errorList">${matchInfo.getMessage().
            replaceAll("<suggestion>", "<span class='correction'>").
            replaceAll("</suggestion>", "</span>")}

            <g:if test="${matchInfo.getRule() instanceof PatternRule}">
                <g:link controller="rule" action="show" id="${matchInfo.getRule().getId()}"
               	params="${[lang: lang, subId: matchInfo.getRule().getSubId()]}"><span class="additional"><g:message code="ltc.check.visit.rule"/></span></g:link>
            </g:if>
            <g:else>
                <g:link controller="rule" action="show" id="${matchInfo.getRule().getId()}"
               	params="${[lang: lang]}"><span class="additional"><g:message code="ltc.check.visit.rule"/></span></g:link>
            </g:else>

           <br/>
           <span class="exampleSentence">${
           org.languagetool.gui.Tools.getContext(matchInfo.getFromPos(),
           matchInfo.getToPos(), textToCheck,
           100, "<span class='error'>", "</span>", true)}</span>
            <br />
        </li>
    </g:each>
    <g:if test="${matches != null && matches.size() == 0 && params.lang != 'auto'}">
       <li><g:message code="ltc.no.rule.matches" args="${[Language.getLanguageForShortName(params.lang)]}"/></li>
    </g:if>
</ul>
