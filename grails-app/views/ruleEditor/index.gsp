
<%@ page import="org.languagetool.Language; org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <script type="text/javascript" src="${resource(dir:'js/jquery',file:'jquery-1.7.1.js')}"></script>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.editor.title"/></title>
        <script type="text/javascript">

            function onLoadingResult(divName, buttonName) {
                showDiv(divName);
                document.ruleForm[buttonName].disabled = true;
            }

            function onResultComplete(divName, buttonName) {
                hideDiv(divName);
                document.ruleForm[buttonName].disabled = false;
                if (divName == 'checkResultSpinner') {
                    // if we (re-)submit the first step we need to clear the
                    // final result to avoid incoherent data being displayed:
                    $('#xml').html("");
                }
            }

            function showDiv(divName) {
                $('#'+divName).show();
            }

            function hideDiv(divName) {
                $('#'+divName).hide();
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

        <div class="body">

            <g:render template="/languageSelection"/>

            <g:form name="ruleForm"  method="post" action="checkRule">

                <g:hiddenField id="messageBackup" name="messageBackup" value=""/>
                <g:hiddenField id="nameBackup" name="nameBackup" value=""/>

                <table style="border: 0px">
                    <tr>
                        <td colspan="2">
                            <p style="width:550px;margin:10px;text-align: right"><g:link action="expert"><g:message code="ltc.editor.advanced.mode"/></g:link></p>

                            <p style="width:550px"><g:message code="ltc.editor.intro"/></p>
                        </td>
                    </tr>
                    <tr>
                        <td width="150"><g:message code="ltc.editor.language"/></td>
                        <td><g:select name="language" from="${languageNames}" value="${params.lang ? Language.getLanguageForShortName(params.lang).getName() : 'English'}"/></td>
                    </tr>
                    <tr>
                        <td valign="top"><g:message code="ltc.editor.wrong.words"/></td>
                        <td><g:textField id="pattern"
                                onkeypress="return handleReturn(event);"
                                onfocus="\$('#pattern').css({color: 'black'})"
                                class="preFilledField" type="text" name="pattern" value="bed English"/>

                        <br/>
                        <div id="patternHelpLink">
                            <a onclick="showDiv('patternHelp');hideDiv('patternHelpLink')" href="#"><g:message code="ltc.editor.show.help"/></a>
                        </div>
                        <div id="patternHelp" style="display: none">
                            <a onclick="showDiv('patternHelpLink');hideDiv('patternHelp')" href="#"><g:message code="ltc.editor.hide.help"/></a><br/>
                            <table>
                                <tr style="background-color: #eeeeee">
                                    <td>foo</td>
                                    <td><g:message code="ltc.editor.help.word"/></td>
                                </tr>
                                <tr>
                                    <td>foo bar</td>
                                    <td><g:message code="ltc.editor.help.phrase"/></td>
                                </tr>
                                <tr style="background-color: #eeeeee">
                                    <td>(?-i)foo</td>
                                    <td><g:message code="ltc.editor.help.word.case.sensitive"/></td>
                                </tr>
                                <tr>
                                    <td>foo|bar|blah</td>
                                    <td><g:message code="ltc.editor.help.regex"/></td>
                                </tr>
                                <tr style="background-color: #eeeeee">
                                    <td>walks?</td>
                                    <td><g:message code="ltc.editor.help.question.mark"/></td>
                                </tr>
                            </table>
                        </div>

                        </td>
                    </tr>
                    <tr>
                        <td><g:message code="ltc.editor.bad.sentence"/></td>
                        <td><g:textField id="incorrectExample1"
                                onkeypress="return handleReturn(event);"
                                onfocus="\$('#incorrectExample1').css({color: 'black'})"
                                class="preFilledField" type="text" name="incorrectExample1" value="Sorry for my bed English."/>
                            <!--<br/>
                            <span class="metaInfo">Example: Sorry for my bed English.</span>-->
                        </td>
                    </tr>
                    <tr>
                        <td><g:message code="ltc.editor.good.sentence"/></td>
                        <td><g:textField id="correctExample1"
                                onkeypress="return handleReturn(event);"
                                onfocus="\$('#correctExample1').css({color: 'black'})"
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
                                              action="checkRule" update="${[success: 'checkResult', failure: 'checkResult']}"
                                              value="${message(code:'ltc.editor.continue')}"/>
                            <img id="checkResultSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
                        </td>
                    </tr>

                </table>

                <br/>
                <div id="checkResult"></div>

            </g:form>

            <br/>
            <div id="xml"></div>

            <script type="text/javascript">
                document.ruleForm.pattern.select();
            </script>

        </div>
    </body>
</html>
