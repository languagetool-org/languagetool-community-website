<%@page import="de.danielnaber.languagetool.Language" %>

<ul>
    <g:each in="${matches}" var="matchInfo" status="i">
        <li class="errorList">${matchInfo.getMessage().
            replaceAll("<suggestion>", "<span class='correction'>").
            replaceAll("</suggestion>", "</span>")}:<br/>
           <span class="exampleSentence">${
           de.danielnaber.languagetool.gui.Tools.getContext(matchInfo.getFromPos(),
           matchInfo.getToPos(), textToCheck,
           100, "<span class='error'>", "</span>", true)}</span>
            <br />
        </li>
    </g:each>
    <g:if test="${matches.size() == 0}">
       <li>No rule matches found in text (language used: ${Language.getLanguageForShortName(params.lang)})</li>
    </g:if>
</ul>
