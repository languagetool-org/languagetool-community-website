<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <g:javascript library="prototype" />
        <meta name="layout" content="iframemain" />
        <title>Check a LanguageTool XML rule</title>
        <script type="text/javascript">

            function showDiv(divName) {
                $(divName).show();
            }

            function hideDiv(divName) {
                $(divName).hide();
            }

        </script>
    </head>
    <body>

        <div class="content">

            <noscript class="warn">This page requires Javascript</noscript>
        
            <g:form name="ruleForm"  method="post" action="checkRule">

                <p>Enter a single LanguageTool XML rule here to check it against Wikipedia data:</p>

                <g:select style="margin-bottom: 5px" name="language" from="${languageNames}" value="English"/><br/>

                <g:textArea name="xml" rows="15" cols="100"></g:textArea>

                <br/>
                <br/>
                <g:submitToRemote name="checkRuleButton" onLoading="showDiv('checkResultSpinner')" onComplete="hideDiv('checkResultSpinner')" action="checkXml" update="checkResult" value="Check XML"/>
                <img id="checkResultSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>

                <br/>
                <div id="checkResult"></div>

            </g:form>

            <script type="text/javascript">
                document.ruleForm.pattern.select();
            </script>

        </div>
    </body>
</html>
