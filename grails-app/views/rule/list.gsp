
<%@ page import="org.languagetool.StringTools" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.rule.browse.title" args="${[ruleCount, language]}" /></title>
    </head>
    <body>
    
        <div class="body">
        
            <g:render template="/languageSelection"/>

            <h1><g:message code="ltc.rule.browse.head" args="${[ruleCount]}" /></h1>
            
            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

            <p style="margin-top: 10px; margin-bottom: 10px"><g:message code="ltc.rule.browse.intro" args="${['https://languagetool.org', 'https://languagetool.org']}"/></p>
            
            <g:form action="list" method="get" name="filterform">
                <input type="hidden" name="offset" value="0"/>
                <input type="hidden" name="max" value="10"/>
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
                <g:textField name="filter" value="${params.filter}" placeholder="${message(code:'ltc.rule.browse.filter.placeholder')}"/>
                <g:select value="${categoryFilter}" noSelection="['': message(code:'ltc.rule.browse.select.category')]" from="${categories}" name="categoryFilter"/>
                <g:actionSubmit action="list" value="${message(code:'ltc.filter')}"/>
                <g:if test="${params.filter || params.categoryFilter}">
                    &nbsp;<g:link params="[lang : params.lang]">${message(code:'ltc.clear.filter')}</g:link>
                </g:if>
            </g:form>
                
            <div class="list">
                <table>
                    <thead>
                        <tr>

                            <g:sortableColumn property="description" title="${message(code:'ltc.rule.browse.description')}" />

                            <g:sortableColumn property="pattern" title="${message(code:'ltc.rule.browse.example')}" />
                            
                            <g:sortableColumn property="category" title="${message(code:'ltc.rule.browse.category')}" />
                            
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${ruleList}" status="i" var="rule">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                            <td>
                                <g:if test="${rule instanceof PatternRule}">
                                    <%
                                    PatternRule pRule = (PatternRule) rule;
                                    %>
                                    <g:set var="subId" value="${pRule.subId}"/>
                                    <g:link action="show" id="${rule.id}"
                                            params="[lang:params.lang, subId: subId]">${rule.description ? StringTools.escapeHtmlAndHighlightMatches(rule.description, params.filter) : "[unnamed]"}</g:link>
                                </g:if>
                                <g:else>
                                    <g:link action="show" id="${rule.id}"
                                            params="[lang:params.lang]">${rule.description ? StringTools.escapeHtmlAndHighlightMatches(rule.description, params.filter) : "[unnamed]"}</g:link>
                                </g:else>
                            </td>

                            <td>
                                <g:if test="${rule.getIncorrectExamples()?.size() > 0}">
                                    ${rule.getIncorrectExamples().get(0).example.encodeAsHTML()
                                            .replace("&lt;marker&gt;", "<span class='errorlight'>").replace("&lt;/marker&gt;", "</span>")}
                                </g:if>
                            </td>

                            <td>
                                <%
                                String categoryName = categoryName = StringTools.escapeHtmlAndHighlightMatches(rule.category.name, params.filter);
                                %>
                                ${categoryName}
                            </td>
                        
                        </tr>
                    </g:each>
                    <g:if test="${ruleList.size() == 0}">
                        <tr>
                            <td>${message(code:'ltc.filter.no.match')} <g:link params="[lang : params.lang]">${message(code:'ltc.clear.filter')}</g:link></td>
                        </tr>
                    </g:if>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${ruleCount}" params="${params}"/>
            </div>

            <g:render template="/languageToolVersion"/>

        </div>

    <script type="text/javascript">
        <!--
        var filter = document.filterform.filter;
        filter.focus();
        if (filter.setSelectionRange) {
            var length = filter.value.length;
            filter.setSelectionRange(length, length);  // place cursor at end
        }
        // -->
    </script>
        
    </body>
</html>
