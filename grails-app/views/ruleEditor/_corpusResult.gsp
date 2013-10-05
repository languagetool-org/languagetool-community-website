<%@ page import="org.apache.commons.lang.StringUtils" %>
<g:if test="${searcherResult}">
    <g:set var="sentencesChecked" value="${formatNumber(number:searcherResult.getCheckedSentences(), type: 'number')}"/>
    <g:set var="docsChecked" value="${formatNumber(number:searcherResult.getDocCount(), type: 'number')}"/>

    <g:if test="${searcherResult.getMatchingSentences().size() > 0}">

        <table>
            <tr>
                <td valign="top"><img style="margin:10px" align="left" src="${resource(dir:'images', file:'information.png')}" /></td>
                <td>
                    <p style="width:700px;">
                        <g:message code="ltc.editor.corpus.intro.problem" args="${[docsChecked, params.language.encodeAsHTML()]}"/>
                        <g:if test="${searcherResult.getMatchingSentences().size() == limit}">
                            <g:message code="ltc.editor.corpus.limit"/>
                        </g:if>
                    </p>

                    <ul style="margin-bottom: 10px">
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
                                        <span title="${StringUtils.join(token.getReadings(), ", ").encodeAsHTML()}">${token.getToken().encodeAsHTML()}</span>
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
                        <li style="list-style-type: none;" class="metaInfo"><g:message code="ltc.editor.corpus.source" /> <a target="_blank" href="http://www.wikipedia.org">Wikipedia</a>,
                            <g:message code="ltc.editor.corpus.license" /> <a target="_blank" href="http://creativecommons.org/licenses/by-sa/3.0/legalcode">Creative Commons Attribution-ShareAlike 3.0 Unported</a></li>
                    </ul>
                </td>
            </tr>
        </table>

    </g:if>
    <g:else>

        <table>
            <tr>
                <td><img style="margin:5px" src="${resource(dir:'images', file:'accept.png')}" /></td>
                <td>
                    <p style="width:700px;">
                        <g:message code="ltc.editor.corpus.intro" args="${[docsChecked, params.language.encodeAsHTML()]}"/>
                    </p>
                </td>
            </tr>
        </table>

    </g:else>

    <table>
        <tr>
            <td valign="top"><img style="margin:5px" align="left" src="${resource(dir:'images', file:'accept.png')}" /></td>
            <td>
                <g:message code="ltc.editor.corpus.correct.example.sentence"/>
                <g:if test="${incorrectExamplesMatches}">
                    <p><g:message code="ltc.editor.corpus.incorrect.example.sentence"/></p>
                    <g:render template="/ruleMatches" model="${[matches: incorrectExamplesMatches, textToCheck: incorrectExamples, hideRuleLink: true]}"/>
                </g:if>
            </td>
        </tr>
    </table>

</g:if>
<g:else>
    <g:if test="${timeOut}">
        <p class="warn">
            <g:message code="ltc.editor.corpus.timeout"/>
        </p>
    </g:if>
</g:else>
