'use strict';

/* Services */

var ruleEditorServices = angular.module('ruleEditor.services', []);

ruleEditorServices.factory('SentenceComparator', 
  function($http, $q) {
    return {
      
      incorrectTokens: function(url, langCode, sentence1, sentence2) {
        var list = [];
        list.push("one");
        list.push("two");
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
            deferred.resolve(tokens);
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
          xml += model.buildXmlForElement(model.patternElements[i]);
        }
        xml += " </pattern>\n";
        xml += " <message>" + model.ruleMessage.htmlEscape() + "</message>\n";
        xml += " <example type='incorrect'>" + model.wrongSentence.htmlEscape() +  "</example>\n";
        xml += " <example type='correct'>" + model.correctedSentence.htmlEscape() + "</example>\n";
        xml += "</rule>\n";
        return xml;
      }

    };
});
