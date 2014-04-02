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
            ruleMessage: "my message",
            messageMatches: []
          });
    }));
    
    it('should parse simple rule with marker around A', inject(function(XmlParser) {
      var result = XmlParser.parseXml(
        "<rule>" +
        "<pattern><marker><token>A</token></marker><token>B</token></pattern>" +
        "<message>my message</message>" +
        "</rule>");
      expect(result.patternElements.length).toEqual(4);
      expect(result.patternElements[0].tokenValue).toEqual('Marker start');
      expect(result.patternElements[1].tokenValue).toEqual('A');
      expect(result.patternElements[2].tokenValue).toEqual('Marker end');
      expect(result.patternElements[3].tokenValue).toEqual('B');
    }));
    
    it('should parse simple rule with marker around A (plus whitespace)', inject(function(XmlParser) {
      var result = XmlParser.parseXml(
        "<rule>" +
        "<pattern>  <marker>  <token>A</token>  </marker>  <token>B</token></pattern>" +
        "<message>my message</message>" +
        "</rule>");
      expect(result.patternElements.length).toEqual(4);
      expect(result.patternElements[0].tokenValue).toEqual('Marker start');
      expect(result.patternElements[1].tokenValue).toEqual('A');
      expect(result.patternElements[2].tokenValue).toEqual('Marker end');
      expect(result.patternElements[3].tokenValue).toEqual('B');
    }));
    
    it('should parse simple rule with marker around B', inject(function(XmlParser) {
      var result = XmlParser.parseXml(
        "<rule>" +
        "<pattern><token>A</token><marker><token>B</token></marker></pattern>" +
        "<message>my message</message>" +
        "</rule>");
      expect(result.patternElements.length).toEqual(4);
      expect(result.patternElements[0].tokenValue).toEqual('A');
      expect(result.patternElements[1].tokenValue).toEqual('Marker start');
      expect(result.patternElements[2].tokenValue).toEqual('B');
      expect(result.patternElements[3].tokenValue).toEqual('Marker end');
    }));
    
   it('should parse token attributes', inject(function(XmlParser) {
     var result = XmlParser.parseXml(
       "<rule name='myname'>" +
       "<pattern case_sensitive='yes'>" +
       "<token postag='X' postag_regexp='yes' postag_negate='yes' regexp='yes' negate='yes' inflected='yes'>A</token>" +
       "</pattern>" +
       "<message>my message</message>" +
       "</rule>");
      expect(result.ruleName).toEqual('myname');
      expect(result.caseSensitive).toEqual(true);
      var element = result.patternElements[0];
      expect(element.tokenValue).toEqual('A');
      expect(element.tokenType).toEqual('word_and_posTag');
      expect(element.inflected).toEqual(true);
      expect(element.regex).toEqual(true);
      expect(element.negation).toEqual(true);
      expect(element.posTag).toEqual('X');
      expect(element.posTagRegex).toEqual(true);
      expect(element.posTagNegation).toEqual(true);
      expect(element.exceptions).toEqual([]);
      expect(element.attributes).toEqual([]);
    }));

    it('should parse and keep unknown attributes', inject(function(XmlParser) {
      var result = XmlParser.parseXml(
        "<rule>" +
        "<pattern><token someNewAttribute='myVal'>A</token></pattern>" +
        "<message>my message</message>" +
        "</rule>");
      expect(result.patternElements[0].attributes).toEqual([{attName: 'someNewAttribute', attValue: 'myVal'}]);
    }));

    it('should parse message with match elements', inject(function(XmlParser) {
      var result = XmlParser.parseXml(
        "<rule>" +
        "<pattern><token someNewAttribute='myVal'>A</token></pattern>" +
        "<message>Use \\1, \\2 or <match no='3' case_conversion='allupper' regexp_match='re' regexp_replace='repl' /> instead, or \\4.</message>" +
        "</rule>");
      expect(result.ruleMessage).toEqual("Use \\1, \\2 or \\3 instead, or \\4.");
      expect(result.messageMatches.length).toEqual(4);
      expect(result.messageMatches[0].tokenNumber).toEqual('1');
      expect(result.messageMatches[1].tokenNumber).toEqual('2');
      expect(result.messageMatches[2].tokenNumber).toEqual('3');
      expect(result.messageMatches[2].caseConversion).toEqual('all upper');
      expect(result.messageMatches[2].regexMatch).toEqual('re');
      expect(result.messageMatches[2].regexReplace).toEqual('repl');
      expect(result.messageMatches[3].tokenNumber).toEqual('4');
    }));
    
    it('should parse message with suggestion and match elements', inject(function(XmlParser) {
      var result = XmlParser.parseXml(
        "<rule>" +
        "<pattern><token someNewAttribute='myVal'>A</token></pattern>" +
        "<message>Use <suggestion>foo \\1</suggestion> or <suggestion>bar \\2</suggestion>.</message>" +
        "</rule>");
      expect(result.ruleMessage).toEqual("Use 'foo \\1' or 'bar \\2'.");
      expect(result.messageMatches.length).toEqual(2);
      expect(result.messageMatches[0].tokenNumber).toEqual('1');
      expect(result.messageMatches[1].tokenNumber).toEqual('2');
    }));
    
    // TODO: exceptions

  });
});
