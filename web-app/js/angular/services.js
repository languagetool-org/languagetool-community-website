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
            var diffStart = self.findFirstDifferentPosition(data.sentence1, data.sentence2);
            var diffEnd = self.findLastDifferentPosition(data.sentence1, data.sentence2);
            var tokens = [];
            for (var i = diffStart; i <= diffEnd; i++) {
              tokens.push(data.sentence1[i]);
            }
            deferred.resolve({'tokens': tokens, 'matchesHtml': data.sentence1Matches});
          })
          .error(function(data, status, headers, config) {
            deferred.reject("Response status " + status);
          });
        return deferred.promise;
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
        if (elem.tokenType == 'word') {
          var negation = elem.negation ? " negate='yes'" : "";
          if (elem.regex == true) {
            xml += "  <token regexp='yes'" + negation + ">" + val;
          } else {
            xml += "  <token" + negation + ">" + val;
          }
          this.buildXmlForConditions(elem.conditions);
          xml += "</token>\n";
        } else if (elem.tokenType == 'posTag') {
          var posNegation = elem.negation ? " negate_pos='yes'" : "";
          if (elem.regex == true) {
            xml += "  <token postag='" + val.htmlEscape() + "' postag_regexp='yes'" + posNegation + ">";
          } else {
            xml += "  <token postag='" + val.htmlEscape() + "'" + posNegation + ">";
          }
          this.buildXmlForConditions(elem.conditions);
          xml += "</token>\n";
        } else if (elem.tokenType == 'regex') {
          xml += "  <token regexp='yes'>" + val;
          this.buildXmlForConditions(elem.conditions);
          xml += "</token>\n";
        } else if (elem.tokenType == 'any') {
          xml += "  <token>";
          this.buildXmlForConditions(elem.conditions);
          xml += "  </token>\n";
        } else if (elem.tokenType == 'marker' && val == __LT_MARKER_START) {
          xml += "  <marker>\n";
        } else if (elem.tokenType == 'marker' && val == __LT_MARKER_END) {
          xml += "  </marker>\n";
        } else {
          console.warn("Unknown token type '" + elem.tokenType + "'");
        }
        return xml;
      },

      buildXmlForConditions: function(conditions) {
        var xml;
        for (var i = 0; i < conditions.length; i++) {
          var condition = conditions[i];
          xml += this.buildXmlForCondition(condition);
        }
        return xml;
      },

      buildXmlForCondition: function(condition) {
        var xml;
        if (condition.negation) {
          if (condition.tokenType == 'word') {
            xml += "<exception>" + condition.tokenValue.htmlEscape() + "</exception>";
          } else if (condition.tokenType == 'posTag') {
            xml += "<exception postag=''/>" + condition.tokenValue.htmlEscape() + "</exception>";
          }
        } else {
          //TODO
        }
        return xml;
      }

  };
});
