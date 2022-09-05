<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<%@page import="org.languagetool.*" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.rule.show.title" args="${[rule.description]}"/></title>
        <script type="text/javascript" src="${resource(dir:'js/prototype',file:'prototype.js')}"></script>
        <script language="JavaScript">
            var ruleVisible = false;
            function showRuleXml(language, id, subId) {
                if (ruleVisible) {
                    $('ruleXml').innerHTML = "";
                    ruleVisible = false;
                } else {
                    $('localSpinner').show();
                    new Ajax.Request("${createLink(action: 'showRuleXml')}", {
                        parameters: {
                            lang: language,
                            id: id,
                            subId: subId
                        },
                        onSuccess: function(response) {
                            $('ruleXml').innerHTML = "<br/>" + response.responseText;
                            $('localSpinner').hide();
                            ruleVisible = true;
                        },
                        onFailure: function(response) {
                            $('ruleXml').innerHTML = response.responseText;
                            $('localSpinner').hide();
                            ruleVisible = false;
                        }
                    });
                }
            }
        </script>
    </head>
    <body>

        <div class="body">
        
            <g:link action="list"  params="${[lang:params.lang.encodeAsHTML()]}"><g:message code="ltc.rule.show.back.to.list" /></g:link>
            
            <h1><g:message code="ltc.rule.show.title" args="${[rule.description]}"/></h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

            <p style="margin-top: 10px; margin-bottom: 10px"><g:message code="ltc.rule.show.intro" args="${['https://languagetool.org', 'https://languagetool.org']}"/></p>
            
            <table style="border-style: none">
                <tr>
                    <td style="width:25%"><g:message code="ltc.rule.show.description" /></td>
                    <td>${rule.description.encodeAsHTML()}</td>
                </tr>
                <g:if test="${rule.isDefaultOff()}">
                    <tr>
                        <td></td>
                        <td><b><g:message code="ltc.rule.show.rule.off" /></b></td>
                    </tr>
                </g:if>
                <g:if test="${rule.getCategory() && rule.getCategory().isDefaultOff()}">
                    <tr>
                        <td></td>
                        <td><b><g:message code="ltc.rule.show.category.off" /></b></td>
                    </tr>
                </g:if>
                <g:if test="${rule instanceof PatternRule}">
                    <tr>
                        <td><g:message code="ltc.rule.show.message" /></td>
                        <td>${org.languagetool.StringTools.formatError(rule.message.encodeAsHTML())}</td>
                    </tr>
                </g:if>
                <tr>
                    <td><g:message code="ltc.rule.show.category" /></td>
                    <td>
                        ${rule.category.name.encodeAsHTML()}
                        <g:if test="${rule.category && rule.category.id}">
                            <span class="metaInfo">(ID: ${rule.category.id.encodeAsHTML()})</span>
                        </g:if>
                    </td>
                </tr>
                <g:if test="${rule.url}">
                    <tr>
                        <td><g:message code="ltc.rule.show.link" /></td>
                        <g:if test="${rule.url.toString().contains('//languagetool.') || rule.url.toString().contains('//www.languagetool.')}">
                            <td><a href="${rule.url}">${rule.url.encodeAsHTML()}</a></td>
                        </g:if>
                        <g:else>
                            <td><a href="${rule.url}" rel="nofollow">${rule.url.encodeAsHTML()}</a></td>
                        </g:else>
                    </tr>
                </g:if>
                <g:if test="${rule.tags}">
                    <tr>
                        <td><g:message code="ltc.rule.show.tags" /></td>
                        <td>${rule.tags.encodeAsHTML()}</td>
                    </tr>
                </g:if>

                <tr>
                    <td><g:message code="ltc.rule.show.incorrect.sentences" /></td>
                    <td>
                        <ul>
                            <g:each var="example" in="${rule.getIncorrectExamples()}">
                                <li>${example.getExample().encodeAsHTML().
                                        replace("&lt;marker&gt;", '<span class="error">').
                                        replace("&lt;/marker&gt;", '</span>')
                                    }
                                    <g:if test="${example.getCorrections().size() > 0 && !example.getCorrections().get(0).isEmpty()}">
                                        <div style="margin-top: 5px">
                                            <g:message code="ltc.rule.show.corrections" />
                                            <span class="correction">${String.join(", ", example.getCorrections())}</span>
                                        </div>
                                    </g:if>
                                </li>
                            </g:each>
                        </ul>
                        <g:if test="${rule.getIncorrectExamples() == null}">
                             <span class="additional"><g:message code="ltc.rule.show.no.examples" /></span>
                        </g:if>
                    </td>
                </tr>

                <g:if test="${rule.getCorrectExamples().size() > 0}">
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
                        </td>
                    </tr>
                </g:if>

                <tr>
                    <td><g:message code="ltc.rule.show.pattern" /></td>
                    <td>
                        <g:set var="langCode" value="${params.lang}"/>
                        <g:if test="${params.lang.contains('-')}">
                            <g:set var="langCode" value="${params.lang.substring(0, params.lang.indexOf('-'))}"/>
                        </g:if>
                        <g:if test="${rule instanceof PatternRule}">
                            <a href="#" onclick="showRuleXml('${params.lang}', '${params.id}', '${params.subId}');return false;"><g:message code="ltc.rule.show.as.xml" /></a> &middot;
                            <g:link controller="ruleEditor2" params="${[id: params.id, subId: params.subId, lang: langCode]}"><g:message code='ltc.rule.show.editor.link'/></g:link>
                            <div id="localSpinner" style="display:none;">
                                <img src="${resource(dir:'images',file:'spinner.gif')}" alt="Spinner" />
                            </div>
                            <div id="ruleXml"></div>
                        </g:if>
                        <g:else>
                            <span class="javaRule"><g:message code="ltc.rule.show.java.rule" /></span>
                            <g:if test="${rule.class.getName().contains('.' + langCode  + '.')}">
                            <%-- language-specific rule --%>
                                <a href="https://github.com/languagetool-org/languagetool/blob/master/languagetool-language-modules/${langCode.encodeAsHTML()}/src/main/java/${rule.class.getName().replace(".", "/")}.java">Sourcecode</a>
                            </g:if>
                            <g:else>
                            <%-- generic rule --%>
                                <a href="https://github.com/languagetool-org/languagetool/blob/master/languagetool-core/src/main/java/${rule.class.getName().replace(".", "/")}.java">Sourcecode</a>
                            </g:else>
                            <br/>
                        </g:else>
                    </td>
                </tr>

                <!--
                <tr>
                    <td><g:message code="ltc.rule.show.wikipedia" /></td>
                    <td>
                        <g:if test="${corpusMatchCount > 0}">
                            <g:link controller="corpusMatch" action="list" params="${[lang: params.lang, filter: ruleId]}"><g:message code="ltc.rule.show.corpus.link" args="${[corpusMatchCount]}"/></g:link>
                        </g:if>
                        <g:else>
                            <g:link controller="corpusMatch" action="list" params="${[lang: params.lang]}"><g:message code="ltc.rule.show.corpus.link" args="${[corpusMatchCount]}"/></g:link>
                        </g:else>
                    </td>
                </tr>
                -->

                <tr>
                    <td>
                        <g:message code="ltc.rule.show.check.text" />
                    </td>

                    <td>
                        <g:form method="post">

                            <input type="hidden" name="id" value="${ruleId}"/>
                            <input type="hidden" name="lang" value="${params.lang.encodeAsHTML()}"/>

                            <g:textArea style="min-width: 200px;max-width: 500px; width: 100%" maxlength="25000" name="text" value="${textToCheck}" rows="3" />
                            <br />
                            <g:actionSubmit action="checkTextWithRule" value="${message(code:'ltc.check.button')}"/>

                        </g:form>

                        <g:if test="${matches != null}">
                            <g:render template="/remoteRuleMatches"/>
                        </g:if>
                    </td>
                </tr>

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
                <tr class="additional">
                    <td><g:message code="ltc.rule.show.languagetool.version" /></td>
                    <td>
                        ${JLanguageTool.VERSION} (${JLanguageTool.BUILD_DATE})
                    </td>
                </tr>

            </table>

        </div>
    </body>
</html>
