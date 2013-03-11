<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <g:javascript library="prototype" />
        <meta name="layout" content="iframemain" />
        <title>Check a LanguageTool XML rule</title>
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

            <noscript class="warn">This page requires Javascript</noscript>
        
            <g:form name="ruleForm"  method="post" action="checkRule">

                <p style="width:550px;text-align: right"><g:link action="index">Simple Mode</g:link></p>

                <p class="warn">Warning: This mode is still experimental</p>

                <p>Enter a single LanguageTool XML rule (everything and including from <tt>&lt;rule&gt;</tt> to <tt>&lt;/rule&gt;</tt>)
                here to check it against Wikipedia data:</p>

                <g:select style="margin-bottom: 5px" name="language" from="${languageNames}" value="English"/><br/>

                <div id="editor"></div>
                
                <script src="http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
                <script>
                    var editor = ace.edit("editor");
                    editor.setTheme("ace/theme/dawn");
                    editor.getSession().setMode("ace/mode/xml");
                    editor.focus();
                </script>
                
                <input id="xml" type="hidden" name="xml" value=""/>
                <br/><span class="metaInfo">Hint: you can submit this form with Ctrl+Return</span>

                <br/>
                <br/>
                <div style="height: 280px"></div>
                <g:submitToRemote name="checkXmlButton"
                                  before="copyXml()"
                                  onLoading="onLoadingResult()"
                                  onComplete="onResultComplete()"
                                  action="checkXml" update="checkResult" value="Check XML"/>
                <img id="checkResultSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>

                <br/>
                <div id="checkResult"></div>

            </g:form>

        </div>
    </body>
</html>
