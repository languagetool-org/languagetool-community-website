
<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.edit.rule.named" args="${[rule.description.encodeAsHTML()]}"/></title>
    </head>
    <body>

        <div class="body">
        
            <g:form method="post">
            
            <input type="hidden" name="id" value="${ruleId.encodeAsHTML()}"/>
            <g:if test="${params.lang}">
	            <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
            </g:if>
            <g:else>
            	<input type="hidden" name="lang" value="${lang.encodeAsHTML()}"/>
            </g:else>
            
            <g:if test="${ruleId}">
	            <h1><g:message code="ltc.edit.rule" /></h1>
            </g:if>
            <g:else>
	            <h1><g:message code="ltc.edit.add.rule" /></h1>
            </g:else>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
            
            <table>
                <tr>
                    <td width="15%"><g:message code="ltc.edit.pattern" /></td>
                    <td>
                    	<% int i = 0; %>
                    	<table border="0">
                    		<g:checkBox id="case_sensitive" name="case_sensitive"
   	                			value="${rule.patternElements[i]?.getCaseSensitive()}"/>
       	            			<label for="case_sensitive">Case sensitive</label>
                    	
                    	<g:while test="${i < grailsApplication.config.maxPatternElements}">
                    		<tr>
	                    	<td align="middle">${i+1}.</td>
	                    	<td>
	                    		<g:textField class="pattern" size="50" name="pattern_${i}"
		                    		value="${rule.patternElements[i]}"/><br />
		                    		<!-- 
		                    		<g:checkBox id="regexp_${i}" name="regexp_${i}"
	    	                			value="fixme"/>
	        	            			<label for="regexp_${i}">Regular expression</label> -->
	                    	</td>
	                    	</tr>
	                    	<% i++ %>
                    	</g:while>
                    	</table>
                    </td>
                </tr>
                <tr>
                    <td><g:message code="ltc.edit.description" /></td>
                    <td><g:textField size="60" name="description" value="${rule.description}"/></td>
                </tr>
                
                <tr>
                    <td><g:message code="ltc.edit.message" /></td>
                    <td><g:textField size="60" name="message" value="${rule.message}"/></td>
                </tr>
                
                <!-- TODO:
                <tr>
                    <td>Incorrect sentences that this rule can detect:</td>
                    <td>
			            <ul>
			            <g:each var="example" in="${rule.getIncorrectExamples()}">
			                <li>${example.getExample().encodeAsHTML().
			                    replace("&lt;marker&gt;", '<span class="error">').
			                    replace("&lt;/marker&gt;", '</span>')
			                    }
			                    <g:if test="${example.getCorrections()}">
    			                    <br />Correction suggestion:
			                        <span class="correction">${StringTools.listToString(example.getCorrections(), ", ")}</span>
			                    </g:if>
			                </li>
			            </g:each>
			            </ul>
                        <g:if test="${rule.getIncorrectExamples() == null}">
                             <span class="additional">[no examples found]</span>
                        </g:if>
                    </td>
                </tr>
                
                <tr>
                    <td>Correct sentences for comparison:</td>
                    <td>
			            <ul>
			            <g:each var="example" in="${rule.getCorrectExamples()}">
			                <li>${example.encodeAsHTML().
			                     replace("&lt;marker&gt;", '<b>').
			                     replace("&lt;/marker&gt;", '</b>')}</li>
			            </g:each>
			            </ul>
                        <g:if test="${rule.getCorrectExamples() == null}">
                             <span class="additional">[no examples found]</span>
                        </g:if>
                    </td>
                </tr>
                -->
            </table>
            
            <g:if test="${session.user}">
            	<g:if test="${ruleId}">
                	<g:actionSubmit action="doEdit" value="${message(code:'ltc.edit.rule.change')}"/>
                </g:if>
                <g:else>
                	<g:actionSubmit action="doEdit" value="${message(code:'ltc.edit.rule.add')}"/>
                </g:else>
            </g:if>

            </g:form>

        </div>
    </body>
</html>
