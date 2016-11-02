

<div id="wrongSentenceEvaluation" class="sentenceAnalysis">
<g:each in="${analyzedSentences}" var="sentence">
    <table style="margin-top: 4px; margin-bottom: 15px; border-style: none">
        <tr>
            <td style="font-weight: bold">Token</td>
            <g:each in="${sentence.getTokensWithoutWhitespace()}" var="token" status="i">
                <td>${token.getToken().encodeAsHTML()}</td>
            </g:each>
        </tr>
        <tr>
            <td style="font-weight: bold">Lemma</td>
            <g:each in="${sentence.getTokensWithoutWhitespace()}" var="token" status="i">
                <td>
                    <g:set var="prevLemma" value=""/>
                    <span class="pos">
                        <g:each in="${token.getReadings()}" var="reading">
                            <g:if test="${reading.getLemma() != prevLemma}">
                                <g:if test="${reading.getLemma()}">
                                    ${reading.getLemma().encodeAsHTML()}<br/>
                                </g:if>
                                <g:else>
                                    -
                                </g:else>
                            </g:if>
                            <g:set var="prevLemma" value="${reading.getLemma()}"/>
                        </g:each>
                    </span>
                </td>
            </g:each>
        </tr>
        <tr>
            <td style="font-weight: bold">
                Part-of-Speech<br/>
                <g:link target="_blank" controller="ruleEditor2" action="posTagInformation" params="${[lang:language.getShortCode()]}">Help</g:link>
            </td>
            <g:each in="${sentence.getTokensWithoutWhitespace()}" var="token" status="i">
                <td>
                    <span class="pos">
                        <g:each in="${token.getReadings()}" var="reading">
                            <g:if test="${reading.getPOSTag()}">
                                ${reading.getPOSTag().encodeAsHTML()}<br/>
                            </g:if>
                            <g:else>
                                -
                            </g:else>
                        </g:each>
                    </span>
                </td>
            </g:each>
        </tr>
        <tr>
            <td style="font-weight: bold">Chunk</td>
            <g:each in="${sentence.getTokensWithoutWhitespace()}" var="token" status="i">
                <td>
                    <span class="pos">
                        <g:each in="${token.getChunkTags()}" var="chunk">
                            <span class="chunk">${chunk.encodeAsHTML()}</span><br/>
                        </g:each>
                    </span>
                </td>
            </g:each>
        </tr>
    </table>
    <g:if test="${sentence.getAnnotations().trim() == 'Disambiguator log:'}">
        <pre class="disambiguatorLog">Disambiguator log: (no disambiguations)</pre>
    </g:if>
    <g:else>
        <pre class="disambiguatorLog">${sentence.getAnnotations().encodeAsHTML().replace("\n\n", "\n")}</pre>
    </g:else>
</g:each>
</div>
