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
  'ruleEditor.postagHelperServices',
  'ruleEditor.xmlServices',
  'ruleEditor.xmlParseServices',
  'ui.sortable',
  'ui.sortable',
  'ruleEditor.directives',
  'ngSanitize',  // show non-escaped HTML
  'ngAnimate',
  'ngModal'  // see https://github.com/adamalbrecht/ngModal
  ]);

ruleEditor.controller('RuleEditorCtrl', function ($scope, $http, $q, $window, SentenceComparator, XmlBuilder, XmlParser) {

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
  
  var SentenceTypes = {
    WRONG: 'wrong',
    CORRECTED: 'corrected'
  };
  $scope.SentenceTypes = SentenceTypes;

  var TokenTypes = {
    WORD: 'word',
    POS_TAG: 'posTag',
    WORD_AND_POS_TAG: 'word_and_posTag',
    ANY: 'any',
    MARKER: 'marker'
  };
  $scope.TokenTypes = TokenTypes;
  
  var CaseConversion = {
    START_LOWER: 'start lower',
    START_UPPER: 'start upper',
    ALL_LOWER: 'all lower',
    ALL_UPPER: 'all upper',
    PRESERVE: 'preserve'
  };
  $scope.CaseConversion = CaseConversion;
    
  $scope.languages = [
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
    {code: 'fa', name: 'Persian'},
    {code: 'pl', name: 'Polish'},
    {code: 'pt', name: 'Portuguese'},
    {code: 'ro', name: 'Romanian'},
    {code: 'ru', name: 'Russian'},
    {code: 'sk', name: 'Slovak'},
    {code: 'sl', name: 'Slovenian'},
    {code: 'es', name: 'Spanish'},
    {code: 'sv', name: 'Swedish'},
    {code: 'tl', name: 'Tagalog'},
    {code: 'ta', name: 'Tamil'},
    {code: 'uk', name: 'Ukrainian'}
  ];

  $scope.getParam = function(param, url) {
    var paramStr = param + "=";
    var startPos = url.indexOf(paramStr);
    if (startPos > -1) {
      var endPos = url.indexOf("&", startPos);
      if (endPos > -1) {
        return url.substring(startPos + paramStr.length, endPos);
      } else {
        return url.substring(startPos + paramStr.length);
      }
    }
    return null;
  };
  
  var paramLang = $scope.getParam("lang", window.location.href);
  $scope.language = $scope.languages[7];  // English
  $scope.languages.forEach(function($lang) {
    if($lang.code === paramLang) {
      console.log("Setting language to: " + paramLang);
      $scope.language = $lang;
    }
  });
  
  $scope.existingXml = __ruleEditorXml ? __ruleEditorXml.replace(/__NL__/g, "\n").replace(/&apos;/g, "'") : null;  // may be pasted by the user or injected by server
  $scope.ruleName = "";
  $scope.caseSensitive = false;
  var defaultWrongSentence = decodeURIComponent($scope.getParam("wrong", window.location.href) || '').replace(/\+/g, " ");
  var defaultCorrectedSentence = decodeURIComponent($scope.getParam("corrected", window.location.href) || '').replace(/\+/g, " ");
  $scope.exampleSentences = [
    //for easier/faster testing:
    //{text: 'Sorry for my bed English.', type: SentenceTypes.WRONG, analysis: null},
    //{text: 'Sorry for my bad English.', type: SentenceTypes.CORRECTED, analysis: null}
    {text: defaultWrongSentence, type: SentenceTypes.WRONG, analysis: null},
    {text: defaultCorrectedSentence, type: SentenceTypes.CORRECTED, analysis: null}
  ];
  $scope.ruleMessage = "";
  $scope.messageMatches = [];
  $scope.shortRuleMessage = "";
  $scope.patternElements = [];
  $scope.detailUrl = "";

  $scope.gui = {
    expertMode: false,
    patternCreationInProgress: false,
    patternEvaluationInProgress: false,
    patternCreated: false,
    patternEvaluated: false,
    knownMatchesHtml: null,     // rule matches that LT already can find without this new rule
    parseXmlDialogShown: false,
    needPosTagHelp: false,
    posTagHelp: [],
    posTagHelpText: null
    //evaluationResult: null  // HTML with rule matches in Wikipedia/Tatoeba
  };

  /** update this.messageMatches depending on "\1" etc. in the rule message. */
  $scope.$watch('ruleMessage', function(data) {
    $scope.extractMessageMatches(data);
  });

  $scope.extractMessageMatches = function(message) {
    var references = message.match(/\\(\d+)/g);
    var largestNumber = -1;
    var refNumbers = [];
    if (references) {
      for (var i = 0; i < references.length; i++) {
        var refNumber = references[i].substring(1);
        refNumbers.push(refNumber);
        if (i >= $scope.messageMatches.length) {
          $scope.addMessageMatch(refNumber);
        }
      }
    }
    // remove refs not in message anymore:
    for (var j = $scope.messageMatches.length - 1; j >= 0; j--) {
      if (refNumbers.indexOf($scope.messageMatches[j].tokenNumber) === -1) {
        $scope.messageMatches.splice(j, 1);
      }
    }
  };
  
  $scope.$watch('exampleSentences[0]', function(data) {
    $scope.wrongSentenceWithMarker = null;
  }, true);
  
  angular.element($window).on('keydown', function(e) {
    if ($scope.gui.parseXmlDialogShown && e.keyCode === 27) {
      $scope.gui.parseXmlDialogShown = false;
      $scope.$apply();
    }
  });
  
  $scope.enterExpertMode = function() {
    this.gui.expertMode = true;
    $('.header').hide();
  };

  $scope.leaveExpertMode = function() {
    this.gui.expertMode = false;
    $('.header').show();
  };

  $scope.parseExistingXml = function() {
    try {
      var rule = XmlParser.parseXml(this.existingXml);
      $scope.ruleName = rule.ruleName;
      $scope.caseSensitive = rule.caseSensitive;
      this.exampleSentences.length = 0;
      for (var i = 0; i < rule.exampleSentences.length; i++) {
        this.exampleSentences.push(rule.exampleSentences[i]);
      }
      $scope.shortRuleMessage = rule.shortRuleMessage;
      this.patternElements.length = 0;
      for (var j = 0; j < rule.patternElements.length; j++) {
        this.patternElements.push(rule.patternElements[j]);
      }
      $scope.ruleMessage = rule.ruleMessage;
      this.messageMatches.length = 0;
      for (var k = 0; k < rule.messageMatches.length; k++) {
        this.messageMatches.push(rule.messageMatches[k]);
      }
      $scope.detailUrl = rule.detailUrl;
      this.gui.patternCreated = true;
      this.gui.parseXmlDialogShown = false;
      this.evaluateErrorPattern();
    } catch (e) {
      console.error(e);
      alert(e);
    }
  };
  
  $scope.addMessageMatch = function(refNumber) {
    this.messageMatches.push({
      tokenNumber: refNumber,
      caseConversion: CaseConversion.PRESERVE,
      regexMatch: '',
      regexReplace: ''
    });
  };
  
  $scope.getMaxTokenNumber = function() {
    var max = 0;
    for (var i = 0; i < this.messageMatches.length; i++) {
      var number = this.messageMatches[i].tokenNumber;
      if (number > max) {
        max = number;
      }
    }
    return max;
  };
  
  $scope.addWrongExampleSentence = function() {
    var sentence = {text: '', type: SentenceTypes.WRONG, analysis: null};
    this.exampleSentences.push(sentence);
    return sentence;
  };
  
  $scope.addCorrectedExampleSentence = function() {
    var sentence = {text: '', type: SentenceTypes.CORRECTED, analysis: null};
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
    var data = "text=" + encodeURIComponent(exampleSentence.text) + "&lang=" + this.language.code;
    this.gui.patternCreationInProgress = true;
    $http({
      url: __ruleEditorSentenceAnalysisUrl,
      method: 'POST',
      data: data,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'}
    }).success(function(data) {
        exampleSentence.analysis = data;
        self.gui.patternCreationInProgress = false;
      })
      .error(function(data, status, headers, config) {
        exampleSentence.analysis = data;
        self.gui.patternCreationInProgress = false;
      });
  };

  $scope.hideSentenceAnalysis = function(exampleSentence) {
    exampleSentence.analysis = null;
  };

  $scope.createErrorPattern = function() {
    var self = this;
    this.gui.patternCreationInProgress = true;
    if (this.gui.patternCreated) {
      if (!confirm("Re-create the pattern, overwriting the existing one?")) {
        this.gui.patternCreationInProgress = false;
        return;
      } else {
        this.patternElements = [];
      }
    }
    var wrongSentence = this.exampleSentences[0].text;
    var correctedSentence = this.exampleSentences[1].text;
    var incorrectTokensPromise = SentenceComparator.incorrectTokens(__ruleEditorTokenizeSentencesUrl, this.language.code,
        wrongSentence, correctedSentence);
    incorrectTokensPromise.then(
      function(result) {
        for (var i = 0; i < result.tokens.length; i++) {
          self.addElement(result.tokens[i]);
        }
        self.gui.knownMatchesHtml = result.matchesHtml;
        self.gui.patternCreated = true;
        self.gui.patternEvaluated = false;
        self.gui.patternCreationInProgress = false;
      },
      function(data) {
        alert("Could not tokenize example sentences: " + data);
        self.gui.patternCreationInProgress = false;
      },
      function(data) {}
    );
  };

  $scope.addElement = function(tokenValue, properties) {
    var elem = {
      tokenValue: tokenValue,
      tokenType: TokenTypes.WORD,
      inflected: false,
      regex: false,
      negation: false,
      posTag: '',
      posTagRegex: false,
      posTagNegation: false,
      exceptions: [],
      //attributes: [{attName:'myname', attValue: 'myval'}]  //for testing
      attributes: []
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
      tokenType: TokenTypes.WORD,
      inflected: false,
      regex: false,
      negation: false,
      posTag: '',
      posTagRegex: false,
      posTagNegation: false,
      attributes: [],
      guiAttributeDialogShown: false
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
      if (this.patternElements[i].tokenType !== TokenTypes.MARKER) {
        position++;
      }
      if (elem === this.patternElements[i]) {
        return position;
      }
    }
    return -1;
  };

  /** Get the element count, not counting markers. */
  $scope.elementCount = function() {
    var count = 0;
    for (var i = 0; i < this.patternElements.length; i++) {
      if (this.patternElements[i].tokenType !== TokenTypes.MARKER) {
        count++;
      }
    }
    return count;
  };

  $scope.addMarker = function() {
    this.patternElements.unshift({'tokenValue': __LT_MARKER_START, 'tokenType': TokenTypes.MARKER});
    this.patternElements.push({'tokenValue': __LT_MARKER_END, 'tokenType': TokenTypes.MARKER});
  };

  $scope.hasNoMarker = function() {
    for (var i = 0; i < this.patternElements.length; i++) {
      if (this.patternElements[i].tokenType === TokenTypes.MARKER) {
        return false;
      }
    }
    return true;
  };

  $scope.removeElement = function(element) {
    var index = this.patternElements.indexOf(element);
    if (this.patternElements[index].tokenType === TokenTypes.MARKER) {
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
      if (this.patternElements[i].tokenType === TokenTypes.MARKER) {
        this.patternElements.splice(i, 1);
      }
    }
  };
  
  $scope.evaluateErrorPattern = function() {
    this.gui.patternEvaluationInProgress = true;
    var data = "language=" + encodeURIComponent(this.language.code) + "&checkMarker=false&xml=" + encodeURIComponent(this.buildXml(false));
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
        //ctrl.gui.evaluationResult = data;
        var markerMatch = data.match(/<span class="internalMarkerInfo".*?>(.*?)<\/span>/);
        // TODO: all incorrect sentences need a marker:
        if (markerMatch) {
          ctrl.wrongSentenceWithMarker = markerMatch[1].trim();
        }
        $('#evaluationResult').html(data);
        ctrl.gui.patternEvaluated = true;
        ctrl.gui.patternEvaluationInProgress = false;
      })
      .error(function(data, status, headers, config) {
        // TODO: see above:
        ctrl.gui.patternEvaluated = true;
        $('#evaluationResult').html("Error " + status + ":<br>" + data);
        ctrl.gui.patternEvaluationInProgress = false;
      });
  };

  $scope.buildXml = function(withMarker) {
    return XmlBuilder.buildXml(this, withMarker);
  };

  $scope.buildEscapedXml = function(withMarker) {
    return XmlBuilder.buildEscapedXml(this, withMarker);
  };

  $scope.looksLikeRegex = function(str) {
    return str && (str.match(/[\[\]\|]/) || str.match(/\\[A-Za-z]/) || str.match(/\.[*+]/));
  };

  $scope.looksLikePosTagRegex = function(str) {
    return this.looksLikeRegex(str) && str.indexOf("=") === -1;
  };

  $scope.getPosTagUrl = function() {
    var langCode = this.language.code;
    return __ruleEditorPosInfoUrl + "?lang=" + langCode;
  };

  $scope.showRegexHelp = function() {
    var dialogElem = $("#regexHelp");
    var html = '<table>' +
      '<tr style="background-color: #eeeeee">' +
      '  <td>foo</td>' +
      '  <td>matches the word "foo"</td>' +
      '</tr>' +
      '<tr>' +
      '  <td>M[ae]yer</td>' +
      '  <td>matches the word "Mayer" or "Meyer"</td>' +
      '</tr>' +
      '<tr style="background-color: #eeeeee">' +
      '  <td>foo|bar|blah</td>' +
      '  <td>matches the word "foo", "bar", or "blah"</td>' +
      '</tr>' +
      '<tr>' +
      '  <td>walks?</td>' +
      '  <td>matches the word "walk" or "walks", i.e. the "s" is optional</td>' +
      '</tr>' +
      //'<tr style="background-color: #eeeeee">' +
      //'  <td>(?-i)foo</td>' +
      //'  <td>matches the word "foo", but not "FOO" or "Foo"</td>' +
      //'</tr>' +
      '</table>';

    dialogElem.html(html);
    dialogElem.dialog({
      modal: false,
      width: 600,
      buttons: {
        Ok: function() {
          $(this).dialog("close");
        }
      }
    });
  };

  $scope.countAttributes = function(attributes) {
    var count = 0;
    for (var key in attributes) {
      if (attributes.hasOwnProperty(key)) {
        var att = attributes[key];
        if (att.attName && att.attValue) {  // don't count empty attributes
          count++;
        }
      }
    }
    return count;
  };
  
  $scope.editAttributes = function(element) {
    if (element.attributes.length == 0) {
      this.addAttribute(element);
    }
    element.guiAttributeDialogShown = true;
  };

  $scope.addAttribute = function(element) {
    element.attributes.push({});
    this.focusAttributeInput = true;
  };

  $scope.removeAttribute = function(element, attr) {
    var index = element.attributes.indexOf(attr);
    if (index > -1) {
      element.attributes.splice(index, 1);
    } else {
      console.warn("Attribute not found: " + attr);
    }
  };

  $scope.editExceptionAttributes = function(exception) {
    if (exception.attributes.length == 0) {
      this.addExceptionAttribute(exception);
    }
    exception.guiAttributeDialogShown = true;
  };

  $scope.addExceptionAttribute = function(exception) {
    exception.attributes.push({});
    this.focusAttributeInput = true;
  };

  $scope.removeExceptionAttribute = function(exception, attr) {
    var index = exception.attributes.indexOf(attr);
    if (index > -1) {
      exception.attributes.splice(index, 1);
    } else {
      console.warn("Exception attribute not found: " + exception + "," + attr);
    }
  };

  if ($scope.existingXml) {
    // the server has injected a rule XML, so show it:
    $scope.parseExistingXml();
  }

});
