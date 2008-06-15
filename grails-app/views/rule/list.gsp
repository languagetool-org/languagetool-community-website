
<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.StringTools" %>
<%@ page import="de.danielnaber.languagetool.rules.patterns.PatternRule" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title>Browse Rules</title>
    </head>
    <body>
    
        <div class="body">
        
            <g:render template="/languageSelection"/>

            <h1>Browse Rules: ${ruleCount} matches</h1>
            
            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
        
            <g:form action="list" method="get" name="filterform">
                <input type="hidden" name="offset" value="0"/>
                <input type="hidden" name="max" value="10"/>
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
                <g:textField name="filter" value="${params.filter}"/>
                <g:actionSubmit value="Filter"/>
                <g:if test="${params.filter}">
                    &nbsp;<g:link params="[lang : params.lang]">Clear Filter</g:link>
                </g:if>
            </g:form>
                
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                            <td>Active?</td>

                   	        <g:sortableColumn property="description" title="Description" />

                            <g:sortableColumn property="pattern" title="Pattern" />
                            
                            <g:sortableColumn property="category" title="Category" />
                            
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${ruleList}" status="i" var="rule">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td>
                                <g:if test="${session.user}">
	                                <g:if test="${disabledRuleIDs != null && disabledRuleIDs.contains(rule.id)}">
	                                    -
	                                </g:if>
	                                <g:else>
	                                    yes
	                                </g:else>
                                </g:if>
                                <g:else>
                                    n/a
                                </g:else>
                            </td>
                        
                            <td>
                            <g:if test="${rule.id.contains('//')}">
	                            <g:link action="show" id="${rule.id.split('//')[1]}"
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
                                <td>[Java rule]</td>
                            </g:else>

                            <td>${rule.category.name}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${ruleCount}" params="[params]"/>
            </div>
            <g:form method="post">
               <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
 	           <g:actionSubmit action="createRule" value="Add New Rule"/> &nbsp;
            </g:form>
        </div>
        
		<script type="text/javascript">
		<!--
		    document.filterform.filter.focus();
		// -->
		</script>
        
    </body>
</html>
