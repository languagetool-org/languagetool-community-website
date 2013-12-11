
<%@ page import="org.languagetool.CorpusMatch" %>
<%@ page import="org.languagetool.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.corpus.match.title"/> - ${language}</title>
        <g:javascript library="jquery" />
        <script language="JavaScript">
            function markedAsFixedOrFalseAlarm(corpusMatchId) {
                jQuery.ajax('${resource(dir:'corpusMatch')}/markAsFixedOrFalseAlarm?id=' + corpusMatchId,
                        {
                            type: 'POST',
                            success: function(data, textStatus, jqXHR) {
                                if (data == "ok") {
                                    $('#ajaxFailure').html("");
                                    $('#ajaxFeedback' + corpusMatchId).html("${message(code:'ltc.feed.matches.marked')}");
                                } else {
                                    $('#ajaxFailure').html("<div class='warn'>Sorry, submitting your vote failed. Are you still logged in?</div>");
                                }
                            },
                            error: function(jqXHR, textStatus, errorThrown) {
                                $('#ajaxFailure').html("<div class='warn'>Sorry, submitting your vote failed</div>");
                            }
                        });
                return false;
            }
        </script>
    </head>
    <body>

        <div class="body">

            <g:render template="/languageSelection"/>

            <h1><g:message code="ltc.corpus.match.title"/> (${totalMatches})</h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

            <p><g:message code="ltc.check.explain"/> <g:message code="ltc.corpus.match.note"/></p>
            
            <br />

            <div id="ajaxFailure"></div>
            
            <form style="margin-bottom: 5px">
                <input type="hidden" name="lang" value="${lang.encodeAsHTML()}"/>
                <select name="typeFilter" onchange="this.form.submit()">
                    <g:if test="${params.typeFilter == ''}">
                        <option value="" selected>Wikipedia &amp; Tatoeba</option>
                    </g:if>
                    <g:else>
                        <option value="">Wikipedia &amp; Tatoeba</option>
                    </g:else>
                    <g:if test="${params.typeFilter == 'wikipedia'}">
                        <option value="wikipedia" selected>Wikipedia</option>
                    </g:if>
                    <g:else>
                        <option value="wikipedia">Wikipedia</option>
                    </g:else>
                    <g:if test="${params.typeFilter == 'tatoeba'}">
                        <option value="tatoeba" selected>Tatoeba</option>
                    </g:if>
                    <g:else>
                        <option value="tatoeba">Tatoeba</option>
                    </g:else>
                </select>
                <select name="categoryFilter" onchange="this.form.filter.value='';this.form.submit()">
                    <option value=""><g:message code="ltc.corpus.match.category.filter.all"/></option>
                    <g:each in="${matchesByCategory}" var="category">
                        <g:set var="categoryName" value="${category[2]}"/>
                        <g:if test="${params.categoryFilter == category[0]}">
                            <option selected value="${category[0].encodeAsHTML()}">${categoryName.encodeAsHTML()}</option>
                        </g:if>
                        <g:else>
                            <option value="${category[0].encodeAsHTML()}">${categoryName.encodeAsHTML()}</option>
                        </g:else>
                    </g:each>
                </select>
                <select name="filter" onchange="this.form.submit()">
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
                <noscript>
                    <g:actionSubmit value="${message(code:'ltc.corpus.match.filter.submit')}" action="list"/>
                </noscript>
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
                                        <span class="category">${match.ruleCategory}</span>
                                    </div>
                                </g:if>
                                <g:set var="prevRuleId" value="${match.ruleID}"/>

                                <div style="margin-bottom: 5px; margin-top: 5px; margin-left: 20px;">
                                    <g:form method="post" onsubmit="return markedAsFixedOrFalseAlarm(${match.id})">
                                        ${StringTools.formatError(match.errorContext.encodeAsHTML())}
                                        <span class="additional"><g:link title="${message(code:'ltc.corpus.match.check.date')} ${StringTools.formatDate(match.checkDate).encodeAsHTML()}" class="additional" url="${match.sourceURI}">${match.sourceURI.replaceFirst("http://..\\.wikipedia\\.org/wiki/", "").encodeAsHTML()}</g:link></span>
                                        <g:if test="${!match.sourceURI.startsWith('http://tatoeba.org')}">
                                            <span class="additional"> - <g:link class="additional" controller="wikiCheck" action="index"
                                                                                params="${[url:match.sourceURI.replace(' ', '_'), enabled:match.ruleID]}"><g:message code="ltc.wikicheck.check.again"/></g:link></span>
                                        </g:if>
                                        <g:if test="${session.user}">
                                            &middot;
                                            <span id="ajaxFeedback${match.id}">
                                                <input type="submit" value="${message(code:'ltc.feed.matches.mark')}"/>
                                            </span>
                                        </g:if>
                                    </g:form>
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

            <g:if test="${date}">
                <p class="metaInfo" style="text-align: right"><g:message code="ltc.corpus.match.last.check" args="${[formatDate(format: 'yyyy-MM-dd', date: date)]}"/></p>
            </g:if>

            <p style="margin-top: 5px"><a href="http://wiki.languagetool.org/make-languagetool-better"><g:message code="ltc.make.languagetool.better"/></a></p>

        </div>
    
    </body>
</html>
