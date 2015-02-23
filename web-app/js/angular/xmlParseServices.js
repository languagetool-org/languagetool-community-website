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

      // try to be fail-safe and stop on any XML element not listed here:
      supportedNodes: ['rule', 'pattern', 'message', 'marker', 'example', 'match', 'suggestion',
                       'exception', 'token', 'url', 'short'],

      parseXml: function(xml) {
        xml = xml.replace(/<!--.*?-->/g, "");
        var parser = new DOMParser();
        var doc = parser.parseFromString(xml, "text/xml");
        this.validateSupportForDoc(doc, xml);

        var self = this;

        var result = {};
        this.evalXPath(doc, result, "/rule", doc, function(thisNode, attr) {
          result.ruleId = attr.getNamedItem('id') ? attr.getNamedItem('id').nodeValue : '';
        });
        this.evalXPath(doc, result, "/rule", doc, function(thisNode, attr) {
          result.ruleName = attr.getNamedItem('name') ? attr.getNamedItem('name').nodeValue : '';
        });

        this.evalXPath(doc, result, "//pattern", doc, function(thisNode, attr) {
          result.caseSensitive = self.attr(attr, 'case_sensitive') === 'yes';
        });

        result.patternElements = [];
        result.exampleSentences = [];
        
        var hasMarker = false;
        var hasEndMarker = false;
        this.evalXPath(doc, result, "//pattern//*", doc, function(thisNode, attr) {
          var word = thisNode.childNodes[0] ? thisNode.childNodes[0].nodeValue : '';
          var pos = attr.getNamedItem('postag') ? attr.getNamedItem('postag').nodeValue : '';
          var tokenType = self.getTokenType(thisNode, word, pos);
          var element;
          if (tokenType === 'exception') {
            // these are handled by getExceptions()
            return;
          } else if (tokenType === 'marker') {
            element = {
              tokenValue: __LT_MARKER_START,
              tokenType: 'marker'
            };
            hasMarker = true;
          } else {
            element = self.getElement(attr, word, tokenType, pos);
            element.exceptions = self.getExceptions(thisNode.childNodes);
          }
          if (thisNode.nodeName === 'token' && thisNode.parentNode.nodeName === 'pattern' && hasMarker && !hasEndMarker) {
            result.patternElements.push({
              tokenValue: __LT_MARKER_END,
              tokenType: 'marker'
            });
            hasEndMarker = true;
          }
          result.patternElements.push(element);
        });
        if (hasMarker && !hasEndMarker) {
          result.patternElements.push({
            tokenValue: __LT_MARKER_END,
            tokenType: 'marker'
          });
        }
        
        this.evalXPath(doc, result, "//example", doc, function(thisNode) {
          var attributes = thisNode.attributes;
          var attValue = attributes.getNamedItem('type');
          if (attValue) {
            attValue = attValue.nodeValue;
          }
          var type;
          if (attValue === 'incorrect') {
            type = 'wrong';
          } else if (attValue === 'correct') {
            type = 'corrected';
          } else if (attributes.getNamedItem('correction')) {
            type = 'wrong';
          } else {
            type = 'corrected';  // no correction implies the sentence is correct
          }
          var sentence = "";
          for (var i = 0; i < thisNode.childNodes.length; i++) {
            var nodeName = thisNode.childNodes[i].nodeName;
            if (nodeName == 'marker') {
              // Note: we currently lose the markers, as the user isn't supposed
              // to add them in interactive mode either:
              sentence += thisNode.childNodes[i].childNodes[0].nodeValue;
            } else if (nodeName == '#text') {
              sentence += thisNode.childNodes[i].nodeValue;
            } else {
              throw "Unsupported node '" + nodeName + "' in example"
            }
          }
          result.exampleSentences.push({text: sentence, type: type});
        });

        this.evalXPath(doc, result, "//message", doc, function(thisNode, attr) {
          result.ruleMessage = "";
          result.messageMatches = [];
          self.handleMessageNodes(thisNode.childNodes, result);
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

      validateSupportForDoc: function (doc, xml) {
        var xpathResult = doc.evaluate("//*", doc, null, XPathResult.ANY_TYPE, null);
        var node = xpathResult.iterateNext();
        var foundRuleElement = false;
        var xmlError = "";
        while (node) {
          if (node.nodeName === 'parsererror') {
            xmlError += "Error:\n" + node.childNodes[0].nodeValue;
          } else if (node.nodeName === 'sourcetext') {
            xmlError += "\nXML:\n" + node.childNodes[0].nodeValue;
          } else if (this.supportedNodes.indexOf(node.nodeName) === -1) {
            throw "Sorry, nodes of type '" + node.nodeName + "' are not yet supported by this parser";
          }
          if (node.nodeName === 'rule') {
            foundRuleElement = true;
          }
          node = xpathResult.iterateNext();
        }
        if (xmlError) {
          throw xmlError;
        } else if (!foundRuleElement) {
          throw "Cannot parse document, no 'rule' element found: " + xml;
        }
      },

      handleMessageNodes: function (nodes, result) {
        for (var i = 0; i < nodes.length; i++) {
          var nodeName = nodes[i].nodeName;
          if (nodeName === '#text') {
            var text = nodes[i].nodeValue;
            result.ruleMessage += text;
            var regex = /\\(\d+)/g;
            var matches;
            while (matches = regex.exec(text)) {
              result.messageMatches.push({
                tokenNumber: matches[1], caseConversion: 'preserve', regexMatch: '', regexReplace: ''
              });
            }
          } else if (nodeName === 'suggestion') {
            result.ruleMessage += "'";
            this.handleMessageNodes(nodes[i].childNodes, result);
            result.ruleMessage += "'";
          } else if (nodeName === 'match') {
            var childAttr = nodes[i].attributes;
            var number = this.attr(childAttr, 'no');
            result.ruleMessage += "\\" + number;
            var caseConversionAttr = this.attr(childAttr, 'case_conversion');
            var caseConversion;
            switch (caseConversionAttr) {
              //TODO: use constants
              case 'startlower': caseConversion = 'start lower'; break;
              case 'startupper': caseConversion = 'start upper'; break;
              case 'alllower': caseConversion = 'all lower'; break;
              case 'allupper': caseConversion = 'all upper'; break;
              case 'preserve': caseConversion = 'preserve'; break;
              case null: caseConversion = 'preserve'; break;
              default: throw "Unknown value for case_conversion: '" + caseConversionAttr + "'"
            }
            result.messageMatches.push({
              tokenNumber: number,
              caseConversion: caseConversion,
              regexMatch: this.attr(childAttr, 'regexp_match'),
              regexReplace: this.attr(childAttr, 'regexp_replace')
              // TODO: more attributes are possible here
            });
          } else {
            throw "Unknown node name '" + nodeName + "' in message";
          }
        }
      },

      getTokenType: function (node, word, pos) {
        var tokenType;
        if (node.nodeName === 'marker') {
          tokenType = 'marker';
        } else if (node.nodeName === 'exception') {
          tokenType = 'exception';
        } else if (word && pos) {
          tokenType = 'word_and_posTag';
        } else if (word) {
          tokenType = 'word';
        } else if (pos) {
          tokenType = 'posTag';
        } else {
          tokenType = 'any';
        }
        return tokenType;
      },
      
      getExceptions: function (nodes) {
        var exceptions = [];
        for (var i = 0; i < nodes.length; i++) {
          var node = nodes[i];
          var nodeName = node.nodeName;
          if (nodeName === 'exception') {
            var word = node.childNodes[0] ? node.childNodes[0].nodeValue : '';
            var attr = node.attributes;
            var pos = attr.getNamedItem('postag') ? attr.getNamedItem('postag').nodeValue : '';
            var tokenType;
            if (word && pos) {
              tokenType = 'word_and_posTag';
            } else if (word) {
              tokenType = 'word';
            } else if (pos) {
              tokenType = 'posTag';
            } else {
              throw "Unknown tokenType in exception '" + nodeName + "' - neither POS nor word?";
            }
            var ex = this.getElement(attr, word, tokenType, pos);
            exceptions.push(ex);
          }
        }
        return exceptions;
      },
      
      getElement: function (attr, word, tokenType, pos) {
        return {
          tokenValue: word,
          tokenType: tokenType,
          inflected: this.attr(attr, 'inflected') === 'yes',
          regex: this.attr(attr, 'regexp') === 'yes',
          negation: this.attr(attr, 'negate') === 'yes',
          posTag: pos,
          posTagRegex: this.attr(attr, 'postag_regexp') === 'yes',
          posTagNegation: this.attr(attr, 'postag_negate') === 'yes',
          attributes: this.collectRemainingAttributes(attr, ['inflected', 'postag', 'regexp', 'negate', 'postag_regexp', 'postag_negate'])
        };
      },
      
      collectRemainingAttributes: function (attr, knownAttributes) {
        var result = [];
        for (var i = 0; i < attr.length; i++) {
          if (knownAttributes.indexOf(attr[i].name) === -1) {
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
