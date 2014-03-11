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
    
  <form>

      <noscript class="warn">Please turn on Javascript.</noscript>

      <h1>Example Sentences</h1>
      
      <table>
          <tr>
              <td width="120"><label for="wrongSentence">Wrong sentence:</label></td>
              <td>
                  <input type="text" ng-model="wrongSentence" id="wrongSentence" placeholder="A example sentence"/><br/>
                  <a href="#" ng-click="analyzeWrongSentence()" ng-show="!wrongSentenceAnalysis">Show analysis</a>
                  <a ng-show="wrongSentenceAnalysis" ng-cloak href="#" ng-click="hideWrongSentenceAnalysis()">Hide analysis</a>
                  <div id="wrongSentenceAnalysis" ng-show="wrongSentenceAnalysis" ng-bind-html="wrongSentenceAnalysis" ng-cloak></div>
              </td>
          </tr>
          <tr>
              <td><label for="correctedSentence">Corrected sentence:</label></td>
              <td><input type="text" ng-model="correctedSentence" id="correctedSentence" placeholder="An example sentence"/></td>
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
          
          <span class="warn" ng-show="patternElements.length == 0">Please add at least one element</span>

          <div id="patternArea">
              <div id="dragContainment">
                  <!-- we need this so dragging to first and last position always works properly: -->
                  <div style="padding-top:10px;padding-bottom:10px;">
                      <ul class="sortable" ui-sortable="sortableOptions" ng-model="patternElements">
                          <li ng-repeat="element in patternElements">
                              <!--<input type="text" ng-model="element.tokenValue" ng-keypress="handleReturnForToken($event)"/>-->
                              <!-- TODO: why won't enter here show the evaluation result div? (it works for message below) -->
                              <div ng-switch on="element.tokenType">
                                  <div ng-switch-when="marker">
                                      <span class="dragHandle">&#8691;</span>
                                      {{element.tokenValue}}
                                      <a class="removeLink" href="#" ng-click="removeElement(element)">Remove</a>
                                  </div>
                                  <div ng-switch-default>
                                      <span class="dragHandle">&#8691;</span>
                                      <input type="text" ng-model="element.tokenValue" ng-enter="evaluateErrorPattern()" 
                                             placeholder="word or part-of-speech tag" focus-me="focusInput"/>
                                      <label><input type="radio" ng-model="element.tokenType" value="word"/>&nbsp;Word</label>
                                      <label><input type="radio" ng-model="element.tokenType" value="posTag"/>&nbsp;POS tag</label>
                                      <a class="removeLink" href="#" ng-click="removeElement(element)">Remove</a>
                                  </div>
                              </div>
                          </li>
                      </ul>
                  </div>
              </div>

              <a href="#" ng-click="addElement()">Add element</a>
              <span ng-show="hasNoMarker()">
              &middot;
                  <a href="#" ng-click="addMarker()">Add marker</a>
              </span>
          </div>


          <h1>Rule Details</h1>
          
          <table>
              <tr>
                  <td width="120">Message:</td>
                  <td><input type="text" ng-model="ruleMessage" ng-enter="evaluateErrorPattern()" placeholder="Error shown to the user if pattern matches"/></td>
              </tr>
              <tr>
                  <td>Rule Name:</td>
                  <td><input type="text" ng-model="ruleName" placeholder="Short rule description used for configuration"/></td>
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


      <div ng-show="patternEvaluated" ng-cloak>

          <h1>Evaluation Results</h1>

          <div id="evaluationResult"></div>
          <!-- too slow: <div ng-bind-html="evaluationResult"></div>-->
          
      </div>

  </form>

  <br/>
  <hr/>
  <br/>
  
  <p>XML: <pre ng-cloak>{{buildXml()}}</pre>

</div>

</body>
</html>
