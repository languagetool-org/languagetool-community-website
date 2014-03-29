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

/* XML Services */

var xmlServices = angular.module('ruleEditor.xmlServices', []);

//TODO: avoid duplication
var __LT_MARKER_START = 'Marker start';
var __LT_MARKER_END = 'Marker end';

xmlServices.factory('XmlBuilder',
  function($http, $q, $filter) {
    return {
      
      buildXml: function(model, withMarker) {
        var date = new Date();
        var dateStr = $filter('date')(date, "yyyy-MM-dd");
        var xml = "<!-- " + model.language.name.htmlEscape() + " rule, " + dateStr + " -->\n";
        xml += "<rule id=\"ID\" name=\"" + model.ruleName.attributeEscape() + "\">\n";
        if (model.caseSensitive) {
          xml += " <pattern case_sensitive='yes'>\n";
        } else {
          xml += " <pattern>\n";
        }
        for (var i = 0; i < model.patternElements.length; i++) {
          xml += this.buildXmlForElement(model.patternElements[i], model);
        }
        xml += " </pattern>\n";
        xml += this.buildXmlForMessage(model.ruleMessage, model);
        if (model.detailUrl) {
          xml += " <url>" + model.detailUrl.htmlEscape() + "</url>\n";
        }
        if (model.shortRuleMessage) {
          xml += " <short>" + model.shortRuleMessage.htmlEscape() + "</short>\n";
        }
        for (var j = 0; j < model.exampleSentences.length; j++) {
          var sentence = model.exampleSentences[j];
          if (sentence.type == model.SentenceTypes.WRONG) {
            if (withMarker && j == 0 && model.wrongSentenceWithMarker) {
              xml += " <example type='incorrect'>" + model.wrongSentenceWithMarker + "</example>\n";
            } else {
              xml += " <example type='incorrect'>" + sentence.text.htmlEscape() + "</example>\n";
            }
          } else {
            xml += " <example type='correct'>" + sentence.text.htmlEscape() + "</example>\n";
          }
        }
        xml += "</rule>\n";
        return xml;
      },

      buildXmlForMessage: function(ruleMessage, model) {
        var xml = "";
        var ruleMessageText = ruleMessage;
        for (var i = 0; i < model.messageMatches.length; i++) {
          var messageMatch = model.messageMatches[i];
          var caseAttribute = "";
          var regexMatchAttribute = "";
          var regexReplaceAttribute = "";
          if (messageMatch.caseConversion != model.CaseConversion.PRESERVE) {
            caseAttribute = " case_conversion=\"" + messageMatch.caseConversion.replace(' ', '') + "\"";
          }
          if (messageMatch.regexMatch) {
            regexMatchAttribute = " regexp_match=\"" + messageMatch.regexMatch + "\"";
          }
          if (messageMatch.regexReplace) {
            regexReplaceAttribute = " regexp_replace=\"" + messageMatch.regexReplace + "\"";
          }
          var replacement = "<match no=\"" + messageMatch.tokenNumber + "\"" + caseAttribute + regexMatchAttribute + regexReplaceAttribute + "/>";
          ruleMessageText = ruleMessageText.replace("\\" + messageMatch.tokenNumber, replacement);
        }
        ruleMessageText = ruleMessageText.replace(/'(.*?)'/g, "<suggestion>$1</suggestion>");
        xml += " <message>" + ruleMessageText + "</message>\n";
        return xml;
      },
      
      buildXmlForElement: function(elem, model) {
        var xml = "";
        var val = elem.tokenValue;
        if (!val) {
          val = "";
        }
        var baseform = this.getBaseformAttribute(elem);
        var regex = this.getRegexAttribute(elem);
        var negation = this.getNegationAttribute(elem);
        var posTagRegex = this.getPosTagRegexAttribute(elem);
        var posTagNegation = this.getPosTagNegationAttribute(elem);
        if (elem.tokenType == model.TokenTypes.WORD) {
          xml += "  <token" + baseform + regex + negation + ">" + val;
          xml += this.buildXmlForExceptions(elem.exceptions, model);
          xml += "</token>\n";
        } else if (elem.tokenType == model.TokenTypes.POS_TAG) {
          xml += "  <token postag='" + elem.posTag.htmlEscape() + "'" + posTagRegex + posTagNegation + ">";
          xml += this.buildXmlForExceptions(elem.exceptions, model);
          xml += "</token>\n";
        } else if (elem.tokenType == model.TokenTypes.WORD_AND_POS_TAG) {
          xml += "  <token" + baseform + regex + negation + " postag='" + elem.posTag.htmlEscape() + "'" + posTagRegex + posTagNegation + ">" + val;
          xml += this.buildXmlForExceptions(elem.exceptions, model);
          xml += "</token>\n";
        } else if (elem.tokenType == model.TokenTypes.ANY) {
          xml += "  <token>";
          xml += this.buildXmlForExceptions(elem.exceptions, model);
          xml += "</token>\n";
        } else if (elem.tokenType == model.TokenTypes.MARKER && val == __LT_MARKER_START) {
          xml += "  <marker>\n";
        } else if (elem.tokenType == model.TokenTypes.MARKER && val == __LT_MARKER_END) {
          xml += "  </marker>\n";
        } else {
          console.warn("Unknown token type '" + elem.tokenType + "'");
        }
        return xml;
      },

      getBaseformAttribute: function(elem) {
        return elem.baseform ? " inflected='yes'" : "";
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
      
      buildXmlForExceptions: function(exceptions, model) {
        var xml = "";
        for (var i = 0; i < exceptions.length; i++) {
          var exception = exceptions[i];
          xml += this.buildXmlForException(exception, model);
        }
        return xml;
      },

      buildXmlForException: function(exception, model) {
        var xml = "";
        var val = exception.tokenValue;
        if (!val) {
          val = "";
        }
        var baseform = this.getBaseformAttribute(exception);
        var regex = this.getRegexAttribute(exception);
        var negation = this.getNegationAttribute(exception);
        var posTagRegex = this.getPosTagRegexAttribute(exception);
        var posTagNegation = this.getPosTagNegationAttribute(exception);
        if (exception.tokenType == model.TokenTypes.WORD) {
          xml += "<exception" + baseform + regex + negation + ">" + val;
          xml += "</exception>";
        } else if (exception.tokenType == model.TokenTypes.POS_TAG) {
          xml += "<exception postag='" + exception.posTag.htmlEscape() + "'" + posTagRegex + posTagNegation + ">";
          xml += "</exception>";
        } else if (exception.tokenType == model.TokenTypes.WORD_AND_POS_TAG) {
          xml += "<exception" + baseform + regex + negation + " postag='" + exception.posTag.htmlEscape() + "'" + posTagRegex + posTagNegation + ">" + val;
          xml += "</exception>";
        } else {
          console.warn("Unknown exception  type '" + exception.tokenType + "'");
        }
        return xml;
      }

  };
});
