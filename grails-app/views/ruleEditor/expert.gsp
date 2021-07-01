<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <script type="text/javascript" src="${resource(dir:'js/jquery',file:'jquery-1.7.1.js')}"></script>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.editor.expert.title" /></title>
        <script type="text/javascript">

            function copyXml(skipDocs) {
                $('#xml').val(editor.getValue());
                $('#skipDocs').val(skipDocs);
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
                max-width: 1024px;
                width: 95%;
                height: 300px;
                font-size: 14px;
            }
        </style>
    </head>
    <body>

        <div class="body">

            <g:form name="ruleForm" method="post" action="checkRule">

                <input type="hidden" id="showMatchesOnly" name="showMatchesOnly" value=""/>

                <p style="margin-top: 8px;">You're in expert mode. Don't know what to do here? <g:link controller="ruleEditor2">Try the simple mode instead.</g:link></p>
                
                <p>
                    <g:message code="ltc.editor.expert.intro" args="${['https://dev.languagetool.org/development-overview']}"/>
                    <g:message code="ltc.editor.expert.intro.completion"/>
                </p>

                <g:select style="margin-bottom: 5px" name="language" from="${languages}" optionKey="shortCodeWithCountryAndVariant" value="${params.language ? params.language : 'en'}"/><br/>

                <g:if test="${params.xml}">
                    <div id="editor">${params.xml.encodeAsHTML()}</div>
                </g:if>
                <g:else>
                    <div id="editor" style="resize:vertical; overflow:auto;">&lt;!-- this is an example rule: --&gt;
&lt;rule id="CONFUSION_OF_BED_BAD" name="confusion of bed/bad"&gt;
    &lt;pattern&gt;
        &lt;token&gt;bed&lt;/token&gt;
        &lt;token&gt;English&lt;/token&gt;
    &lt;/pattern&gt;
    &lt;message&gt;Did you mean &lt;suggestion&gt;bad English&lt;/suggestion&gt;?&lt;/message&gt;
    &lt;example correction="bad English"&gt;Sorry for my &lt;marker&gt;bed English&lt;/marker&gt;.&lt;/example&gt;
&lt;/rule&gt;
</div>
                </g:else>
                
                <script src="${resource(dir:'js/ace/src-min-noconflict',file:'ace.js')}" type="text/javascript" charset="utf-8"></script>
                <script>
                    function getCompletions(s) {
                        var strings = s.split(/ /);
                        strings.sort();
                        var result = [];
                        for (i = 0; i < strings.length; i++) {
                            result.push({snippet: strings[i] + "=\"\"", caption: strings[i]});
                        }
                        return result;
                    }
                    
                    function getLeftElementOfAttribute(line, columnPos) {
                        var spaceFoundFirst = false;
                        var quoteCount = 0;
                        for (i = columnPos - 1; i >= 0; i--) {
                            var ch = line[i];
                            if (ch == "\"" || ch == "'") {
                                quoteCount++;
                            } else if (ch == " ") {
                                spaceFoundFirst = true;
                            } else if (ch == "<") {
                                if (quoteCount % 2 == 1) {
                                    // it seems we're inside an attribute value, completion is not supported here yet:
                                    return "";
                                }
                                if (spaceFoundFirst) {
                                    // find the element name:
                                    var endElementPos = line.indexOf(" ", i);
                                    return line.substring(i+1, endElementPos);
                                }
                            }
                        }
                        return "";
                    }
                    
                    var attrCompletions = {};
                    // The following values are copied manually from the rules.xsd and pattern.xsd:
                    attrCompletions['rulegroup'] = getCompletions("id name default type");
                    attrCompletions['rule'] = getCompletions("id name default type");
                    attrCompletions['pattern'] = getCompletions("case_sensitive");
                    attrCompletions['unify'] = getCompletions("negate");
                    attrCompletions['feature'] = getCompletions("id");
                    attrCompletions['type'] = getCompletions("id");
                    attrCompletions['exception'] = getCompletions("postag_regexp negate_pos postag spacebefore inflected scope regexp negate");
                    attrCompletions['token'] = getCompletions("postag postag_regexp negate min max negate_pos regexp chunk inflected spacebefore skip case_sensitive");
                    attrCompletions['match'] = getCompletions("regexp_match postag_regexp setpos suppress_misspelled regexp_replace postag_replace postag no include_skipped");
                    attrCompletions['suggestion'] = getCompletions("suppress_misspelled");
                    attrCompletions['phraseref'] = getCompletions("idref");
                    attrCompletions['example'] = getCompletions("correction");
                    
                    ace.require("ace/ext/language_tools");
                    var editor = ace.edit("editor");
                    editor.setTheme("ace/theme/dawn");
                    editor.getSession().setMode("ace/mode/xml");
                    var codeCompleter = {
                        getCompletions: function (editor, session, pos, prefix, callback) {
                            var text = editor.getValue();
                            var line = editor.getSession().getDocument().getLine(pos.row);
                            var leftElement = getLeftElementOfAttribute(line, pos.column);
                            if (leftElement) {
                                var completionList = attrCompletions[leftElement];
                                if (completionList) {
                                    callback(null, completionList);
                                }
                            }
                        }
                    };
                    editor.setOptions({
                        enableBasicAutocompletion: true,
                        enableSnippets: true
                    });
                    editor.completers = [codeCompleter];
                    editor.focus();
                </script>

                <input id="xml" type="hidden" name="xml" value=""/>
                <input id="skipDocs" type="hidden" name="skipDocs" value=""/>
                <input type="hidden" name="devMode" value="${params.devMode ? 'true' : ''}"/>
                <input type="hidden" name="factor" value="${params.factor ? Integer.parseInt(params.factor) : '1'}"/>
                
                <g:if test="${params.devMode == 'true'}">
                    You're in developer mode.
                    <g:if test="${params.factor}">
                        Factor: ${Integer.parseInt(params.factor)}
                    </g:if>
                </g:if>

                <table style="border:0">
                    <tr>
                        <td style="width:10%">
                            <g:if test="${params.devMode == 'true'}">
                                <input id="checkXmlButton" type="submit" value="Check XML and search docs...">
                                <input id="stopButton" type="button" value="Stop" style="background-color: orangered;color: white">
                            </g:if>
                            <g:else>
                                <g:submitToRemote name="checkXmlButton"
                                                  before="copyXml()"
                                                  onLoading="onLoadingResult()"
                                                  onComplete="onResultComplete()"
                                                  action="checkXml" update="${[success: 'checkResult', failure: 'checkResult']}"
                                                  value="${message(code:'ltc.editor.expert.check.xml')}"/>
                            </g:else>
                            <img id="checkResultSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
                        </td>
                        <td><span class="metaInfo"><g:message code="ltc.editor.expert.submit.hint"/></span></td>
                    </tr>
                </table>
                
                <br/>
                <div id="checkResult"></div>

            </g:form>

            <script>
                var limit = 250000;
                var stepSize = 1000;
                var stopSearch = false;

                function enableStopButton() {
                    $("#stopButton").prop('disabled', false);
                    $("#stopButton").css('background-color', 'orangered');
                    showDiv('checkResultSpinner');
                }

                function disableStopButton() {
                    $("#stopButton").prop('disabled', false);
                    $("#stopButton").css('background-color', 'grey');
                    hideDiv('checkResultSpinner');
                }

                function getMatches(form, skipCount) {
                    enableStopButton();
                    console.log("getMatches from " + skipCount);
                    if (skipCount > 0) {
                        $("#showMatchesOnly").val("1");
                        $('#skipDocs').val(skipCount);
                    } else {
                        $("#showMatchesOnly").val("");
                    }
                    if (skipCount > limit) {
                        $("#checkResult").append("Limit (" + limit + ") reached, stopping.");
                        disableStopButton();
                        return;
                    }
                    $.ajax({
                        type: "POST",
                        url: "checkXml",
                        data: form.serialize(), // serializes the form's elements
                        success: function (data) {
                            $("#checkResult").append(data);
                            onResultComplete();
                            if (stopSearch) {
                                console.log("Stopping search, user clicked stop button");
                                disableStopButton();
                                stopSearch = false;
                            } else if (data.indexOf("<!--STOPCHECK-->") == -1) {
                                getMatches(form, skipCount + stepSize);
                            } else {
                                console.log("Stopping search, got hint from server");
                                disableStopButton();
                            }
                        }
                    });
                }

                $( document ).ready(function() {
                    disableStopButton();
                    $("#stopButton").click(function(e) {
                        console.log("stop button clicked");
                        stopSearch = true;
                        disableStopButton();
                    });
                    $("#ruleForm").submit(function(e) {
                        console.log("submit button clicked");
                        $("#checkResult").html("");
                        e.preventDefault();
                        var form = $(this);
                        copyXml();
                        getMatches(form, 0);
                    });
                });
            </script>

        </div>
    </body>
</html>
