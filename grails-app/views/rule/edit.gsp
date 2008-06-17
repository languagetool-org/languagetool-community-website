
<%@ page import="org.languagetool.User" %>
<%@ page import="de.danielnaber.languagetool.rules.patterns.PatternRule" %>
<%@ page import="de.danielnaber.languagetool.tools.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title>Edit Rule "${rule.description.encodeAsHTML()}"</title>
    </head>
    <body>

        <div class="body">
        
            <g:form method="post">
            
            <input type="hidden" name="id" value="${rule.id.encodeAsHTML()}"/>
            <g:if test="${params.lang}">
	            <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
            </g:if>
            <g:else>
            	<input type="hidden" name="lang" value="${lang.encodeAsHTML()}"/>
            </g:else>
            
            <h1>Edit Rule</h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
            
            <table>
                <tr>
                    <td width="15%">Pattern:</td>
                    <td>
                    	<% int i = 0; %>
                    	<g:while test="${i < grailsApplication.config.maxPatternElements}">
	                    	${i+1}. <g:textField class="pattern" size="50" name="pattern_${i}"
	                    		value="${rule.patternElements[i]}"/><br />
	                    	<% i++ %>
                    	</g:while>
                    </td>
                </tr>
                <tr>
                    <td>Description:</td>
                    <td><g:textField size="60" name="description" value="${rule.description}"/></td>
                </tr>
                
                <tr>
                    <td>Message:</td>
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
                <g:actionSubmit action="doEdit" value="Change"/>
            </g:if>

            </g:form>

        </div>
    </body>
</html>