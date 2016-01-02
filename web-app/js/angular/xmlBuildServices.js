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
        xml += "<rule id=\"" + this.buildId(model.ruleName).attributeEscape() + "\" name=\"" + model.ruleName.attributeEscape() + "\">\n";
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
          if (sentence.type === model.SentenceTypes.WRONG) {
            if (withMarker && j === 0 && model.wrongSentenceWithMarker) {
              xml += " <example correction=''>" + model.wrongSentenceWithMarker + "</example>\n";
            } else {
              xml += " <example correction=''>" + sentence.text.htmlEscape() + "</example>\n";
            }
          } else {
            xml += " <example>" + sentence.text.htmlEscape() + "</example>\n";
          }
        }
        xml += "</rule>\n";
        return xml;
      },

      buildEscapedXml: function(model, withMarker) {
        return this.buildXml(model, withMarker).replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/ /g, "&nbsp;").replace(/\n/g, "<br/>");
      },

      buildId: function(ruleName) {
        return ruleName.replace(/[^a-zA-Z_ ]/g, "").replace(/ +/g, "_").toUpperCase();
      },

      buildXmlForMessage: function(ruleMessage, model) {
        var xml = "";
        var ruleMessageText = ruleMessage;
        for (var i = 0; i < model.messageMatches.length; i++) {
          var messageMatch = model.messageMatches[i];
          var caseAttribute = "";
          var regexMatchAttribute = "";
          var regexReplaceAttribute = "";
          if (messageMatch.caseConversion !== model.CaseConversion.PRESERVE) {
            caseAttribute = " case_conversion=\"" + messageMatch.caseConversion.replace(' ', '') + "\"";
          }
          if (messageMatch.regexMatch) {
            regexMatchAttribute = " regexp_match=\"" + messageMatch.regexMatch + "\"";
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
        var val = elem.tokenValue ? elem.tokenValue.htmlEscape() : '';
        var inflected = this.getInflectedAttribute(elem);
        var regex = this.getRegexAttribute(elem);
        var negation = this.getNegationAttribute(elem);
        var posTagRegex = this.getPosTagRegexAttribute(elem);
        var posTagNegation = this.getPosTagNegationAttribute(elem);
        if (elem.tokenType === model.TokenTypes.WORD) {
          xml += "  <token" + inflected + regex + negation;
          xml += this.buildXmlForAttributes(elem.attributes, model);
          xml += ">" + val;
          xml += this.buildXmlForExceptions(elem.exceptions, model);
          xml += "</token>\n";
        } else if (elem.tokenType === model.TokenTypes.POS_TAG) {
          xml += "  <token " + this.getPosTagsAttributes(elem.posTag) + posTagRegex + posTagNegation;
          xml += this.buildXmlForAttributes(elem.attributes, model);
          xml += ">";
          xml += this.buildXmlForExceptions(elem.exceptions, model);
          xml += "</token>\n";
        } else if (elem.tokenType === model.TokenTypes.WORD_AND_POS_TAG) {
          xml += "  <token" + inflected + regex + negation + " " + this.getPosTagsAttributes(elem.posTag) + posTagRegex + posTagNegation;
          xml += this.buildXmlForAttributes(elem.attributes, model);
          xml += ">" + val;
          xml += this.buildXmlForExceptions(elem.exceptions, model);
          xml += "</token>\n";
        } else if (elem.tokenType === model.TokenTypes.ANY) {
          xml += "  <token";
          xml += this.buildXmlForAttributes(elem.attributes, model);
          xml += ">";
          xml += this.buildXmlForExceptions(elem.exceptions, model);
          xml += "</token>\n";
        } else if (elem.tokenType === model.TokenTypes.MARKER && val === __LT_MARKER_START) {
          xml += "  <marker>\n";
        } else if (elem.tokenType === model.TokenTypes.MARKER && val === __LT_MARKER_END) {
          xml += "  </marker>\n";
        } else {
          console.warn("Unknown token type '" + elem.tokenType + "'");
        }
        return xml;
      },

      // input may be mix of structured an regex-based tag, e.g. "pos=noun number=singular NN[AB]"
      getPosTagsAttributes: function(posTagStr) {
        var posTags = "";
        var parts = posTagStr.split(/ /);
        for (var i = 0; i < parts.length; i++) {
          var part = parts[i];
          if (part.trim().length === 0) {
            continue;
          }
          if (part.indexOf("=") !== -1) {
            var tokenParts = part.split(/=/);
            if (tokenParts.length !== 2) {
              throw "Expected POS tag part to have two parts delimited by '=': " + tokenParts;
            }
            posTags += " " + tokenParts[0] + "='" + tokenParts[1].htmlEscape().replace(/\|/g, " ") + "'";
          } else {
            posTags += " postag='" + part.htmlEscape() + "'";
          }
        }
        return posTags.trim();
      },

      getInflectedAttribute: function(elem) {
        return elem.inflected ? " inflected='yes'" : "";
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
        var val = exception.tokenValue ? exception.tokenValue.htmlEscape() : '';
        var inflected = this.getInflectedAttribute(exception);
        var regex = this.getRegexAttribute(exception);
        var negation = this.getNegationAttribute(exception);
        var posTagRegex = this.getPosTagRegexAttribute(exception);
        var posTagNegation = this.getPosTagNegationAttribute(exception);
        if (exception.tokenType === model.TokenTypes.WORD) {
          xml += "<exception" + inflected + regex + negation;
          xml += this.buildXmlForAttributes(exception.attributes, model);
          xml += ">" + val;
          xml += "</exception>";
        } else if (exception.tokenType === model.TokenTypes.POS_TAG) {
          xml += "<exception " + this.getPosTagsAttributes(exception.posTag) + posTagRegex + posTagNegation;
          xml += this.buildXmlForAttributes(exception.attributes, model);
          xml += ">";
          xml += "</exception>";
        } else if (exception.tokenType === model.TokenTypes.WORD_AND_POS_TAG) {
          xml += "<exception" + inflected + regex + negation + " " + this.getPosTagsAttributes(exception.posTag) + posTagRegex + posTagNegation;
          xml += this.buildXmlForAttributes(exception.attributes, model);
          xml += ">" + val;
          xml += "</exception>";
        } else {
          console.warn("Unknown exception  type '" + exception.tokenType + "'");
        }
        return xml;
      },

      buildXmlForAttributes: function(attributes, model) {
        var xml = "";
        for (var i = 0; i < attributes.length; i++) {
          var att = attributes[i];
          if (att.attName && att.attValue) {
            xml += " " + att.attName + "='" + att.attValue.attributeEscape() + "'";
          }
        }
        return xml;
      }

  };
});
