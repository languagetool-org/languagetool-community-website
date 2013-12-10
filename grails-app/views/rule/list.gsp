
<%@ page import="org.languagetool.User" %>
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
        
            <g:form action="list" method="get" name="filterform">
                <input type="hidden" name="offset" value="0"/>
                <input type="hidden" name="max" value="10"/>
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
                <g:textField name="filter" value="${params.filter}" placeholder="${message(code:'ltc.rule.browse.filter.placeholder')}"/>
                <g:actionSubmit action="list" value="${message(code:'ltc.filter')}"/>
                <g:if test="${params.filter}">
                    &nbsp;<g:link params="[lang : params.lang]">Clear Filter</g:link>
                </g:if>
            </g:form>
                
            <div class="list">
                <table>
                    <thead>
                        <tr>

                            <g:sortableColumn property="description" title="${message(code:'ltc.rule.browse.description')}" />

                            <g:sortableColumn property="pattern" title="${message(code:'ltc.rule.browse.pattern')}" />
                            
                            <g:sortableColumn property="category" title="${message(code:'ltc.rule.browse.category')}" />
                            
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${ruleList}" status="i" var="rule">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                            <!-- TODO: find clean solution: -->
							<% String userRuleId = null; %>
                            <g:if test="${patternRuleIdToUserRuleId.containsKey(rule.id)}">
                            	<% userRuleId = patternRuleIdToUserRuleId.get(rule.id); %>
							</g:if>

                            <td>
                                <g:if test="${userRuleId}">
                                    <g:link action="show" id="${userRuleId}"
                                        params="[lang:params.lang]">${rule.description ? StringTools.escapeHtmlAndHighlightMatches(rule.description, params.filter) : "[unnamed]"}</g:link>
                                </g:if>
                                <g:else>
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
                                </g:else>
                            </td>

                            <g:if test="${rule instanceof PatternRule}">
                                <%
                                PatternRule pRule = (PatternRule) rule;
                                String patternDisplay = pRule.toPatternString();
                                patternDisplay = StringTools.shorten(patternDisplay, 80, "...");
                                patternDisplay = patternDisplay.replace(", ", " ");  // commas don't help the user to understand the pattern, remove them
                                patternDisplay = StringTools.escapeHtmlAndHighlightMatches(patternDisplay, params.filter);
                                %>
                                <td class="metaInfo">${patternDisplay}</td>
                            </g:if>
                            <g:else>
                                <td><g:message code="ltc.rule.browse.java.rule" /></td>
                            </g:else>

                            <td>
                                <%
                                String categoryName = categoryName = StringTools.escapeHtmlAndHighlightMatches(rule.category.name, params.filter);
                                %>
                                ${categoryName}
                            </td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${ruleCount}" params="${params}"/>
            </div>
            <!--
            <g:if test="${session.user}">
                <g:form method="post">
                   <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
                   <g:actionSubmit action="createRule" value="${message(code:'ltc.rule.browse.add.rule') }"/> &nbsp;
                </g:form>
            </g:if>
            -->

	        <g:if test="${session.user}">
	        	<br />
	        	<g:link controller="user" action="exportRules">Export the rules you added</g:link>
	        </g:if>

            <g:render template="/languageToolVersion"/>

        </div>
        
		<script type="text/javascript">
		<!--
		    document.filterform.filter.focus();
		// -->
		</script>
        
    </body>
</html>
