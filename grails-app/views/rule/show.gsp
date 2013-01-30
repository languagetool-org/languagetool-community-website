
<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.rule.show.title" args="${[rule.description.encodeAsHTML()]}"/></title>
    </head>
    <body>

        <div class="body">
        
            <g:form method="post">
            
            <input type="hidden" name="id" value="${ruleId.encodeAsHTML()}"/>
            <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
            <input type="hidden" name="disableId" value="${disableId.encodeAsHTML()}"/>
            
            <h1><g:message code="ltc.rule.show.title" args="${[rule.description.encodeAsHTML()]}"/></h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
            
            <table>
                <tr>
                    <td><g:message code="ltc.rule.show.pattern" /></td>
                    <td>
			            <g:if test="${rule instanceof PatternRule}">
			                <span class="pattern">${rule.toPatternString().replace(", ", " ").encodeAsHTML()}</span><br />
			            </g:if>
			            <g:else>
			                <span class="javaRule"><g:message code="ltc.rule.show.java.rule" /></span>
                            <g:set var="langCode" value="${params.lang}"/>
                            <g:if test="${params.lang.contains('-')}">
                                <g:set var="langCode" value="${params.lang.substring(0, params.lang.indexOf('-'))}"/>
                            </g:if>
                            <g:if test="${rule.class.getName().contains('.' + langCode  + '.')}">
                                <%-- language-specific rule --%>
                                <a href="http://languagetool.svn.sourceforge.net/viewvc/languagetool/trunk/languagetool/languagetool-language-modules/${langCode.encodeAsHTML()}/src/main/java/${rule.class.getName().replace(".", "/")}.java?view=markup">Sourcecode</a>
                            </g:if>
                            <g:else>
                                <%-- generic rule --%>
                                <a href="http://languagetool.svn.sourceforge.net/viewvc/languagetool/trunk/languagetool/languagetool-core/src/main/java/${rule.class.getName().replace(".", "/")}.java?view=markup">Sourcecode</a>
                            </g:else>
                            <br/>
			            </g:else>
                    </td>
                </tr>
                <tr>
                    <td><g:message code="ltc.rule.show.description" /></td>
                    <td>${rule.description.encodeAsHTML()}</td>
                </tr>
                <g:if test="${rule instanceof PatternRule}">
	                <tr>
	                    <td><g:message code="ltc.rule.show.message" /></td>
	                    <td>${org.languagetool.StringTools.formatError(rule.message.encodeAsHTML())}</td>
	                </tr>
                </g:if>
                <tr>
                    <td><g:message code="ltc.rule.show.category" /></td>
                    <td>${rule.category.name.encodeAsHTML()}</td>
                </tr>
                <g:if test="${rule.url}">
                    <tr>
                        <td><g:message code="ltc.rule.show.link" /></td>
                        <td><a href="${rule.url}">${rule.url.encodeAsHTML()}</a></td>
                    </tr>
                </g:if>
                <tr>
                    <td><g:message code="ltc.rule.show.active" /></td>
                    <td>
                        <g:if test="${session.user}">
                            <g:checkBox name="active" value="${!isDisabled}"/>
                        </g:if>
                        <g:else>
                            <input type="checkbox" name="active" value="on" checked="checked" disabled="disabled" />
                        </g:else>
                </tr>
                
                <tr>
                    <td><g:message code="ltc.rule.show.incorrect.sentences" /></td>
                    <td>
			            <ul>
			            <g:each var="example" in="${rule.getIncorrectExamples()}">
			                <li>${example.getExample().encodeAsHTML().
			                    replace("&lt;marker&gt;", '<span class="error">').
			                    replace("&lt;/marker&gt;", '</span>')
			                    }
			                    <g:if test="${example.getCorrections()}">
    			                    <br /><g:message code="ltc.rule.show.corrections" />
			                        <span class="correction">${StringTools.listToString(example.getCorrections(), ", ")}</span>
			                    </g:if>
			                </li>
			            </g:each>
			            </ul>
                        <g:if test="${rule.getIncorrectExamples() == null}">
                             <span class="additional"><g:message code="ltc.rule.show.no.examples" /></span>
                        </g:if>
                    </td>
                </tr>
                
                <tr>
                    <td><g:message code="ltc.rule.show.correct.sentences" /></td>
                    <td>
			            <ul>
			            <g:each var="example" in="${rule.getCorrectExamples()}">
			                <li>${example.encodeAsHTML().
			                     replace("&lt;marker&gt;", '<b>').
			                     replace("&lt;/marker&gt;", '</b>')}</li>
			            </g:each>
			            </ul>
                        <g:if test="${rule.getCorrectExamples() == null}">
                             <span class="additional"><g:message code="ltc.rule.show.no.examples" /></span>
                        </g:if>
                    </td>
                </tr>
                <g:if test="${!isUserRule}">
	                <tr class="additional">
	                    <td><g:message code="ltc.rule.show.id" /></td>
                        <td>
                            <g:if test="${ruleSubId}">
                                ${rule.id.encodeAsHTML()} [${ruleSubId.encodeAsHTML()}]
                            </g:if>
                            <g:else>
                                ${rule.id.encodeAsHTML()}
                            </g:else>
                        </td>
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
            
            <p style="margin-top:20px">
                <a href="http://www.languagetool.org"><img style="margin-right:7px;" src="${resource(dir:'images',file:'lt-logo.png')}" alt="LanguageTool logo" align="left"/></a>
                <g:message code="ltc.languagetool.link" />
            </p>

            <br />
            <p><g:message code="ltc.rule.show.check.text" /></p>
            
            <g:form method="post">

                <input type="hidden" name="id" value="${ruleId}"/>
                <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>
            
                <g:textArea name="text" value="${textToCheck}" rows="2" cols="80" />
                <br />
                <g:actionSubmit action="checkTextWithRule" value="${message(code:'ltc.check.button')}"/>
                
            </g:form>

            <g:if test="${matches != null}">
                <g:render template="/ruleMatches"/>
            </g:if>
            
            <p style="margin-top:10px">
            <g:if test="${corpusMatchCount > 0}">
                <g:link controller="corpusMatch" action="list" params="${[lang: params.lang, filter: ruleId]}"><g:message code="ltc.rule.show.corpus.link" args="${[corpusMatchCount]}"/></g:link>
            </g:if>
            <g:else>
                <g:link controller="corpusMatch" action="list" params="${[lang: params.lang]}"><g:message code="ltc.rule.show.corpus.link" args="${[corpusMatchCount]}"/></g:link>
            </g:else>
            </p>
            
        </div>
    </body>
</html>
