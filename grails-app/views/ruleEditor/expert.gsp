<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <g:javascript library="prototype" />
        <meta name="layout" content="iframemain" />
        <title>Check a LanguageTool XML rule</title>
        <script type="text/javascript">

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

                <g:textArea id="xml" name="xml" rows="15" cols="100"></g:textArea>
                <br/><span class="metaInfo">Hint: you can submit this form with Ctrl+Return</span>

                <br/>
                <br/>
                <g:submitToRemote name="checkXmlButton"
                                  onLoading="onLoadingResult()"
                                  onComplete="onResultComplete()"
                                  action="checkXml" update="checkResult" value="Check XML"/>
                <img id="checkResultSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>

                <br/>
                <div id="checkResult"></div>

            </g:form>

            <script type="text/javascript">
                document.ruleForm.xml.select();
            </script>

        </div>
    </body>
</html>
