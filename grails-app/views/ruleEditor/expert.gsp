<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <g:javascript library="prototype" />
        <meta name="layout" content="iframemain" />
        <title><g:message code="ltc.editor.expert.title" /></title>
        <script type="text/javascript">

            function copyXml() {
                $('xml').value = editor.getValue();
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
                $(divName).show();
            }

            function hideDiv(divName) {
                $(divName).hide();
            }

            document.observe('keydown', function(e) {
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
                    <div id="editor"></div>
                </g:else>
                
                <script src="http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
                <script>
                    var editor = ace.edit("editor");
                    editor.setTheme("ace/theme/dawn");
                    editor.getSession().setMode("ace/mode/xml");
                    editor.focus();
                </script>

                <input id="xml" type="hidden" name="xml" value=""/>

                <br/>
                <div style="height: 270px"></div>
                <br/><span class="metaInfo"><g:message code="ltc.editor.expert.submit.hint"/></span><br/><br/>
                <g:submitToRemote name="checkXmlButton"
                                  before="copyXml()"
                                  onLoading="onLoadingResult()"
                                  onComplete="onResultComplete()"
                                  action="checkXml" update="checkResult" value="${message(code:'ltc.editor.expert.check.xml')}"/>
                <img id="checkResultSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>

                <br/>
                <div id="checkResult"></div>

            </g:form>

        </div>
    </body>
</html>
