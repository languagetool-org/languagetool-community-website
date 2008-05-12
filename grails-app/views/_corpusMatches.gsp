<%@page import="org.languagetool.*" %>
<ul>
    <g:each in="${matches}" var="matchInfo" status="i">
        <li class="errorList">${matchInfo.match.getMessage()}:<br/>
           <span class="exampleSentence">${matchInfo.match.getErrorContext().
            replaceAll("<err>", "<span class='error'>").replaceAll("</err>", "</span>")}</span>
            <br />
            
            <g:if test="${session.user}">
                <g:if test="${matchInfo.opinion == CorpusMatchController.NEGATIVE_OPINION}">
                   [voted as useless]
                </g:if>
                <g:elseif test="${matchInfo.opinion == CorpusMatchController.POSITIVE_OPINION}">
                   [voted as useful]
                </g:elseif>
                <g:else>
                    <div id="opinion_${i}">
                        <g:remoteLink controller="corpusMatch" action="markUseful" update="opinion_${i}"
                            id="${matchInfo.match.id}">Mark error message as useful</g:remoteLink>
                        <br />
                        <g:remoteLink controller="corpusMatch" action="markUseless" update="opinion_${i}"
                            id="${matchInfo.match.id}">Mark error message as useless/incorrect</g:remoteLink>
                    </div>
                </g:else>
            </g:if>
            <g:else>
               <g:link controller="user" action="login" 
                params="[lang: langCode, ids: matches.match.id]">Login to vote on this message</g:link>
            </g:else>
            <p>
                <g:link url="${matchInfo.match.sourceURI}">Visit Wikipedia page</g:link>
            </p>
        </li>
    </g:each>
    <g:if test="${matches.size() == 0}">
       <li>Sorry, no example error messages found in the database for language '${langCode.encodeAsHTML()}'</li>
    </g:if>
    <g:if test="${matches.size() > 0}">
        <li><g:link controller="homepage"
           params="[lang:params.lang.encodeAsHTML()]">Show other random examples</g:link></li>
    </g:if>
</ul>
