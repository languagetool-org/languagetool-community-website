
<%@ page import="org.languagetool.CorpusMatch" %>
<%@ page import="org.languagetool.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.corpus.match.title"/> - ${language}</title>
    </head>
    <body>

        <div class="body">

            <g:render template="/languageSelection"/>

            <h1><g:message code="ltc.corpus.match.title"/> (${totalMatches})</h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
            
            <p><g:message code="ltc.corpus.match.note"/></p>
            
            <br />
            
            <form style="margin-bottom: 5px">
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
                <select name="filter">
                    <option value=""><g:message code="ltc.corpus.match.filter.all"/></option>
                    <g:each in="${matchesByRule}" var="rule">
                        <g:set var="ruleDesc" value="${rule[2]}"/>
                        <g:set var="hiddenText" value="${hiddenRuleIds.contains(rule[0]) ? ', hidden' : ''}"/>
                        <g:if test="${params.filter == rule[0]}">
                            <option selected value="${rule[0].encodeAsHTML()}">${ruleDesc.encodeAsHTML()} (${rule[1].encodeAsHTML()} matches${hiddenText})</option>
                        </g:if>
                        <g:else>
                            <option value="${rule[0].encodeAsHTML()}">${ruleDesc.encodeAsHTML()} (${rule[1].encodeAsHTML()} matches${hiddenText})</option>
                        </g:else>
                    </g:each>
                </select>
                <g:actionSubmit value="${message(code:'ltc.corpus.match.filter.submit')}" action="list"/>
            </form>
            
            <div class="list">
                <table>
                    <thead>
                        <tr>
                            <th><g:message code="ltc.corpus.match.match"/></th>
                        </tr>
                    </thead>
                    <tbody>
                    <g:set var="prevRuleId" value="${null}"/>
                    <g:each in="${corpusMatchList}" status="i" var="match">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                            <td>
                            	<g:set var="cleanText" value="${StringTools.cleanError(match.errorContext)}"/>

                                <g:if test="${match.ruleID != prevRuleId}">
                                    <div class="ruleMessage">
                                        <g:link controller="rule" action="show" id="${match.ruleID}"
                                                params="${[lang: lang, subId: match.ruleSubID, textToCheck: cleanText]}">${StringTools.formatError(match.message.encodeAsHTML())}</g:link>
                                    </div>
                                </g:if>
                                <g:set var="prevRuleId" value="${match.ruleID}"/>

                                <div style="margin-bottom: 5px; margin-top: 5px; margin-left: 20px;">
                                    ${StringTools.formatError(match.errorContext.encodeAsHTML())}
                                    <span class="additional"><g:link title="${message(code:'ltc.corpus.match.check.date')} ${StringTools.formatDate(match.corpusDate).encodeAsHTML()}" class="additional" url="${match.sourceURI}">${match.sourceURI.replaceFirst("http://..\\.wikipedia\\.org/wiki/", "").encodeAsHTML()}</g:link></span>
                                </div>

                            </td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${totalMatches}" 
                    params="${params}"/>
            </div>
        </div>
    </body>
</html>
