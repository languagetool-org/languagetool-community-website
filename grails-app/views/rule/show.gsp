
<%@ page import="org.languagetool.User" %>
<%@ page import="de.danielnaber.languagetool.rules.patterns.PatternRule" %>
<%@ page import="de.danielnaber.languagetool.tools.StringTools" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Browse Rules</title>
    </head>
    <body>

        <div class="body">
        
            <g:form method="post">
            
            <h1>Show Rule Details</h1>
            
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
                <tr>
                    <td>Category:</td>
                    <td>${rule.category.name.encodeAsHTML()}</td>
                </tr>
                <tr class="additional">
                    <td>ID:</td>
                    <td>${rule.id.encodeAsHTML()}</td>
                </tr>
                <tr>
                    <td>Active?</td>
                    <td><g:checkBox name="active" value="on"/>
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
                    </td>
                </tr>
            </table>
            
            <g:actionSubmit action="change" value="Change"/>

            </g:form>
             
            
            <p class="additional">
            <br /><br />
            <br /><br />TODO:<br/>
            -why no good/bad examples for java rules? 
            -test only this rule on a sentence / text<br/>
            -modify and test rule<br />
            -add your own example sentence<br/>
            -export as XML (to be loaded in OOo)<br/>
            </p>
            
        </div>
    </body>
</html>
