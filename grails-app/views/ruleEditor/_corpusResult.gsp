<g:if test="${searcherResult}">
    <g:set var="sentencesChecked" value="${formatNumber(number:searcherResult.getCheckedSentences(), type: 'number')}"/>
    <g:set var="docsChecked" value="${formatNumber(number:searcherResult.getDocCount(), type: 'number')}"/>

    <g:if test="${searcherResult.getMatchingSentences().size() == 0}">

        <p style="width:700px;"><g:message code="ltc.editor.corpus.intro" args="${[docsChecked, params.language.encodeAsHTML()]}"/></p>

        <p><g:message code="ltc.editor.corpus.correct.example.sentence"/></p>

    </g:if>
    <g:else>

        <p style="width:700px;"><g:message code="ltc.editor.corpus.intro.problem" args="${[docsChecked, params.language.encodeAsHTML()]}"/>
        <g:if test="${searcherResult.getMatchingSentences().size() == limit}">
            <g:message code="ltc.editor.corpus.limit"/>
        </g:if>
        </p>

        <ul style="margin-bottom: 30px">
            <g:each in="${searcherResult.getMatchingSentences()}" var="matchingSentence">
                <g:each in="${matchingSentence.getRuleMatches()}" var="match">
                    <li>
                        <g:set var="pos" value="${0}"/>
                        <g:set var="startMarked" value="${false}"/>
                        <g:set var="endMarked" value="${false}"/>
                        <g:each in="${matchingSentence.getAnalyzedSentence().getTokens()}" var="token">
                            <g:if test="${pos >= match.getFromPos() && !startMarked}">
                                <span class='errorMarker'>
                                <g:set var="startMarked" value="${true}"/>
                            </g:if>
                            <span title="${token.getReadings().encodeAsHTML()}">${token.getToken().encodeAsHTML()}</span>
                            <g:if test="${pos >= match.getToPos() && !endMarked}"></span>
                                <g:set var="endMarked" value="${true}"/>
                            </g:if>
                            <%
                               pos += token.getToken().length();
                            %>
                        </g:each>
                    </li>
                </g:each>
            </g:each>
        </ul>

    </g:else>

</g:if>
<g:else>
    <g:if test="${timeOut}">
        <p class="warn">
            <g:message code="ltc.editor.corpus.timeout"/>
        </p>
    </g:if>
</g:else>
