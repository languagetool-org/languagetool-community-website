
<%@ page import="org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <g:javascript library="prototype" />
        <meta name="layout" content="iframemain" />
        <title>Create a new LanguageTool rule</title>
        <script type="text/javascript">

            function onLoadingResult(divName, buttonName) {
                showDiv(divName);
                document.ruleForm[buttonName].disabled = true;
            }

            function onResultComplete(divName, buttonName) {
                hideDiv(divName);
                document.ruleForm[buttonName].disabled = false;
            }

            function showDiv(divName) {
                $(divName).show();
            }

            function hideDiv(divName) {
                $(divName).hide();
            }

            function handleReturn(event) {
                if (event.keyCode == 13) {
                    document.ruleForm.checkRuleButton.click();
                }
            }

            function handleReturnForXmlCreation(event) {
                if (event.keyCode == 13) {
                    document.ruleForm.createXmlButton.click();
                }
            }

        </script>
    </head>
    <body>

        <div class="content">

            <noscript class="warn">This page requires Javascript</noscript>
        
            <g:form name="ruleForm"  method="post" action="checkRule">

                <g:hiddenField id="messageBackup" name="messageBackup" value=""/>
                <g:hiddenField id="nameBackup" name="nameBackup" value=""/>

                <table style="border: 0px">
                    <tr>
                        <td colspan="2">
                            <p style="width:550px;text-align: right"><g:link action="expert">Expert Mode</g:link></p>

                            <p style="width:550px">LanguageTool finds errors based on rules. Most of these rules are expressed
                            as XML, and this page will help you to create your own simple rules in XML.</p>
                        </td>
                    </tr>
                    <tr>
                        <td width="150">Language</td>
                        <td><g:select name="language" from="${languageNames}" value="English"/></td>
                    </tr>
                    <tr>
                        <td valign="top">Wrong words</td>
                        <td><g:textField id="pattern"
                                onkeypress="return handleReturn(event);"
                                onfocus="\$('pattern').setStyle({color: 'black'})"
                                class="preFilledField" type="text" name="pattern" value="bed English"/>

                        <br/>
                        <div id="patternHelpLink">
                            <a onclick="showDiv('patternHelp');hideDiv('patternHelpLink')" href="#">Show Help</a>
                        </div>
                        <div id="patternHelp" style="display: none">
                            <a onclick="showDiv('patternHelpLink');hideDiv('patternHelp')" href="#">Hide Help</a><br/>
                            <table>
                                <tr style="background-color: #eeeeee">
                                    <td>foo</td>
                                    <td>matches the word "foo", ignoring case</td>
                                </tr>
                                <tr>
                                    <td>foo bar</td>
                                    <td>matches the phrase "foo bar"</td>
                                </tr>
                                <tr style="background-color: #eeeeee">
                                    <td>(?-i)foo</td>
                                    <td>matches the word "foo", but not "FOO" or "Foo"</td>
                                </tr>
                                <tr>
                                    <td>foo|bar|blah</td>
                                    <td>matches the word "foo", "bar" or "blah"</td>
                                </tr>
                                <tr style="background-color: #eeeeee">
                                    <td>walks?</td>
                                    <td>matches the word "walk" or "walks", i.e. the "s" is optional</td>
                                </tr>
                            </table>
                        </div>

                        </td>
                    </tr>
                    <tr>
                        <td>Sentence<br/>
                            with error</td>
                        <td><g:textField id="incorrectExample1"
                                onkeypress="return handleReturn(event);"
                                onfocus="\$('incorrectExample1').setStyle({color: 'black'})"
                                class="preFilledField" type="text" name="incorrectExample1" value="Sorry for my bed English."/>
                            <!--<br/>
                            <span class="metaInfo">Example: Sorry for my bed English.</span>-->
                        </td>
                    </tr>
                    <tr>
                        <td>Sentence<br/>
                            with the error corrected</td>
                        <td><g:textField id="correctExample1"
                                onkeypress="return handleReturn(event);"
                                onfocus="\$('correctExample1').setStyle({color: 'black'})"
                                class="preFilledField" type="text" name="correctExample1" value="Sorry for my bad English."/>
                            <!--<br/>
                            <span class="metaInfo">Example: Sorry for my bad English.</span>-->
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <g:submitToRemote name="checkRuleButton"
                                              onLoading="onLoadingResult('checkResultSpinner', 'checkRuleButton')"
                                              onComplete="onResultComplete('checkResultSpinner', 'checkRuleButton')"
                                              action="checkRule" update="checkResult" value="Continue"/>
                            <img id="checkResultSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
                        </td>
                    </tr>

                </table>

                <br/>
                <div id="checkResult"></div>

            </g:form>

            <script type="text/javascript">
                document.ruleForm.pattern.select();
            </script>

        </div>
    </body>
</html>
