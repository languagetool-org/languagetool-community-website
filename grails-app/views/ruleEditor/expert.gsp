<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <script type="text/javascript" src="${resource(dir:'js/jquery',file:'jquery-1.7.1.js')}"></script>
        <meta name="layout" content="iframemain" />
        <title><g:message code="ltc.editor.expert.title" /></title>
        <script type="text/javascript">

            function copyXml() {
                $('#xml').val(editor.getValue());
            }

            function onLoadingResult() {
                showDiv('checkResultSpinner');
                document.ruleForm.checkXmlButton.disabled = true;
            }

            function onResultComplete() {
                hideDiv('checkResultSpinner');
                document.ruleForm.checkXmlButton.disabled = false;
            }

            function showDiv(divName) {
                $('#'+divName).show();
            }

            function hideDiv(divName) {
                $('#'+divName).hide();
            }

            $(document).keydown(function(e) {
                if (e.ctrlKey && e.keyCode == 13) {
                    document.ruleForm.checkXmlButton.click();
                }
            });

        </script>
        <style type="text/css" media="screen">
            #editor {
                width: 95%;
                height: 300px;
                font-size: 14px;
            }
        </style>
    </head>
    <body>

        <div class="content">

            <noscript class="warn"><g:message code="ltc.editor.nojs"/></noscript>
        
            <g:form name="ruleForm" method="post" action="checkRule">

                <p style="width:550px;text-align: right"><g:link action="index"><g:message code="ltc.editor.simple.mode"/></g:link></p>

                <p class="warn"><g:message code="ltc.editor.expert.beta.warning"/></p>
                
                <p><g:message code="ltc.editor.expert.intro" args="${['http://www.languagetool.org/development/']}"/></p>

                <g:select style="margin-bottom: 5px" name="language" from="${languageNames}" value="${params.language ? params.language : 'English'}"/><br/>

                <g:if test="${params.xml}">
                    <div id="editor">${params.xml.encodeAsHTML()}</div>
                </g:if>
                <g:else>
                    <div id="editor">&lt;!-- this is an example rule: --&gt;
&lt;rule id="CONFUSION_OF_BED_BAD" name="confusion of bed/bad"&gt;
    &lt;pattern&gt;
        &lt;token&gt;bed&lt;/token&gt;
        &lt;token&gt;English&lt;/token&gt;
    &lt;/pattern&gt;
    &lt;message&gt;Did you mean &lt;suggestion&gt;bad&lt;/suggestion&gt;?&lt;/message&gt;
    &lt;example type="incorrect"&gt;Sorry for my &lt;marker&gt;bed English&lt;/marker&gt;.&lt;/example&gt;
    &lt;example type="correct"&gt;Sorry for my bad English.&lt;/example&gt;
&lt;/rule&gt;
</div>
                </g:else>
                
                <script src="${resource(dir:'js/ace/src-min-noconflict',file:'ace.js')}" type="text/javascript" charset="utf-8"></script>
                <script>
                    var editor = ace.edit("editor");
                    editor.setTheme("ace/theme/dawn");
                    editor.getSession().setMode("ace/mode/xml");
                    editor.focus();
                </script>

                <input id="xml" type="hidden" name="xml" value=""/>

                <table>
                    <tr>
                        <td>
                            <g:submitToRemote name="checkXmlButton"
                                              before="copyXml()"
                                              onLoading="onLoadingResult()"
                                              onComplete="onResultComplete()"
                                              action="checkXml" update="checkResult" value="${message(code:'ltc.editor.expert.check.xml')}"/>
                            <img id="checkResultSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
                        </td>
                        <td><span class="metaInfo"><g:message code="ltc.editor.expert.submit.hint"/></span></td>
                    </tr>
                </table>
                
                <br/>
                <div id="checkResult"></div>

            </g:form>

        </div>
    </body>
</html>
