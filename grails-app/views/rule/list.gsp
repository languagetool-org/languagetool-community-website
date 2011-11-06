
<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.StringTools" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.rule.browse.title" args="${[ruleCount]}" /></title>
    </head>
    <body>
    
        <div class="body">
        
            <g:render template="/languageSelection"/>

            <h1><g:message code="ltc.rule.browse.title" args="${[ruleCount]}" /></h1>
            
            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
        
            <g:form action="list" method="get" name="filterform">
                <input type="hidden" name="offset" value="0"/>
                <input type="hidden" name="max" value="10"/>
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
                <g:textField name="filter" value="${params.filter}"/>
                <g:actionSubmit action="list" value="${message(code:'ltc.filter')}"/>
                <g:if test="${params.filter}">
                    &nbsp;<g:link params="[lang : params.lang]">Clear Filter</g:link>
                </g:if>
            </g:form>
                
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                            <td><g:message code="ltc.rule.browse.active" /></td>

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
                                <g:if test="${session.user}">
	                                <g:if test="${disabledRuleIDs != null && (disabledRuleIDs.contains(rule.id) || disabledRuleIDs.contains(userRuleId))}">
	                                    -
	                                </g:if>
	                                <g:else>
	                                    <g:message code="ltc.rule.browse.active.yes" />
	                                </g:else>
                                </g:if>
                                <g:else>
                                    n/a
                                </g:else>
                            </td>
                        
                            <td>
                            <g:if test="${userRuleId}">
	                            <g:link action="show" id="${userRuleId}"
    	                            params="[lang:params.lang]">${rule.description ? rule.description.encodeAsHTML() : "[unnamed]"}</g:link></td>
                            </g:if>
                            <g:else>
	                            <g:link action="show" id="${rule.id}"
    	                            params="[lang:params.lang]">${rule.description ? rule.description.encodeAsHTML() : "[unnamed]"}</g:link></td>
                            </g:else>

                            <g:if test="${rule instanceof PatternRule}">
                                <%
                                PatternRule pRule = (PatternRule) rule;
                                String patternDisplay = pRule.toPatternString();
                                patternDisplay = StringTools.shorten(patternDisplay, 80, "...");
                                %>
                                <td>${patternDisplay.encodeAsHTML()}</td>
                            </g:if>
                            <g:else>
                                <td><g:message code="ltc.rule.browse.java.rule" /></td>
                            </g:else>

                            <td>${rule.category.name}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${ruleCount}" params="${params}"/>
            </div>
            <g:form method="post">
               <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
 	           <g:actionSubmit action="createRule" value="${message(code:'ltc.rule.browse.add.rule') }"/> &nbsp;
            </g:form>

	        <g:if test="${session.user}">
	        	<br />
	        	<g:link controller="user" action="exportRules">Export the rules you added</g:link>
	        </g:if>

        </div>
        
		<script type="text/javascript">
		<!--
		    document.filterform.filter.focus();
		// -->
		</script>
        
    </body>
</html>
