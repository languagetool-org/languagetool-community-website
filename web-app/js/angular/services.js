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

/* Services */

var ruleEditorServices = angular.module('ruleEditor.services', []);

//TODO: avoid duplication
var __LT_MARKER_START = 'Marker start';
var __LT_MARKER_END = 'Marker end';

ruleEditorServices.factory('SentenceComparator', 
  function($http, $q) {
    return {
      
      // Find the difference between two example sentences, so these different
      // tokens can be used as a basis for the error pattern:
      incorrectTokens: function(url, langCode, sentence1, sentence2) {
        var deferred = $q.defer();
        var data = "lang=" + langCode + "&sentence1=" + sentence1 + "&sentence2=" + sentence2;  //TODO: encode?
        var self = this;
        $http({
          url: url,
          method: 'POST',
          data: data,
          // See http://stackoverflow.com/questions/19254029/angularjs-http-post-does-not-send-data:
          headers: {'Content-Type': 'application/x-www-form-urlencoded'}
        }).success(function(data) {
            var errorTokens = self.getErrorTokens(data.sentence1, data.sentence2);
            deferred.resolve({'tokens': errorTokens, 'matchesHtml': data.sentence1Matches});
          })
          .error(function(data, status, headers, config) {
            deferred.reject("Response status " + status);
          });
        return deferred.promise;
      },

      getErrorTokens: function(tokens1, tokens2) {
        var diffStart = this.findFirstDifferentPosition(tokens1, tokens2);
        var diffEnd = this.findLastDifferentPosition(tokens1, tokens2);
        var errorTokens = [];
        for (var i = diffStart; i <= diffEnd; i++) {
          errorTokens.push(tokens1[i]);
        }
        return errorTokens;
      },

      findFirstDifferentPosition: function(wrongSentenceTokens, correctedSentenceTokens) {
        for (var i = 0; i < Math.min(wrongSentenceTokens.length, correctedSentenceTokens.length); i++) {
          if (wrongSentenceTokens[i] != correctedSentenceTokens[i]) {
            return i;
          }
        }
        return -1;
      },

      findLastDifferentPosition: function(wrongSentenceTokens, correctedSentenceTokens) {
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

  };
});

ruleEditorServices.factory('XmlBuilder',
  function($http, $q) {
    return {
      
      buildXml: function(model) {
        var xml = "";
        xml += "<rule name=\"" + model.ruleName.attributeEscape() + "\">\n";
        xml += " <pattern>\n";
        for (var i = 0; i < model.patternElements.length; i++) {
          xml += this.buildXmlForElement(model.patternElements[i]);
        }
        xml += " </pattern>\n";
        xml += " <message>" + model.ruleMessage.htmlEscape() + "</message>\n";
        xml += " <example type='incorrect'>" + model.wrongSentence.htmlEscape() +  "</example>\n";
        xml += " <example type='correct'>" + model.correctedSentence.htmlEscape() + "</example>\n";
        xml += "</rule>\n";
        return xml;
      },

      buildXmlForElement: function(elem) {
        var xml = "";
        var val = elem.tokenValue;
        if (!val) {
          val = "";
        }
        var regex = this.getRegexAttribute(elem);
        var negation = this.getNegationAttribute(elem);
        var posTagRegex = this.getPosTagRegexAttribute(elem);
        var posTagNegation = this.getPosTagNegationAttribute(elem);
        if (elem.tokenType == 'word') {
          xml += "  <token" + regex + negation + ">" + val;
          xml += this.buildXmlForExceptions(elem.exceptions);
          xml += "</token>\n";
        } else if (elem.tokenType == 'posTag') {
          xml += "  <token postag='" + elem.posTag.htmlEscape() + "'" + posTagRegex + posTagNegation + ">";
          xml += this.buildXmlForExceptions(elem.exceptions);
          xml += "</token>\n";
        } else if (elem.tokenType == 'word_and_posTag') {
          xml += "  <token" + regex + negation + " postag='" + elem.posTag.htmlEscape() + "'" + posTagRegex + posTagNegation + ">" + val;
          xml += this.buildXmlForExceptions(elem.exceptions);
          xml += "</token>\n";
        } else if (elem.tokenType == 'any') {
          xml += "  <token>";
          xml += this.buildXmlForExceptions(elem.exceptions);
          xml += "</token>\n";
        } else if (elem.tokenType == 'marker' && val == __LT_MARKER_START) {
          xml += "  <marker>\n";
        } else if (elem.tokenType == 'marker' && val == __LT_MARKER_END) {
          xml += "  </marker>\n";
        } else {
          console.warn("Unknown token type '" + elem.tokenType + "'");
        }
        return xml;
      },

      getRegexAttribute: function(elem) {
        return elem.regex ? " regexp='yes'" : "";
      },
      getNegationAttribute: function(elem) {
        return elem.negation ? " negate='yes'" : "";
      },
      getPosTagRegexAttribute: function(elem) {
        return elem.posTagRegex ? " postag_regexp='yes'" : "";
      },
      getPosTagNegationAttribute: function(elem) {
        return elem.posTagNegation ? " negate_pos='yes'" : "";
      },
      
      buildXmlForExceptions: function(exceptions) {
        var xml = "";
        for (var i = 0; i < exceptions.length; i++) {
          var exception = exceptions[i];
          xml += this.buildXmlForException(exception);
        }
        return xml;
      },

      buildXmlForException: function(exception) {
        var xml = "";
        var val = exception.tokenValue;
        if (!val) {
          val = "";
        }
        var regex = this.getRegexAttribute(exception);
        var negation = this.getNegationAttribute(exception);
        var posTagRegex = this.getPosTagRegexAttribute(exception);
        var posTagNegation = this.getPosTagNegationAttribute(exception);
        if (exception.tokenType == 'word') {
          xml += "<exception" + regex + negation + ">" + val;
          xml += "</exception>";
        } else if (exception.tokenType == 'posTag') {
          xml += "<exception postag='" + exception.posTag.htmlEscape() + "'" + posTagRegex + posTagNegation + ">";
          xml += "</exception>";
        } else if (exception.tokenType == 'word_and_posTag') {
          xml += "<exception" + regex + negation + " postag='" + exception.posTag.htmlEscape() + "'" + posTagRegex + posTagNegation + ">" + val;
          xml += "</exception>";
        } else {
          console.warn("Unknown exception  type '" + exception.tokenType + "'");
        }
        return xml;
      }

  };
});
