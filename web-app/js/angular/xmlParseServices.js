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

/* XML Parse Services */

var xmlServices = angular.module('ruleEditor.xmlParseServices', []);

//TODO: avoid duplication
var __LT_MARKER_START = 'Marker start';
var __LT_MARKER_END = 'Marker end';

xmlServices.factory('XmlParser',
  function() {
    return {
      
      parseXml: function(xml) {
        var parser = new DOMParser();
        var doc = parser.parseFromString(xml, "text/xml");

        if (doc.childNodes[0].nodeName !== 'rule') {
          throw "Cannot parse document, it needs to start with a 'rule' element";
        }

        var self = this;

        var result = {};
        this.evalXPath(doc, result, "/rule", doc, function(thisNode, attr) {
          result.ruleId = attr.getNamedItem('id') ? attr.getNamedItem('id').nodeValue : null;
        });
        this.evalXPath(doc, result, "/rule", doc, function(thisNode, attr) {
          result.ruleName = attr.getNamedItem('name') ? attr.getNamedItem('name').nodeValue : null;
        });

        result.patternElements = [];
        result.exampleSentences = [];
        
        this.evalXPath(doc, result, "//pattern", doc, function(thisNode, attr) {
          result.caseSensitive = self.attr(attr, 'case_sensitive') == 'yes';
        });

        //var foo = doc.evaluate("//pattern//token | //pattern/marker", doc, null, XPathResult.ANY_TYPE);

        var hasMarker = false;
        var hasEndMarker = false;
        this.evalXPath(doc, result, "//pattern//*", doc, function(thisNode, attr) {
          var element;
          var tokenType;
          var word = thisNode.childNodes[0].nodeValue;
          var pos = attr.getNamedItem('postag') ? attr.getNamedItem('postag').nodeValue : '';
          if (word && pos) {
            tokenType = 'word_and_posTag';
          } else if (word) {
            tokenType = 'word';
          } else if (pos) {
            tokenType = 'posTag';
          } else if (thisNode.nodeName == 'marker') {
            element = {
              tokenValue: __LT_MARKER_START,
              tokenType: 'marker'
            };
            hasMarker = true;
          } else {
            throw "Unknown tokenType '" + thisNode.nodeName + "' - neither POS nor word?";
          }
          
          if (!element) {
            element = {
              tokenValue: word,
              tokenType: tokenType,
              inflected: self.attr(attr, 'inflected') == 'yes',
              regex: self.attr(attr, 'regexp') == 'yes',
              negation: self.attr(attr, 'negate') == 'yes',
              posTag: pos,
              posTagRegex: self.attr(attr, 'postag_regexp') == 'yes',
              posTagNegation: self.attr(attr, 'postag_negate') == 'yes',
              exceptions: [],  // TODO: implement
              attributes: self.collectRemainingAttributes(attr, ['inflected', 'postag', 'regexp', 'negate', 'postag_regexp', 'postag_negate'])
            };
          }
          
          //console.log("++++++++"+thisNode.nodeName + " " + thisNode.parentNode.nodeName);
          if (thisNode.nodeName == 'token' && thisNode.parentNode.nodeName == 'pattern' && hasMarker && !hasEndMarker) {
            result.patternElements.push({
              tokenValue: __LT_MARKER_END,
              tokenType: 'marker'
            });
            hasEndMarker = true;
          }
          //console.log(element);
          result.patternElements.push(element);
        });
        if (hasMarker && !hasEndMarker) {
          result.patternElements.push({
            tokenValue: __LT_MARKER_END,
            tokenType: 'marker'
          });
        }
        
        this.evalXPath(doc, result, "//example", doc, function(thisNode) {
          var attValue = thisNode.attributes.getNamedItem('type').nodeValue;
          var type;
          if (attValue === 'incorrect') {
            type = 'wrong';
          } else if (attValue === 'correct') {
            type = 'corrected';
          } else {
            throw "Unknown attribute value '" + attValue + "'";
          }
          result.exampleSentences.push({text: thisNode.childNodes[0].nodeValue, type: type});
        });

        this.evalXPath(doc, result, "//message", doc, function(thisNode) {
          result.ruleMessage = thisNode.childNodes[0].nodeValue;
        });

        this.evalXPath(doc, result, "//short", doc, function(thisNode) {
          result.shortRuleMessage = thisNode.childNodes[0].nodeValue;
        });

        this.evalXPath(doc, result, "//url", doc, function(thisNode) {
          result.detailUrl = thisNode.childNodes[0].nodeValue;
        });
        
        // TODO: handle unknown elements

        return result;
      },

      collectRemainingAttributes: function (attr, knownAttributes) {
        var result = [];
        for (var i = 0; i < attr.length; i++) {
          if (knownAttributes.indexOf(attr[i].name) == -1) {
            result.push({attName: attr[i].name, attValue: attr[i].value});
          }
        }
        return result;
      },

      attr: function(attr, attName) {
        if (attr && attr.getNamedItem(attName)) {
          return attr.getNamedItem(attName).nodeValue;
        }
        return null;
      },
      
      evalXPath: function(doc, result, xpath, node, perNode) {
        var xpathResult = doc.evaluate(xpath, node, null, XPathResult.ANY_TYPE, null);
        var thisNode = xpathResult.iterateNext();
        while (thisNode) {
          perNode(thisNode, thisNode.attributes);
          thisNode = xpathResult.iterateNext();
        }
      }

  };
});
