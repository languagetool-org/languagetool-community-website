<%@ page import="org.languagetool.Language; org.languagetool.User" %>
<%@ page import="org.languagetool.rules.patterns.PatternRule" %>
<%@ page import="org.languagetool.tools.StringTools" %>
<html>
    <head>
        <script type="text/javascript" src="${resource(dir:'js/jquery', file:'jquery-1.7.1.js')}"></script>
        <script type="text/javascript" src="${resource(dir:'js/jquery-ui', file:'jquery-ui-1.10.4.min.js')}"></script>
        <link rel="stylesheet" href="${resource(dir:'css/jquery-ui/themes/smoothness', file:'jquery-ui.css')}">
        <meta name="layout" content="main" />
        <title><g:message code="ltc.editor.title"/></title>

        <style>
            #sortable { list-style-type: none; margin: 0; padding: 0; width: 80%; }
            #sortable li { margin: 0 3px 3px 3px; padding: 0.4em 0.4em 1.1em 1.5em; height: 18px; }
            #sortable li span { position: absolute; margin-left: -1.0em; }
            .exampleSentenceField {
                width: 300px;
            }
            .removeLink {
                float: right;
            }
            #dragContainment {
            }
            #patternArea {
                margin-left: 6px;
                max-width: 800px;
            }
            .dragHandle {
                cursor: ns-resize;
                font-size: 16px;
            }
            input[type='text'] {
                width: 300px;
            }
            .evaluationResultArea {
                max-width: 600px;
                margin-bottom: 30px;
            }
            .pos, .lemma {
                color: #777;
            }
        </style>

        <script type="text/javascript">

            var MARKER_START = 'Marker start';
            var MARKER_END = 'Marker end';
            
            var elementCount = 0;
            var patternCreated = false;

            $(document).ready(function() {
                $(function() {
                    $("#sortable").sortable({handle: '.dragHandle', containment: '#dragContainment', axis: 'y'});
                });
                String.prototype.htmlEscape = function() {
                    return $('<div/>').text(this.toString()).html();
                };
            });

            function toggle(selector) {
                if ($(selector).css('display') == 'none') {
                    $(selector).show();
                } else {
                    $(selector).hide();
                }
            }
            
            function handleReturnForToken(event) {
                if (event.keyCode == 13) {
                    event.stopPropagation();
                    event.preventDefault();
                    evaluateRule();
                }
            }

            function createPattern() {
                if (patternCreated) {
                    if (!confirm("Re-create the pattern, overwriting the existing one?")) {
                        return;
                    } else {
                        clearPattern();
                    }
                }
                var wrongSentence = $('#wrongSentence').attr('value');
                var correctedSentence = $('#correctedSentence').attr('value');
                $('#createPatternSpinner').show();
                $.when(
                        //TODO: check if LT knows the error already
                        sendWrongSentenceAnalysisRequest(wrongSentence),
                        sendCorrectedSentenceAnalysisRequest(correctedSentence)
                    )
                    .done(function() {
                        addPatternTokens(wrongSentence, correctedSentence);
                        patternCreated = true;
                        $('#createPatternSpinner').hide();
                    }
                );
            }
            
            function sendWrongSentenceAnalysisRequest(wrongSentence) {
                $.ajax({
                    async: false,
                    type: "POST",
                    url: '${resource(dir: 'analysis', file: 'analyzeTextForEmbedding')}',
                    data: {
                        lang: '${language.getShortName().encodeAsHTML()}',
                        text: wrongSentence,
                        elementId: 'tokenizationOfWrongSentence'
                    },
                    success: function(data) {
                        $('#wrongSentenceEvaluationResult').html(data);
                        $('#errorPatternPart').css('display', 'block');
                    },
                    error: function(xhr, ajaxOptions, thrownError) {
                        $('#wrongSentenceEvaluationResult').html(xhr.status + " " + thrownError + "<br/>" + xhr.responseText);
                    }
                });
            }
            
            function sendCorrectedSentenceAnalysisRequest(correctedSentence) {
                $.ajax({
                    async: false,
                    type: "POST",
                    url: '${resource(dir: 'analysis', file: 'analyzeTextForEmbedding')}',
                    data: {
                        lang: '${language.getShortName().encodeAsHTML()}',
                        text: correctedSentence,
                        elementId: 'tokenizationOfCorrectedSentence'
                    },
                    success: function(data) {
                        $('#correctedSentenceEvaluationResult').html(data);
                        // nothing to show, we need the result only internally for its tokens
                    },
                    error: function(xhr, ajaxOptions, thrownError) {
                        $('#correctedSentenceEvaluationResult').html(xhr.status + " " + thrownError + "<br/>" + xhr.responseText);
                        $('#correctedSentenceEvaluationResult').css('display', 'block');
                    }
                });
            }
            
            function addPatternTokens(wrongSentence, correctedSentence) {
                var wrongSentenceTokens = getTokens('#tokenizationOfWrongSentence');
                var correctedSentenceTokens = getTokens('#tokenizationOfCorrectedSentence');
                var diffStart = findFirstDifferentPosition(wrongSentenceTokens, correctedSentenceTokens);
                var diffEnd = findLastDifferentPosition(wrongSentenceTokens, correctedSentenceTokens);
                for (var j = diffStart; j <= diffEnd; j++) {
                    addToken(wrongSentenceTokens[j]);
                }
            }
            
            function getTokens(selector) {
                var tokenList = $(selector).find('li');
                var tokens = [];
                for (var i = 0; i < tokenList.length; i++) {
                    tokens.push($(tokenList[i]).html());
                }
                return tokens;
            }
            
            function clearPattern() {
                var domElements = $('#sortable li');
                for (var i = 0; i < domElements.length; i++) {
                    $(domElements[i]).remove();
                }
            }

            function findFirstDifferentPosition(wrongSentenceTokens, correctedSentenceTokens) {
                for (var i = 0; i < Math.min(wrongSentenceTokens.length, correctedSentenceTokens.length); i++) {
                    if (wrongSentenceTokens[i] != correctedSentenceTokens[i]) {
                        return i;
                    }
                }
                return -1;
            }
            
            function findLastDifferentPosition(wrongSentenceTokens, correctedSentenceTokens) {
                var wrongSentencePos = wrongSentenceTokens.length;
                var correctedSentencePos = correctedSentenceTokens.length;
                var startPos = Math.max(wrongSentenceTokens.length, correctedSentenceTokens.length);
                for (var i = startPos; i >=  0 && wrongSentencePos > 0 && correctedSentencePos > 0 ; i--) {
                    if (wrongSentenceTokens[wrongSentencePos] != correctedSentenceTokens[correctedSentencePos]) {
                        return i;
                    }
                    wrongSentencePos--;
                    correctedSentencePos--;
                }
                return -1;
            }
            
            function addToken(defaultValue) {
                var newToken = $('#tokenTemplate').clone();
                elementCount++;
                var newId = 'token'+elementCount;
                newToken.attr('id', newId);
                newToken.find('[name="type"]').attr('name', "type"+elementCount);  //prevent mixing up radio buttons
                newToken.appendTo('#sortable');
                var newTokenField = $("#" + newId + " [name='word']"); 
                if (defaultValue) {
                    newTokenField.attr('value', defaultValue);
                }
                newTokenField.focus();
            }

            function addMarker() {
                var startMarkerId = getNewId();
                var startMarker = getMarkerFromTemplate('#markerStartTemplate', startMarkerId);
                startMarker.find('[name="type"]').attr('name', "type"+elementCount);  //prevent mixing up radio buttons
                startMarker.prependTo('#sortable');
                $("#" + startMarkerId + " [name='word']").attr('value', MARKER_START);
                
                var endMarkerId = getNewId();
                var endMarker = getMarkerFromTemplate('#markerEndTemplate', endMarkerId);
                endMarker.find('[name="type"]').attr('name', "type"+elementCount);  //prevent mixing up radio buttons
                endMarker.appendTo('#sortable');
                $("#" + endMarkerId + " [name='word']").attr('value', MARKER_END);
            }

            function getNewId() {
                elementCount++;
                return 'token'+elementCount;
            }
            
            function getMarkerFromTemplate(templateSelector, newId) {
                var newToken = $(templateSelector).clone();
                newToken.attr('id', newId);
                return newToken;
            }

            function removeParent(event) {
                event.target.parentNode.remove();
            }
            
            // ---------------------------------------------------------------

            function evaluateRule() {
                $('#evaluateSpinner').show();
                var ruleXml = buildXml();
                //console.log(ruleXml);
                var dataArray = {
                    xml: ruleXml,
                    language: '${language.getName().encodeAsHTML()}',
                    checkMarker: 'false'
                };
                $.ajax({
                    type: "POST",
                    url: '${resource(dir: 'ruleEditor', file: 'checkXml')}',
                    data: dataArray,
                    success: function(data) {
                        $('#evaluationResult').html("<h2>Evaluation Results</h2>" + data);
                    },
                    error: function(xhr, ajaxOptions, thrownError) {
                        $('#evaluationResult').html(xhr.status + " " + thrownError + "<br/>" + xhr.responseText);
                    },
                    complete: function(jqXHR, textStatus) {
                        $('#evaluateSpinner').hide();
                    }
                });
            }

            function buildXml() {
                var domElements = $('#sortable li');
                var xml = "";
                xml += "<rule name=\"" + $('#ruleName').attr('value').htmlEscape() + "\">\n";
                xml += " <pattern>\n";
                for (var i = 0; i < domElements.length; i++) {
                    var tokenField = $(domElements[i]).find('[name="word"]');
                    var tokenType = getTokenType(domElements[i]);
                    var tokenValue = tokenField.attr('value').htmlEscape();
                    if (tokenType == 'word') {
                        xml += "  <token>" + tokenValue + "</token>\n";
                    } else if (tokenType == 'regex') {
                        xml += "  <token regexp='yes'>" + tokenValue + "</token>\n";
                    } else if (tokenType == 'marker' && tokenValue == MARKER_START) {
                        xml += "  <marker>\n";
                    } else if (tokenType == 'marker' && tokenValue == MARKER_END) {
                        xml += "  </marker>\n";
                    } else {
                        console.warn("Unknown token type '" + tokenType + "' for the following element:");
                        console.warn(domElements[i]);
                    }
                }
                xml += " </pattern>\n";
                xml += " <message>" + $('#ruleErrorMessage').attr('value').htmlEscape() + "</message>\n";
                xml += " <example type='incorrect'>" + $('#wrongSentence').attr('value').htmlEscape() + "</example>\n";
                xml += " <example type='correct'>" +  $('#correctedSentence').attr('value').htmlEscape() + "</example>\n";
                xml += "</rule>\n";
                return xml;
            }

            function getTokenType(domElement) {
                var wordTypes = $(domElement).find('[name^="type"]');  // starts with (e.g. "type3")
                for (var j = 0; j < wordTypes.length; j++) {
                    if ($(wordTypes[j]).attr('checked')) {
                        return wordTypes[j].value;
                    }
                }
                return "";
            }

            function showXml() {
                var xml = buildXml();
                var dialogElem = $("#dialog-message");
                dialogElem.html("This is your rule in XML format:<br/><br/>" + 
                        "<pre>" + xml.htmlEscape() + "</pre>");
                dialogElem.dialog({
                    modal: true,
                    width: 600,
                    buttons: {
                        Ok: function() {
                            $(this).dialog("close");
                        }
                    }
                });
            }
            
        </script>
    </head>
    <body>

        <div class="body">

            <g:render template="/languageSelection"/>

            <h1>LanguageTool Online Rule Editor</h1>
            
            <div class="warn" style="width:300px">Warning: This is still a prototype</div>

            <g:form id="ruleForm" name="ruleForm" method="post">

                <h2>Rule</h2>

                Rule Name: <g:textField id="ruleName" name="ruleName" value="" placeholder="a short rule description"/>

                
                <h2>Example Sentences</h2>
                
                <table style="width:auto;border-style: hidden">
                    <tr>
                        <td>Wrong Sentence:</td>
                        <td>
                            <g:textField class="exampleSentenceField" id="wrongSentence" name="wrongSentence" value="Sorry for my bed English."/>
                            <div id="wrongSentenceEvaluationResult"></div>
                        </td>
                    </tr>
                    <tr>
                        <td>Corrected Sentence:</td>
                        <td>
                            <g:textField class="exampleSentenceField" id="correctedSentence" name="correctedSentence" value="Sorry for my bad English."/>
                            <div id="correctedSentenceEvaluationResult" style="display: none"></div>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <input type="submit" onclick="createPattern();return false;" value="Create Error Pattern"/>
                            <img id="createPatternSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
                        </td>
                    </tr>
                </table>
                
                
                <div id="errorPatternPart" style="display: none">
                    
                    <h2>Error Pattern</h2>
                    
                    <!-- Templates, will be copied when new tokens are added: -->
                    <ul style="display: none">
                    <li id="tokenTemplate" class="ui-state-default"><span class="dragHandle">&#8691;</span>
                        <g:textField onkeypress="return handleReturnForToken(event);" name="word"/>
                        <label><g:radio name="type" value="word" checked="checked"/> Word</label>
                        <label><g:radio name="type" value="regex"/> RegEx</label>
                        <!--
                        TODO:
                        <label><g:radio name="type" value="pos"/> Part-of-speech</label>
                        <label><g:radio name="type" value="any"/> Any Word</label>
                        <label><g:checkBox name="negation" value="any"/> Anything but this</label>
                        -->
                        <a class="removeLink" href="#" onclick="removeParent(event);return false;">Remove</a>
                        </li>
                        <li id="markerStartTemplate" class="ui-state-default"><span class="dragHandle">&#8691;</span>
                            Marker Start. The error underline will start here.
                            <g:textField disabled="disabled" name="word" style="display:none"/>
                            <span style="display: none"><g:radio name="type" value="marker" checked="checked"/></span>
                            <a class="removeLink" href="#" onclick="removeParent(event);return false;">Remove</a>
                        </li>
                        <li id="markerEndTemplate" class="ui-state-default"><span class="dragHandle">&#8691;</span>
                            Marker End. The error underline will end here.
                            <g:textField disabled="disabled" name="word" style="display:none"/>
                            <span style="display: none"><g:radio name="type" value="marker" checked="checked"/></span>
                            <a class="removeLink" href="#" onclick="removeParent(event);return false;">Remove</a>
                        </li>
                    </ul>
                    <!-- End of templates -->
                
                    <div id="patternArea">
                        <div id="dragContainment">
                            <!-- we need this so dragging to first and last position always works properly: -->
                            <div style="padding-top:10px;padding-bottom:10px;">
                                <ul id="sortable">
                                </ul>
                            </div>
                        </div>
        
                        <a href="#" onclick="addToken();return false;">Add another word</a> &middot;
                        <a href="#" onclick="addMarker();return false;">Add marker</a>
                    </div>
    
                    
                    <h2>Error Message</h2>
    
                    <table style="width:auto;border-style: hidden">
                        <tr>
                            <td>Message:</td>
                            <td><g:textField onkeypress="return handleReturnForToken(event);" id="ruleErrorMessage"
                                             name="ruleErrorMessage" value="" placeholder="message shown to the user"/></td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <input type="submit" onclick="evaluateRule();return false;" value="Evaluate Rule"/>
                                <!--<input type="submit" onclick="showXml();return false;" value="Show XML"/>-->
                                <img id="evaluateSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div class="evaluationResultArea">
                                    <div id="evaluationResult"></div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <input class="evaluationResultArea" type="submit" onclick="showXml();return false;" value="Show XML"/>
                                <div id="dialog-message" style="display: none">HALLO ich bin ein dialog</div>
                            </td>
                        </tr>
                    </table>

                </div>

            </g:form>

        </div>

        <script type="text/javascript">
            document.ruleForm.wrongSentence.select();
        </script>

    </body>
</html>
