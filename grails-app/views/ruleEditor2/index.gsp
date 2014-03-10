<!doctype html>
<html lang="en" ng-app="ruleEditor">
<head>
  <meta charset="utf-8">
  <title>LanguageTool RuleEditor</title>
  <script type="text/javascript" src="${resource(dir:'js/jquery', file:'jquery-1.7.1.js')}"></script>
  <script type="text/javascript" src="${resource(dir:'js/jquery-ui', file:'jquery-ui-1.10.4.min.js')}"></script>
  <link rel="stylesheet" href="${resource(dir:'css/jquery-ui/themes/smoothness', file:'jquery-ui.css')}">
</head>
<body ng-controller="RuleEditorCtrl">

  <script>
      // used in *.js as GSP doesn't get evaluated there:
      var __ruleEditorEvaluationUrl = '${resource(dir: 'ruleEditor', file: 'checkXml')}';
      var __ruleEditorSentenceAnalysisUrl = '${resource(dir: 'analysis', file: 'tokenizeSentences')}';
  </script>
  <script src="${resource(dir:'js/angular/lib', file:'angular.js')}"></script>
  <script src="${resource(dir:'js/angular/lib', file:'angular-sanitize.min.js')}"></script>
  <script src="${resource(dir:'js/angular', file:'app.js')}"></script>
  <script src="${resource(dir:'js/angular', file:'services.js')}"></script>
  <script src="${resource(dir:'js/angular', file:'directives.js')}"></script>
  <script src="${resource(dir:'js/angular/modules', file:'sortable.js')}"></script>

  <form>
      
      <h1>Rule</h1>

      Rule Name: <input type="text" ng-model="ruleName" placeholder="a short rule description"/>

      
      <h1>Example Sentences</h1>

      Wrong sentence: <input type="text" ng-model="wrongSentence" placeholder="A example sentence"/><br/>
      Corrected sentence: <input type="text" ng-model="correctedSentence" placeholder="An example sentence"/>

      <br/>
      <input type="submit" ng-click="createErrorPattern()" value="Create error pattern">
      <img ng-show="patternCreationInProgress" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>


      <div ng-show="patternCreated">
      
          <h1>Error Pattern</h1>
          
          <span style="color:red" ng-show="patternElements.length == 0">Please add at least one element</span>
          
          <ul ui-sortable ng-model="patternElements">
              <li ng-repeat="element in patternElements">
                  <!--<input type="text" ng-model="element.tokenValue" ng-keypress="handleReturnForToken($event)"/>-->
                  <!-- TODO: why won't enter here show the evaluation result div? (it works for message below) -->
                  <div ng-switch on="element.tokenType">
                    <div ng-switch-when="marker">
                        {{element.tokenValue}}
                        <a href="#" ng-click="removeElement(element)">Remove</a>
                    </div>
                    <div ng-switch-default>
                        <input type="text" ng-model="element.tokenValue" ng-enter="evaluateErrorPattern()"/>
                        <label><input type="radio" ng-model="element.tokenType" value="word"/>Word</label>
                        <label><input type="radio" ng-model="element.tokenType" value="posTag"/>POS tag</label>
                        <a href="#" ng-click="removeElement(element)">Remove</a>
                    </div>
                  </div>
              </li>
          </ul>
    
          <!--
          <ul>
              <li ng-repeat="element in patternElements">
                {{element.tokenValue}}
              </li>
          </ul>-->
    
          <a href="#" ng-click="addElement()">Add element</a>
          <span ng-show="hasNoMarker()">
            &middot;
            <a href="#" ng-click="addMarker()">Add marker</a>
          </span>

          <h1>Error Message</h1>

          Message: <input type="text" ng-model="ruleMessage" ng-enter="evaluateErrorPattern()"/>

          <br/>
          <input ng-show="patternCreated" type="submit" ng-click="evaluateErrorPattern()" value="Evaluate error pattern">
          <img ng-show="patternEvaluationInProgress" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>

      </div>


      <div ng-show="patternEvaluated">

          <h1>Evaluation Results</h1>

          <div id="evaluationResult"></div>
          <!-- too slow: <div ng-bind-html="evaluationResult"></div>-->
          
      </div>

  </form>

  <hr/>
  
  <p>XML: <pre>{{buildXml()}}</pre>

</body>
</html>
