<g:if test="${searcherResult}">
    <g:set var="sentencesChecked" value="${formatNumber(number:searcherResult.getCheckedSentences(), type: 'number')}"/>

    <g:if test="${searcherResult.getMatchingSentences().size() == 0}">

        <p style="width:700px;">We've checked your pattern against ${sentencesChecked} sentences
        from <a href="http://www.wikipedia.org">Wikipedia</a> and found no matches.</p>

    </g:if>
    <g:else>

        <p style="width:700px;">We've checked your pattern against ${sentencesChecked} sentences
        from <a href="http://www.wikipedia.org">Wikipedia</a> and found the following matches
        <g:if test="${searcherResult.getMatchingSentences().size() == limit}">
            (showing only the first ${limit} matches).
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
</g:else>
