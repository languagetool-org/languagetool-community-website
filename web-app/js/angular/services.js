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

ruleEditorServices.factory('SentenceComparator', 
  function($http, $q) {
    return {
      
      // Find the difference between two example sentences, so these different
      // tokens can be used as a basis for the error pattern:
      incorrectTokens: function(url, langCode, sentence1, sentence2) {
        var deferred = $q.defer();
        var data = "lang=" + encodeURIComponent(langCode)
          + "&sentence1=" + encodeURIComponent(sentence1) + "&sentence2=" + encodeURIComponent(sentence2);
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
          if (wrongSentenceTokens[i] !== correctedSentenceTokens[i]) {
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
          if (wrongSentenceTokens[wrongSentencePos] !== correctedSentenceTokens[correctedSentencePos]) {
            return i;
          }
          wrongSentencePos--;
          correctedSentencePos--;
        }
        return -1;
      }

  };
});
