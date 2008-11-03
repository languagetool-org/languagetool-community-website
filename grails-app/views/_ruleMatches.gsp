<%@page import="de.danielnaber.languagetool.Language" %>

<ul>
    <g:each in="${matches}" var="matchInfo" status="i">
        <li class="errorList">${matchInfo.getMessage().
            replaceAll("<suggestion>", "<span class='correction'>").
            replaceAll("</suggestion>", "</span>")}
           <g:link controller="rule" action="show" id="${matchInfo.getRule().getId()}"
           	params="${[lang: lang]}"><span class="additional"><g:message code="ltc.check.visit.rule"/></span></g:link>
           <br/>
           <span class="exampleSentence">${
           de.danielnaber.languagetool.gui.Tools.getContext(matchInfo.getFromPos(),
           matchInfo.getToPos(), textToCheck,
           100, "<span class='error'>", "</span>", true)}</span>
            <br />
        </li>
    </g:each>
    <g:if test="${matches.size() == 0}">
       <li><g:message code="ltc.no.rule.matches" args="${[Language.getLanguageForShortName(params.lang)]}"/></li>
    </g:if>
</ul>
