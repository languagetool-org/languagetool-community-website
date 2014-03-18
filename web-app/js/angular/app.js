/* LanguageTool Community Website 
 * Copyright (C) 2014 Daniel Naber (http://www.danielnaber.de)
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
 * USA
 */
'use strict';

var ruleEditor = angular.module('ruleEditor', [
  'ruleEditor.services',
  'ui.sortable',
  'ui.sortable',
  'ruleEditor.directives',
  'ngSanitize'  // show non-escaped HTML
]);

ruleEditor.controller('RuleEditorCtrl', function ($scope, $http, $q, SentenceComparator, XmlBuilder) {

  String.prototype.htmlEscape = function() {
    return $('<div/>').text(this.toString()).html();
  };

  String.prototype.attributeEscape = function() {
    return this.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/'/g, "&apos;");
  };

  $scope.sortableOptions = {
    handle: '.dragHandle', containment: '#dragContainment', axis: 'y'
  };

  var __LT_MARKER_START = 'Marker start';
  var __LT_MARKER_END = 'Marker end';

  $scope.languageCodes = [
    {code: 'ast', name: 'Asturian'},
    {code: 'be', name: 'Belarusian'},
    {code: 'br', name: 'Breton'},
    {code: 'ca', name: 'Catalan'},
    {code: 'zh', name: 'Chinese'},
    {code: 'da', name: 'Danish'},
    {code: 'nl', name: 'Dutch'},
    {code: 'en', name: 'English'},
    {code: 'eo', name: 'Esperanto'},
    {code: 'fr', name: 'French'},
    {code: 'gl', name: 'Galician'},
    {code: 'de', name: 'German'},
    {code: 'el', name: 'Greek'},
    {code: 'is', name: 'Icelandic'},
    {code: 'it', name: 'Italian'},
    {code: 'ja', name: 'Japanese'},
    {code: 'km', name: 'Khmer'},
    {code: 'lt', name: 'Lithuanian'},
    {code: 'ml', name: 'Malayalam'},
    {code: 'pl', name: 'Polish'},
    {code: 'pt', name: 'Portuguese'},
    {code: 'ro', name: 'Romanian'},
    {code: 'ru', name: 'Russian'},
    {code: 'sk', name: 'Slovak'},
    {code: 'sl', name: 'Slovenian'},
    {code: 'es', name: 'Spanish'},
    {code: 'sv', name: 'Swedish'},
    {code: 'tl', name: 'Tagalog'},
    {code: 'uk', name: 'Ukrainian'}
  ];
  $scope.languageCode = $scope.languageCodes[7];  // English
  $scope.ruleName = "";
  $scope.caseSensitive = false;
  $scope.exampleSentences = [
    //for easier/faster testing:
    {text: 'Sorry for my bed English.', type: 'wrong', analysis: null},
    {text: 'Sorry for my bad English.', type: 'corrected', analysis: null}
    //{text: '', type: 'wrong', analysis: null},
    //{text: '', type: 'corrected', analysis: null}
  ];

  $scope.ruleMessage = "";

  $scope.patternCreated = false;
  $scope.patternEvaluated = false;
  $scope.patternElements = [];
  $scope.knownMatchesHtml = null;  // rule matches that LT already can find without this new rule
  $scope.evaluationResult = null;  // HTML with rule matches in Wikipedia/Tatoeba
  
  $scope.wrongSentenceAnalysis = null;
  $scope.correctedSentenceAnalysis = null;
  $scope.patternCreationInProgress = false;
  $scope.patternEvaluationInProgress = false;

  $scope.addWrongExampleSentence = function() {
    var sentence = {text: '', type: 'wrong', analysis: null};
    this.exampleSentences.push(sentence);
    return sentence;
  };
  
  $scope.addCorrectedExampleSentence = function() {
    var sentence = {text: '', type: 'corrected', analysis: null};
    this.exampleSentences.push(sentence);
    return sentence;
  };
  
  $scope.removeExampleSentence = function(exampleSentence) {
    var index = this.exampleSentences.indexOf(exampleSentence);
    if (index > -1) {
      this.exampleSentences.splice(index, 1);
    } else {
      console.warn("Example sentence not found: " + exampleSentence);
    }
  };
  
  $scope.analyzeSentence = function(exampleSentence) {
    var self = this;
    var data = "text=" + encodeURIComponent(exampleSentence.text) + "&lang=" + this.languageCode.code;
    this.patternCreationInProgress = true;
    $http({
      url: __ruleEditorSentenceAnalysisUrl,
      method: 'POST',
      data: data,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'}
    }).success(function(data) {
        exampleSentence.analysis = data;
        self.patternCreationInProgress = false;
      })
      .error(function(data, status, headers, config) {
        exampleSentence.analysis = data;
        self.patternCreationInProgress = false;
      });
  };

  $scope.hideSentenceAnalysis = function(exampleSentence) {
    exampleSentence.analysis = null;
  };

  $scope.createErrorPattern = function() {
    var self = this;
    this.patternCreationInProgress = true;
    if (this.patternCreated) {
      if (!confirm("Re-create the pattern, overwriting the existing one?")) {
        this.patternCreationInProgress = false;
        return;
      } else {
        this.patternElements = [];
      }
    }
    var wrongSentence = this.exampleSentences[0].text;
    var correctedSentence = this.exampleSentences[1].text;
    var incorrectTokensPromise = SentenceComparator.incorrectTokens(__ruleEditorTokenizeSentencesUrl, this.languageCode.code,
        wrongSentence, correctedSentence);
    incorrectTokensPromise.then(
      function(result) {
        for (var i = 0; i < result.tokens.length; i++) {
          self.addElement(result.tokens[i]);
        }
        self.knownMatchesHtml = result.matchesHtml;
        self.patternCreated = true;
        self.patternEvaluated = false;
        self.patternCreationInProgress = false;
      },
      function(data) {
        alert("Could not tokenize example sentences: " + data);
        self.patternCreationInProgress = false;
      },
      function(data) {}
    );
  };

  $scope.addElement = function(tokenValue, properties) {
    var elem = {
      tokenValue: tokenValue,
      tokenType: 'word',
      inflected: false,
      regex: false,
      negation: false,
      posTag: '',
      posTagRegex: false,
      posTagNegation: false,
      exceptions: []
    };
    if (properties) {
      elem = jQuery.extend({}, elem, properties);
    }
    this.patternElements.push(elem);
    this.focusInput = true;
    return elem;
  };

  $scope.setElement = function(tokenValue, properties) {
    this.patternElements = [];
    return this.addElement(tokenValue, properties);
  };

  $scope.addException = function(element, properties) {
    var ex = {
      tokenValue: '',
      tokenType: 'word',
      inflected: false,
      regex: false,
      negation: false,
      posTag: '',
      posTagRegex: false,
      posTagNegation: false
    };
    if (properties) {
      ex = jQuery.extend({}, ex, properties);
    }
    element.exceptions.push(ex);
    this.focusExceptionInput = true;
  };

  $scope.removeException = function(element, exception) {
    var index = this.patternElements.indexOf(element);
    if (index > -1) {
      var exceptionIndex = this.patternElements[index].exceptions.indexOf(exception);
      if (exceptionIndex > -1) {
        this.patternElements[index].exceptions.splice(exceptionIndex, 1);
      } else {
        console.warn("No element/exception found: " + element + " / " + exception);
      }
    } else {
      console.warn("No element found: " + element);
    }
  };

  /** Get the position of the element, not counting markers. */
  $scope.elementPosition = function(elem) {
    var position = 0;
    for (var i = 0; i < this.patternElements.length; i++) {
      if (this.patternElements[i].tokenType != 'marker') {
        position++;
      }
      if (elem == this.patternElements[i]) {
        return position;
      }
    }
    return -1;
  };

  $scope.addMarker = function() {
    this.patternElements.unshift({'tokenValue': __LT_MARKER_START, 'tokenType': 'marker'});
    this.patternElements.push({'tokenValue': __LT_MARKER_END, 'tokenType': 'marker'});
  };

  $scope.hasNoMarker = function() {
    for (var i = 0; i < this.patternElements.length; i++) {
      if (this.patternElements[i].tokenType == 'marker') {
        return false;
      }
    }
    return true;
  };

  $scope.removeElement = function(element) {
    var index = this.patternElements.indexOf(element);
    if (this.patternElements[index].tokenType == 'marker') {
      this.removeMarkers();
    } else {
      if (index > -1) {
        this.patternElements.splice(index, 1);
      } else {
        console.warn("No element found: " + element);
      }
    }
  };

  $scope.removeMarkers = function() {
    for (var i = this.patternElements.length - 1; i >= 0; i--) {
      if (this.patternElements[i].tokenType == 'marker') {
        this.patternElements.splice(i, 1);
      }
    }
  };
  
  /*$scope.handleReturnForToken = function() {
      // TODO: why won't this show the evaluation result div? (this.patternEvaluated = true;) 
      this.evaluateErrorPattern();
    };*/
  
  $scope.evaluateErrorPattern = function() {
    this.patternEvaluationInProgress = true;
    var data = "language=" + encodeURIComponent(this.languageCode.code) + "&checkMarker=false&xml=" + encodeURIComponent(this.buildXml());
    var ctrl = this;
    var url = __ruleEditorEvaluationUrl;  // GSP doesn't evaluate in JS, so we need this hack
    $http({
      url: url,
      method: 'POST',
      data: data,
      // See http://stackoverflow.com/questions/19254029/angularjs-http-post-does-not-send-data:
      headers: {'Content-Type': 'application/x-www-form-urlencoded'}
    }).success(function(data) {
        // TODO: slooooow! see https://github.com/Pasvaz/bindonce
        //ctrl.evaluationResult = data;
        $('#evaluationResult').html(data);
        ctrl.patternEvaluated = true;
        ctrl.patternEvaluationInProgress = false;
      })
      .error(function(data, status, headers, config) {
        // TODO: see above:
        ctrl.patternEvaluated = true;
        $('#evaluationResult').html("Error " + status + ":<br>" + data);
        ctrl.patternEvaluationInProgress = false;
      });
  };

  $scope.buildXml = function() {
    return XmlBuilder.buildXml(this);
  };

  $scope.looksLikeRegex = function(str) {
    return str.match(/[\[\]\|]/);
  };

});
