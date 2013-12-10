<%@page import="org.languagetool.*" %>
<ul>
    <g:each in="${matches}" var="matchInfo" status="i">
        <li class="errorList">${matchInfo.match.getMessage()}:
        	<g:set var="cleanText" value="${StringTools.cleanError(matchInfo.match.getErrorContext())}"/>
			<g:link controller="rule" action="show" id="${matchInfo.match.ruleID}"
           		params="${[lang: lang, textToCheck: cleanText]}"><span class="additional"><g:message
           		code="ltc.check.visit.rule"/></span></g:link><br/>
           <span class="exampleSentence">${matchInfo.match.getErrorContext().
            replaceAll("<err>", "<span class='error'>").replaceAll("</err>", "</span>")}</span>
            <br />
            <g:link class="sourceLink" url="${matchInfo.match.sourceURI}"><g:message code="ltc.visit.source.page"/></g:link>
        </li>
    </g:each>
    <g:if test="${matches.size() == 0}">
       <li><g:message code="ltc.no.examples.errors" args="${[langCode.encodeAsHTML()]}"/></li>
    </g:if>
</ul>
<g:if test="${matches.size() > 0}">
    <g:link controller="homepage"
       params="[lang:params.lang.encodeAsHTML()]"><g:message code="ltc.show.random.examples"/></g:link>
    <br/>
    <a href="http://wiki.languagetool.org/make-languagetool-better"><g:message code="ltc.make.languagetool.better"/></a>
</g:if>
