
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
            
            <form>
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
                <select name="filter">
                    <option value="">- all non-hidden rules -</option>
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
                    <g:each in="${corpusMatchList}" status="i" var="match">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td>
                            	<g:set var="cleanText" value="${StringTools.cleanError(match.errorContext)}"/>
                                <div style="color: #666666; font-weight: bold; width:60%">
                                    ${StringTools.formatError(match.message.encodeAsHTML())}
                                    <g:link controller="rule" action="show" id="${match.ruleID}"
                          							params="${[lang: lang, subId: match.ruleSubID, textToCheck: cleanText]}"><g:message code="ltc.check.visit.rule"/></g:link>
                                </div>
                                <div style="margin-bottom: 5px; margin-top: 5px; margin-left: 20px;">
                                    ${StringTools.formatError(match.errorContext.encodeAsHTML())}<br />
                                </div>
                                <span class="additional">Article: <g:link class="additional" url="${match.sourceURI}">${match.sourceURI.replaceFirst("http://..\\.wikipedia\\.org/wiki/", "").encodeAsHTML()}</g:link></span>
                                <span class="additional"> (${StringTools.formatDate(match.corpusDate).encodeAsHTML()})</span>
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
