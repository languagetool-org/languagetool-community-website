
<%@ page import="org.languagetool.User" %>
<%@ page import="de.danielnaber.languagetool.rules.patterns.PatternRule" %>
<%@ page import="de.danielnaber.languagetool.tools.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title>Show Rule "${rule.description.encodeAsHTML()}"</title>
    </head>
    <body>

        <div class="body">
        
            <g:form method="post">
            
            <input type="hidden" name="id" value="${ruleId.encodeAsHTML()}"/>
            <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
            <input type="hidden" name="disableId" value="${disableId.encodeAsHTML()}"/>
            
            <h1>Rule Details</h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
            
            <table>
                <tr>
                    <td width="15%">Pattern:</td>
                    <td>
			            <g:if test="${rule instanceof PatternRule}">
			                <span class="pattern">${rule.toPatternString().encodeAsHTML()}</span><br />
			            </g:if>
			            <g:else>
			                <!-- TODO: add link to source code -->
			                [Java Rule]<br/>
			            </g:else>
                    </td>
                </tr>
                <tr>
                    <td>Description:</td>
                    <td>${rule.description.encodeAsHTML()}</td>
                </tr>
                <g:if test="${rule instanceof PatternRule}">
	                <tr>
	                    <td>Message:</td>
	                    <td>${org.languagetool.StringTools.formatError(rule.message.encodeAsHTML())}</td>
	                </tr>
                </g:if>
                <tr>
                    <td>Category:</td>
                    <td>${rule.category.name.encodeAsHTML()}</td>
                </tr>
                <tr>
                    <td>Active?</td>
                    <td>
                        <g:if test="${session.user}">
                            <g:checkBox name="active" value="${!isDisabled}"/>
                        </g:if>
                        <g:else>
                            <input type="checkbox" name="active" value="on" checked="checked" disabled="disabled" />
                        </g:else>
                </tr>
                
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
                <g:if test="${!isUserRule}">
	                <tr class="additional">
	                    <td>ID:</td>
	                    <td>${rule.id.encodeAsHTML()}</td>
	                </tr>
                </g:if>
            </table>
            
            <g:if test="${session.user}">
                <g:actionSubmit action="change" value="Change Active/Inactive"/> &nbsp;
                <g:if test="${rule instanceof PatternRule}">
		            <g:if test="${isUserRule}">
		            	<g:actionSubmit action="edit" value="Edit Rule"/>
		            </g:if>
		            <g:else>
		                <g:actionSubmit action="copyAndEditRule" value="Copy and Edit Rule "/>
		            </g:else>
	            </g:if>
            </g:if>

            </g:form>
             

            <br />
            <p>Check the following text against just this rule:</p>
            
            <g:form method="post">
                <input type="hidden" name="id" value="${rule.id.encodeAsHTML()}"/>
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
            
                <g:textArea name="text" value="${textToCheck}" rows="2" cols="80" />
                <br />
                <g:actionSubmit action="checkTextWithRule" value="Check"/>
                
            </g:form>

            <g:if test="${matches != null}">            
                <g:render template="/ruleMatches"/>
            </g:if>
            
        </div>
    </body>
</html>
