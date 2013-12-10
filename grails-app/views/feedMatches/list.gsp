<%@ page import="org.languagetool.CorpusMatch" %>
<%@ page import="org.languagetool.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.feed.matches.title"/> - ${language}</title>
        <g:javascript library="jquery" />
        <script language="JavaScript">
            function markedAsFixedOrFalseAlarm(feedMatchId) {
                jQuery.ajax('${resource(dir:'feedMatches')}/markAsFixedOrFalseAlarm?id=' + feedMatchId,
                        {
                            type: 'POST',
                            success: function(data, textStatus, jqXHR) {
                                $('#ajaxFailure').html("");
                                $('#ajaxFeedback' + feedMatchId).html("${message(code:'ltc.feed.matches.marked')}");
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

            <h1><g:message code="ltc.feed.matches.title"/> (${totalMatches})</h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
            
            <br />
            
            <div id="ajaxFailure"></div>

            <form style="margin-bottom: 5px">
                <input type="hidden" name="lang" value="${lang.encodeAsHTML()}"/>
                
                <select name="notFixedFilter" onchange="this.form.submit()">
                    <option ${params.notFixedFilter == '-' ? 'selected' : ''} value="0"><g:message code='ltc.feed.matches.unfixed.no.filter' args="${[2]}"/></option>
                    <option ${params.notFixedFilter == '10' ? 'selected' : ''} value="10"><g:message code='ltc.feed.matches.unfixed.for.minutes' args="${[10]}"/></option>
                    <option ${params.notFixedFilter == '30' ? 'selected' : ''} value="30"><g:message code='ltc.feed.matches.unfixed.for.minutes' args="${[30]}"/></option>
                    <option ${params.notFixedFilter == '60' ? 'selected' : ''} value="60"><g:message code='ltc.feed.matches.unfixed.for.one.hour'/></option>
                    <option ${params.notFixedFilter == '120' ? 'selected' : ''} value="120"><g:message code='ltc.feed.matches.unfixed.for.hours' args="${[2]}"/></option>
                    <option ${params.notFixedFilter == '240' ? 'selected' : ''} value="240"><g:message code='ltc.feed.matches.unfixed.for.hours' args="${[4]}"/></option>
                    <option ${params.notFixedFilter == '480' ? 'selected' : ''} value="480"><g:message code='ltc.feed.matches.unfixed.for.hours' args="${[8]}"/></option>
                    <option ${params.notFixedFilter == '960' ? 'selected' : ''} value="960"><g:message code='ltc.feed.matches.unfixed.for.hours' args="${[16]}"/></option>
                    <option ${params.notFixedFilter == '1440' ? 'selected' : ''} value="1440"><g:message code='ltc.feed.matches.unfixed.for.hours' args="${[24]}"/></option>
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

            <g:if test="${languageMatchCount == 0}">
                <div class="warn"><g:message code="ltc.feed.matches.no.analysis"/></div>
            </g:if>

            <div class="list">
                <table>
                    <thead>
                        <tr>
                            <th><g:message code="ltc.feed.matches.edit.date"/></th>
                            <th><g:message code="ltc.corpus.match.match"/></th>
                        </tr>
                    </thead>
                    <tbody>
                    <g:set var="prevRuleId" value="${null}"/>
                    <g:each in="${corpusMatchList}" status="i" var="match">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                            <td>
                                <g:formatDate date="${match.editDate}" format="yyyy-MM-dd'&nbsp;'HH:mm"/>
                            </td>
                            
                            <td>
                                <g:set var="cleanText" value="${StringTools.cleanError(match.errorContext)}"/>

                                <g:if test="${match.ruleId != prevRuleId}">
                                    <div class="ruleMessage">
                                        <g:link controller="rule" action="show" id="${match.ruleId}"
                                                params="${[lang: lang, subId: match.ruleSubId, textToCheck: cleanText]}">${StringTools.formatError(match.ruleMessage.encodeAsHTML())}</g:link>
                                        <span class="category">${match.ruleCategory}</span>
                                    </div>
                                </g:if>
                                <g:set var="prevRuleId" value="${match.ruleId}"/>

                                <div style="margin-bottom: 5px; margin-top: 5px; margin-left: 20px;">
                                    <span style="font-family: monospace">${StringTools.formatError(match.errorContext.encodeAsHTML())}</span>
                                    <br/>
                                    <g:form method="post" onsubmit="return markedAsFixedOrFalseAlarm(${match.id})">
                                        <div style="margin-top: 5px">
                                            <g:set var="articleUrl" value="http://${match.languageCode.encodeAsHTML()}.wikipedia.org/wiki/${match.title.replace(' ', '_').encodeAsURL()}"/>
                                            <a class="additionalFeedMatchLink" href="http://${match.languageCode.encodeAsURL()}.wikipedia.org/w/index.php?title=${match.title.replace(' ', '_').encodeAsURL()}&diff=${match.diffId}"
                                                ><g:message code="ltc.feed.matches.diff"/></a>
                                            &middot; <g:link class="additionalFeedMatchLink" controller="wikiCheck" action="index"
                                                params="${[url:articleUrl, enabled:match.ruleId]}"><g:message code="ltc.wikicheck.check.again"/></g:link>
                                            &middot; <a class="additionalFeedMatchLink" href="${articleUrl}">${match.title.encodeAsHTML()}</a>
                                            <g:if test="${session.user}">
                                                &middot;
                                                <span id="ajaxFeedback${match.id}">
                                                    <input type="submit" value="${message(code:'ltc.feed.matches.mark')}"/>
                                                </span>
                                            </g:if>
                                        </div>
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

            <p style="margin-top: 5px"><a href="http://wiki.languagetool.org/make-languagetool-better"><g:message code="ltc.make.languagetool.better"/></a></p>

        </div>
    
    </body>
</html>
