<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title><g:message code="ltc.analysis.title"/></title>
    <meta name="layout" content="main" />
    <g:render template="script"/>
</head>
<body>

<div class="body">

    <g:render template="/languageSelection"/>

    <div class="dialog">

        <h1><g:message code="ltc.analysis.head"/></h1>

        <p><g:message code="ltc.analysis.intro"/></p>

        <g:render template="textForm"/>

        <div class="textAnalysis">
        
            <h2>Analysis Result</h2>

            <div style="margin-bottom: 8px" class="metaInfo">
                LanguageTool version: ${JLanguageTool.VERSION} (${JLanguageTool.BUILD_DATE})<br/>
                Language: ${language.getName().encodeAsHTML()}
            </div>
        
            <p style="margin-bottom: 8px"><a href="https://github.com/languagetool-org/languagetool/blob/master/languagetool-language-modules/${language.shortCode}/src/main/resources/org/languagetool/resource/${language.shortCode}/tagset.txt">What do the tags mean?</a></p>
        
            <g:each in="${analyzedSentences}" var="sentence">
                <g:if test="${sentence.getAnnotations().trim() == 'Disambiguator log:'}">
                    <pre class="disambiguatorLog">Disambiguator log: (no disambiguations)</pre>
                </g:if>
                <g:else>
                    <pre class="disambiguatorLog">${sentence.getAnnotations().encodeAsHTML().replace("\n\n", "\n")}</pre>
                </g:else>
                <table style="margin-top: 4px; margin-bottom: 15px">
                    <tr>
                        <th>Token</th>
                        <th style="text-align: right">Lemma</th>
                        <th>Part-of-speech</th>
                        <th>Chunk</th>
                    </tr>
                    <g:each in="${sentence.getTokensWithoutWhitespace()}" var="token" status="i">
                        <tr class="${i % 2 == 0 ? 'even' : 'odd'}">
                            <td width="20%">${token.getToken().encodeAsHTML()}</td>
                            <td width="15%" style="text-align: right">
                                <g:set var="prevLemma" value=""/>
                                <g:each in="${token.getReadings()}" var="reading">
                                    <span class="pos">
                                        <g:if test="${reading.getLemma() != prevLemma}">
                                            <g:if test="${reading.getLemma()}">
                                                ${reading.getLemma().encodeAsHTML()}
                                            </g:if>
                                            <g:else>
                                                -
                                            </g:else>
                                        </g:if>
                                    </span><br/>
                                    <g:set var="prevLemma" value="${reading.getLemma()}"/>
                                </g:each>
                            </td>
                            <td width="20%">
                                <g:each in="${token.getReadings()}" var="reading">
                                    <span class="pos">
                                        <g:if test="${reading.getPOSTag()}">
                                            ${reading.getPOSTag().encodeAsHTML()}
                                        </g:if>
                                        <g:else>
                                            -
                                        </g:else>
                                    </span><br/>
                                </g:each>
                            </td>
                            <td width="45%">
                                <g:each in="${token.getChunkTags()}" var="chunk">
                                    <span class="chunk">${chunk.encodeAsHTML()}</span><br/>
                                </g:each>
                            </td>
                        </tr>
                    </g:each>
                </table>
            </g:each>
        </div>

    </div>

</div>

</body>
</html>