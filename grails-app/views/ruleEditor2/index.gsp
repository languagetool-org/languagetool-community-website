<%@ page import="org.languagetool.JLanguageTool; org.languagetool.Language" %>
<!doctype html>
<html><!-- see layout for attributes -->
<head>
    <script type="text/javascript" src="${resource(dir:'js/jquery', file:'jquery-1.7.1.js')}"></script>
    <script type="text/javascript" src="${resource(dir:'js/jquery-ui', file:'jquery-ui-1.10.4.min.js')}"></script>
    <link rel="stylesheet" href="${resource(dir:'css/jquery-ui/themes/smoothness', file:'jquery-ui.css')}">
    <link rel="stylesheet" href="${resource(dir:'css', file:'ruleEditor.css')}">
    <meta name="layout" content="angularRuleEditor" />
    <title><g:message code="ltc.editor.title"/></title>
    <script>
        // used in *.js as GSP doesn't get evaluated there:
        var __ruleEditorEvaluationUrl = '${resource(dir: 'ruleEditor', file: 'checkXml')}';
        var __ruleEditorTokenizeSentencesUrl = '${resource(dir: 'analysis', file: 'tokenizeSentences')}';
        var __ruleEditorSentenceAnalysisUrl = '${resource(dir: 'analysis', file: 'analyzeTextForEmbedding')}';
    </script>
    <script src="${resource(dir:'js/angular/lib', file:'angular.js')}"></script>
    <script src="${resource(dir:'js/angular/lib', file:'angular-sanitize.min.js')}"></script>
    <script src="${resource(dir:'js/angular', file:'app.js')}"></script>
    <script src="${resource(dir:'js/angular', file:'services.js')}"></script>
    <script src="${resource(dir:'js/angular', file:'directives.js')}"></script>
    <script src="${resource(dir:'js/angular/modules', file:'sortable.js')}"></script>
</head>
<body><!-- see layout for attributes -->

<div class="body ruleEditor">

  <p id="introText">LanguageTool finds errors based on rules. This page will help you
  to create your own rules. As a result, you will have your rule in XML format, which you
  can <a href="https://languagetool.org/support/" target="_blank">send to the developers</a> for inclusion in LanguageTool
  or add to your <tt>grammar.xml</tt> file for local use.</p>

  <p class="warn">Note: this version of the rule editor is an incomplete prototype</p>
    
  <form>

      <noscript class="warn">Please turn on Javascript.</noscript>

      <h1>Example Sentences</h1>
      
      <table>
          <tr>
              <td width="120" class="metaInfo">Version:</td>
              <td class="metaInfo">
                  LanguageTool ${JLanguageTool.VERSION} (${JLanguageTool.BUILD_DATE})
              </td>
          </tr>
          <tr>
              <td><label for="language">Language:</label></td>
              <td>
                  <select name="language" id="language" ng-model="languageCode" ng-options="c.name for c in languageCodes"></select>
              </td>
          </tr>
          <tr>
              <td><label for="wrongSentence">Wrong sentence:</label></td>
              <td>
                  <input type="text" ng-model="wrongSentence" id="wrongSentence" placeholder="A example sentence"/>
              </td>
          </tr>
          <tr>
              <td></td>
              <td>
                  <a href ng-click="analyzeWrongSentence()" ng-show="!wrongSentenceAnalysis && wrongSentence">Show analysis</a>
                  <span ng-show="wrongSentenceAnalysis" ng-cloak>
                    <a href ng-click="analyzeWrongSentence()">Update analysis</a> &middot;
                    <a href ng-click="hideWrongSentenceAnalysis()">Hide analysis</a>
                  </span>
                  <div id="wrongSentenceAnalysis" class="sentenceAnalysis" ng-show="wrongSentenceAnalysis" ng-bind-html="wrongSentenceAnalysis" ng-cloak></div>
              </td>
          </tr>
          <tr>
              <td><label for="correctedSentence">Corrected sentence:</label></td>
              <td><input type="text" ng-model="correctedSentence" id="correctedSentence" placeholder="An example sentence"/></td>
          </tr>
          <tr>
              <td></td>
              <td>
                  <a href ng-click="analyzeCorrectedSentence()" ng-show="!correctedSentenceAnalysis && correctedSentence">Show analysis</a>
                  <span ng-show="correctedSentenceAnalysis" ng-cloak>
                      <a href ng-click="analyzeCorrectedSentence()">Update analysis</a> &middot;
                      <a href ng-click="hideCorrectedSentenceAnalysis()">Hide analysis</a>
                  </span>
                  <div id="correctedSentenceAnalysis" class="sentenceAnalysis" ng-show="correctedSentenceAnalysis" ng-bind-html="correctedSentenceAnalysis" ng-cloak></div>
              </td>
          </tr>
          <tr>
              <td></td>
              <td>
                  <input type="submit" ng-click="createErrorPattern()" value="Create error pattern" ng-disabled="!(wrongSentence && correctedSentence)"/>
                  <img ng-show="patternCreationInProgress" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol" ng-cloak/>
              </td>
          </tr>
      </table>


      <div ng-show="patternCreated" ng-cloak>
      
          <h1>Error Pattern</h1>

          <div id="patternArea">

              <div ng-cloak ng-show="knownMatchesHtml">
                  <strong>Note:</strong> LanguageTool can already detect the following error(s) in your example sentence:
                  <div ng-cloak ng-bind-html="knownMatchesHtml"></div>
              </div>
              
              <label><input ng-model="caseSensitive" type="checkbox"/>&nbsp;Case-sensitive word matching</label>

              <div class="warn" ng-show="patternElements.length == 0">Please add at least one token to the pattern</div>

              <div id="dragContainment">
                  <!-- we need this so dragging to first and last position always works properly: -->
                  <div style="padding-top:20px;padding-bottom:30px;">
                      <ul class="sortable" ui-sortable="sortableOptions" ng-model="patternElements">
                          <li ng-repeat="element in patternElements">
                              <!--<input type="text" ng-model="element.tokenValue" ng-keypress="handleReturnForToken($event)"/>-->
                              <!-- TODO: why won't enter here show the evaluation result div? (it works for message below) -->
                              <div ng-switch on="element.tokenType">
                                  <div ng-switch-when="marker">
                                      <span class="dragHandle">&#8691; {{element.tokenValue}}</span>
                                      <a class="removeLink" href ng-click="removeElement(element)">Remove</a>
                                  </div>
                                  <div ng-switch-default>
                                      <span class="dragHandle">&#8691; Token #{{elementPosition(element)}}</span>
                                      <a class="removeLink" href ng-click="removeElement(element)">Remove</a>
                                      <div style="margin-left: 15px">

                                        <label><input type="radio" ng-model="element.tokenType" value="word"/>&nbsp;Word</label>
                                        <label><input type="radio" ng-model="element.tokenType" value="posTag"/>&nbsp;Part-of-speech</label>
                                        <label><input type="radio" ng-model="element.tokenType" value="word_and_posTag"/>&nbsp;Word + Part-of-speech</label>
                                        <label><input type="radio" ng-model="element.tokenType" value="any"/>&nbsp;Any word</label>
                                          
                                        <table>
                                            <tr ng-show="element.tokenType == 'word' || element.tokenType == 'word_and_posTag'">
                                                <td>Word:</td>
                                                <td>
                                                    <div>
                                                        <input type="text" ng-model="element.tokenValue" ng-enter="evaluateErrorPattern()"
                                                                     placeholder="word" focus-me="focusInput" />
                                                        <label title="Interpret the given word as a regular expression"><input type="checkbox" ng-model="element.regex" value="true" ng-disabled="element.tokenType == 'any'"/>&nbsp;RegExp</label>
                                                        <label title="Matches the base form (e.g. the singular for nouns) of the given word"><input type="checkbox" ng-model="element.baseform" value="false" />&nbsp;Base&nbsp;form</label>
                                                        <label title="Matches anything but the given word"><input type="checkbox" ng-model="element.negation" value="false" />&nbsp;Negate</label>
                                                        <br/>
                                                        <div ng-show="element.tokenValue.contains(' ')">
                                                            <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> Add another token instead of using spaces in a token
                                                        </div>
                                                        <div ng-show="looksLikeRegex(element.tokenValue) && !element.regex">
                                                            <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> This looks like a regular expression, but the "RegExp" checkbox is not checked
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr ng-show="element.tokenType == 'posTag' || element.tokenType == 'word_and_posTag'">
                                                <td>Part-of-speech:</td>
                                                <td>
                                                    <div>
                                                        <input type="text" ng-model="element.posTag" ng-enter="evaluateErrorPattern()"
                                                                               placeholder="part-of-speech tag" focus-me="focusInput" />
                                                        <label title="Interpret the given part-of-speech tag as a regular expression"><input type="checkbox" ng-model="element.posTagRegex" value="true" ng-disabled="element.tokenType == 'any'"/>&nbsp;RegExp</label>
                                                        <label title="Matches anything but the given part-of-speech tag"><input type="checkbox" ng-model="element.posTagNegation" value="false" />&nbsp;Negate</label>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                          
                                        <ul>
                                          <li ng-repeat="exception in element.exceptions">
                                              and:

                                              <a href ng-click="removeException(element, exception)" class="removeLink">Remove exception</a>

                                              <!-- copied from above, 'element' replaced with 'exception': -->

                                              <label><input type="radio" ng-model="exception.tokenType" value="word"/>&nbsp;Word</label>
                                              <label><input type="radio" ng-model="exception.tokenType" value="posTag"/>&nbsp;Part-of-speech</label>
                                              <label><input type="radio" ng-model="exception.tokenType" value="word_and_posTag"/>&nbsp;Word + Part-of-speech</label>

                                              <table>
                                                  <tr ng-show="exception.tokenType == 'word' || exception.tokenType == 'word_and_posTag'">
                                                      <td>Word:</td>
                                                      <td>
                                                          <div>
                                                              <input type="text" ng-model="exception.tokenValue" ng-enter="evaluateErrorPattern()"
                                                                     placeholder="word" focus-me="focusInput" />
                                                              <label title="Interpret the given word as a regular expression"><input type="checkbox" ng-model="exception.regex" value="true" ng-disabled="exception.tokenType == 'any'"/>&nbsp;RegExp</label>
                                                              <label title="Matches the base form (e.g. the singular for nouns) of the given word"><input type="checkbox" ng-model="exception.baseform" value="false" />&nbsp;Base&nbsp;form</label>
                                                              <label title="Matches anything but the given word"><input type="checkbox" ng-model="exception.negation" value="false" />&nbsp;Negate</label>
                                                              <br/>
                                                              <div ng-show="exception.tokenValue.contains(' ')">
                                                                  <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> Add another token instead of using spaces in a token
                                                              </div>
                                                              <div ng-show="looksLikeRegex(exception.tokenValue) && !exception.regex">
                                                                  <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> This looks like a regular expression, but the "RegExp" checkbox is not checked 
                                                              </div>
                                                          </div>
                                                      </td>
                                                  </tr>
                                                  <tr ng-show="exception.tokenType == 'posTag' || exception.tokenType == 'word_and_posTag'">
                                                      <td>Part-of-speech:</td>
                                                      <td>
                                                          <div>
                                                              <input type="text" ng-model="exception.posTag" ng-enter="evaluateErrorPattern()"
                                                                     placeholder="part-of-speech tag" focus-me="focusInput" />
                                                              <label title="Interpret the given part-of-speech tag as a regular expression"><input type="checkbox" ng-model="exception.posTagRegex" value="true" ng-disabled="exception.tokenType == 'any'"/>&nbsp;RegExp</label>
                                                              <label title="Matches anything but the given part-of-speech tag"><input type="checkbox" ng-model="exception.posTagNegation" value="false" />&nbsp;Negate</label>
                                                          </div>
                                                      </td>
                                                  </tr>
                                              </table>

                                          </li>
                                        </ul>
                                          
                                        <div>
                                            <a href ng-click="addException(element)" title="Add an exception for this element">Add exception</a>
                                        </div>
                                          
                                      </div>
                                  </div>
                              </div>
                          </li>
                      </ul>
                  </div>
              </div>

              &nbsp;<a href ng-click="addElement()">Add token to pattern</a>
              <span ng-show="hasNoMarker()">
              &middot;
                  <a href ng-click="addMarker()">Add error marker to pattern</a>
              </span>
          </div>


          <h1>Rule Details</h1>
          
          <table>
              <tr>
                  <td width="120"><label for="ruleMessage">Message:</label></td>
                  <td><input type="text" id="ruleMessage" ng-model="ruleMessage" ng-enter="evaluateErrorPattern()" placeholder="Error shown to the user if pattern matches"/></td>
              </tr>
              <tr>
                  <td><label for="ruleName">Rule Name:</label></td>
                  <td><input type="text" id="ruleName" ng-model="ruleName" placeholder="Short rule description used for configuration"/></td>
              </tr>
              <tr>
                  <td></td>
                  <td>
                      <input ng-show="patternCreated" type="submit" ng-click="evaluateErrorPattern()" 
                             value="Evaluate error pattern" ng-disabled="patternElements.length == 0">
                      <img ng-show="patternEvaluationInProgress" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
                  </td>
              </tr>
          </table>

      </div>

      <h1>Debugging: XML</h1>

      <pre id="ruleAsXml" ng-cloak>{{buildXml()}}</pre>


      <div ng-show="patternEvaluated" ng-cloak>

          <h1>Evaluation Results</h1>

          <div id="evaluationResult" ng-class="{inProgress: patternEvaluationInProgress}"></div>
          <!-- too slow: <div ng-bind-html="evaluationResult"></div>-->
          
      </div>

  </form>

</div>

</body>
</html>
