<%@page import="org.languagetool.*" %>
<ul>
    <g:each in="${matches}" var="matchInfo" status="i">
        <li class="errorList">${matchInfo.match.getMessage()}:
			<g:link controller="rule" action="show" id="${matchInfo.match.ruleID}"
           		params="${[lang: lang]}"><span class="additional"><g:message code="ltc.check.visit.rule"/></span></g:link><br/>
           <span class="exampleSentence">${matchInfo.match.getErrorContext().
            replaceAll("<err>", "<span class='error'>").replaceAll("</err>", "</span>")}</span>
            <br />
            
            <g:if test="${session.user}">
                <g:if test="${matchInfo.opinion == CorpusMatchController.NEGATIVE_OPINION}">
                   <g:message code="ltc.voted.useless"/>
                </g:if>
                <g:elseif test="${matchInfo.opinion == CorpusMatchController.POSITIVE_OPINION}">
                   <g:message code="ltc.voted.useful"/>
                </g:elseif>
                <g:else>
                    <div id="opinion_${i}">
                        <noscript><b><g:message code="ltc.javascript.required"/></b><br /></noscript>
                        <g:remoteLink controller="corpusMatch" action="markUseful" update="opinion_${i}"
                            id="${matchInfo.match.id}"><g:message code="ltc.vote.useful"/></g:remoteLink>
                        <br />
                        <g:remoteLink controller="corpusMatch" action="markUseless" update="opinion_${i}"
                            id="${matchInfo.match.id}"><g:message code="ltc.vote.useless"/></g:remoteLink>
                    </div>
                </g:else>
            </g:if>
            <g:else>
               <g:link controller="user" action="login" 
                params="[lang: langCode, ids: matches.match.id]"><g:message code="ltc.login.to.vote"/></g:link>
            </g:else>
            <p>
                <g:link url="${matchInfo.match.sourceURI}"><g:message code="ltc.visit.wikipedia.page"/></g:link>
            </p>
        </li>
    </g:each>
    <g:if test="${matches.size() == 0}">
       <li><g:message code="ltc.no.examples.errors" args="${[langCode.encodeAsHTML()]}"/></li>
    </g:if>
    <g:if test="${matches.size() > 0}">
        <li><g:link controller="homepage"
           params="[lang:params.lang.encodeAsHTML()]"><g:message code="ltc.show.random.examples"/></g:link></li>
        <li><g:link controller="corpusMatch" action="list" params="[lang: params.lang]"><g:message code="ltc.show.all.matches"/></g:link></li>
        <li><g:link controller="userOpinion" action="list" params="[lang: params.lang]"><g:message code="ltc.show.user.votes"/></g:link></li>
    </g:if>
</ul>
