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

describe('RuleEditor services', function() {
  
  beforeEach(module('ruleEditor.xmlParseServices'));

  describe('RuleEditorCtrl', function() {

    it('should detects invalid docs', inject(function(XmlParser) {
      var thrower = function() { XmlParser.parseXml("<foo></foo>") };
      expect(thrower).toThrow();
    }));

    it('should parse simple rule', inject(function(XmlParser) {
      expect(XmlParser.parseXml(
        "<rule id='myid' name='foo'>" +
        "<pattern><token>A</token></pattern>" +
        "<message>my message</message>" +
        "<example type='correct'>correct example</example>" +
        "<example type='incorrect'>incorrect example</example>" +
        "</rule>")).toEqual(
          {
            ruleId: 'myid',
            ruleName: 'foo',
            caseSensitive: false,
            patternElements: [
              {
                tokenValue: 'A',
                tokenType: 'word',
                inflected: false,
                regex: false,
                negation: false,
                posTag: '',
                posTagRegex: false,
                posTagNegation: false,
                exceptions: [],
                attributes: []
              }],
            exampleSentences:
              [
                {text: 'correct example', type: 'corrected'},
                {text: 'incorrect example', type: 'wrong'}
              ],
            ruleMessage: "my message"
          });
    }));
    
    it('should parse simple rule with marker around A', inject(function(XmlParser) {
      expect(XmlParser.parseXml(
        "<rule>" +
        "<pattern><marker><token>A</token></marker><token>B</token></pattern>" +
        "<message>my message</message>" +
        "<example type='correct'>correct example</example>" +
        "<example type='incorrect'>incorrect example</example>" +
        "</rule>")).toEqual(
          {
            ruleId: null,
            ruleName: null,
            caseSensitive: false,
            patternElements: [
              { tokenValue: 'Marker start', tokenType: 'marker' },
              {
                tokenValue: 'A',
                tokenType: 'word',
                inflected: false,
                regex: false,
                negation: false,
                posTag: '',
                posTagRegex: false,
                posTagNegation: false,
                exceptions: [],
                attributes: []
              },
              { tokenValue: 'Marker end', tokenType: 'marker' },
              {
                tokenValue: 'B',
                tokenType: 'word',
                inflected: false,
                regex: false,
                negation: false,
                posTag: '',
                posTagRegex: false,
                posTagNegation: false,
                exceptions: [],
                attributes: []
              }
            ],
            exampleSentences:
              [
                {text: 'correct example', type: 'corrected'},
                {text: 'incorrect example', type: 'wrong'}
              ],
            ruleMessage: "my message"
          });
    }));
    
    it('should parse simple rule with marker around B', inject(function(XmlParser) {
      expect(XmlParser.parseXml(
        "<rule>" +
        "<pattern><token>A</token><marker><token>B</token></marker></pattern>" +
        "<message>my message</message>" +
        "<example type='correct'>correct example</example>" +
        "<example type='incorrect'>incorrect example</example>" +
        "</rule>")).toEqual(
          {
            ruleId: null,
            ruleName: null,
            caseSensitive: false,
            patternElements: [
              {
                tokenValue: 'A',
                tokenType: 'word',
                inflected: false,
                regex: false,
                negation: false,
                posTag: '',
                posTagRegex: false,
                posTagNegation: false,
                exceptions: [],
                attributes: []
              },
              { tokenValue: 'Marker start', tokenType: 'marker' },
              {
                tokenValue: 'B',
                tokenType: 'word',
                inflected: false,
                regex: false,
                negation: false,
                posTag: '',
                posTagRegex: false,
                posTagNegation: false,
                exceptions: [],
                attributes: []
              },
              { tokenValue: 'Marker end', tokenType: 'marker' }
            ],
            exampleSentences:
              [
                {text: 'correct example', type: 'corrected'},
                {text: 'incorrect example', type: 'wrong'}
              ],
            ruleMessage: "my message"
          });
    }));
    
   it('should parse token attributes', inject(function(XmlParser) {
      expect(XmlParser.parseXml(
        "<rule name='myname'>" +
        "<pattern case_sensitive='yes'>" +
        "  <token postag='X' postag_regexp='yes' postag_negate='yes' regexp='yes' negate='yes' inflected='yes'>A</token>" +
        "</pattern>" +
        "<message>my message</message>" +
        "<example type='correct'>correct example</example>" +
        "<example type='incorrect'>incorrect example</example>" +
        "</rule>")).toEqual(
          {
            ruleId: null,
            ruleName: 'myname',
            caseSensitive: true,
            patternElements: [
              {
                tokenValue: 'A',
                tokenType: 'word_and_posTag',
                inflected: true,
                regex: true,
                negation: true,
                posTag: 'X',
                posTagRegex: true,
                posTagNegation: true,
                exceptions: [],
                attributes: []
              }],
            exampleSentences:
              [
                {text: 'correct example', type: 'corrected'},
                {text: 'incorrect example', type: 'wrong'}
              ],
            ruleMessage: "my message"
          });
    }));

    it('should parse and keep unknown attributes', inject(function(XmlParser) {
      expect(XmlParser.parseXml(
        "<rule>" +
        "<pattern><token someNewAttribute='myVal'>A</token></pattern>" +
        "<message>my message</message>" +
        "<example type='correct'>correct example</example>" +
        "<example type='incorrect'>incorrect example</example>" +
        "</rule>").patternElements[0].attributes).toEqual([{attName: 'someNewAttribute', attValue: 'myVal'}]);
    }));

  });
});
