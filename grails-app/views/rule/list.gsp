
<%@ page import="org.languagetool.User" %>
<%@ page import="de.danielnaber.languagetool.rules.patterns.PatternRule" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Browse Rules</title>
    </head>
    <body>
    
        <div class="body">
        
            <h1>Browse Rules: ${ruleCount} matches</h1>
            
            <p>Switch language:
            <g:render template="/languageSelection"/>
            
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
                                <g:if test="${activeRules.contains(rule)}">
                                    Y
                                </g:if>
                                <g:else>
                                    N
                                </g:else>
                            </td>
                        
                            <td><g:link action="show" id="${rule.id}"
                                params="[lang:params.lang]">${rule.description ? rule.description.encodeAsHTML() : "[unnamed]"}</g:link></td>

                            <g:if test="${rule instanceof PatternRule}">
                                <%
                                PatternRule pRule = (PatternRule) rule;
                                %>
                                <td>${pRule.toPatternString()}</td>
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
        </div>
        
		<script type="text/javascript">
		<!--
		    document.filterform.filter.focus();
		// -->
		</script>
        
    </body>
</html>
