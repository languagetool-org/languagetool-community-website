<g:if test="${searcherResult}">
    <g:set var="sentencesChecked" value="${formatNumber(number:searcherResult.getCheckedSentences(), type: 'number')}"/>
    <g:set var="docsChecked" value="${formatNumber(number:searcherResult.getDocCount(), type: 'number')}"/>

    <g:if test="${searcherResult.getMatchingSentences().size() == 0}">

        <p style="width:700px;">We've checked your pattern against ${docsChecked} documents
        from the ${params.language.encodeAsHTML()} <a href="http://www.wikipedia.org">Wikipedia</a> and found no matches.
        That's a good sign, it means your rule doesn't trigger any false alarms at least
        in the documents we checked.</p>

        <p>Your example sentences are also correct.</p>

        <g:render template="submitRule"/>

    </g:if>
    <g:else>

        <p style="width:700px;">We've checked your pattern against ${docsChecked} documents
        from the ${params.language.encodeAsHTML()}
        <a href="http://www.wikipedia.org">Wikipedia</a> and found the following matches.
        <g:if test="${searcherResult.getMatchingSentences().size() == limit}">
            (showing only the first ${limit} matches)
        </g:if>
        Please consider modifying your rule if these matches are false alarms.
        <g:if test="${!expertMode}">
            As this page does not support our full rule syntax you might want to learn
            more in <a target="devdocumentation" href="http://www.languagetool.org/development/">our development
            documentation</a>.
        </g:if>
        </p>

        <ul style="margin-bottom: 30px">
            <g:each in="${searcherResult.getMatchingSentences()}" var="matchingSentence">
                <g:each in="${matchingSentence.getRuleMatches()}" var="match">
                    <li>
                        <span class="exampleSentence">${org.languagetool.gui.Tools.getContext(
                            match.getFromPos(), match.getToPos(),
                            matchingSentence.getSentence(),
                            100, "<span class='errorMarker'>", "</span>", true)}</span>
                    </li>
                </g:each>
            </g:each>
        </ul>

    </g:else>

</g:if>
<g:else>
    <g:if test="${timeOut}">
        <p class="warn">
            Sorry, there was a timeout when searching our Wikipedia data for matches. This can happen
            for patterns with some regular expressions, for example if the pattern starts with .*.
            These kinds of patterns are currently not supported by this tool. You can continue
            creating the rule anyway.
        </p>
    </g:if>
</g:else>
