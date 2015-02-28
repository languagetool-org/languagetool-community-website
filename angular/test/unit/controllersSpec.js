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

var __ruleEditorXml;

describe('RuleEditor controllers', function() {
  
  describe('RuleEditorCtrl', function() {

    var scope, ctrl;
    beforeEach(module('ruleEditor'));
    beforeEach(module('ruleEditor.services'));
    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      ctrl = $controller('RuleEditorCtrl', {
        $scope: scope
      });
    }));

    function clean(s) {
        return s;
    }
    
    it('should extract language from url', inject(function($controller) {
      expect(scope.getParam("lang", "http://foo.de?lang=xx")).toBe("xx");
      expect(scope.getParam("lang", "http://foo.de?lang=xx&wrong=an+wrong+sentence")).toBe("xx");
      expect(scope.getParam("lang", "http://foo.de?wrong=an+wrong+sentence&foo=bar&lang=yy")).toBe("yy");
      expect(scope.getParam("lang", "http://foo.de/bla")).toBe(null);
    }));
      
    it('should provide some basic elements manipulations', inject(function($controller) {
      expect(scope.language.code).toBe("en");
      expect(scope.language.name).toBe("English");
      expect(scope.languages.length).toBeGreaterThan(28);

      var elems = scope.patternElements;
      expect(elems.length).toBe(0);
      scope.addElement("foo");
      expect(elems.length).toBe(1);
      expect(elems[0].tokenValue).toBe("foo");

      expect(elems[0].exceptions.length).toBe(0);
      scope.addException(elems[0]);
      expect(elems.length).toBe(1);
      expect(elems[0].exceptions.length).toBe(1);

      scope.removeException(elems[0], elems[0].exceptions[0]);
      expect(elems[0].exceptions.length).toBe(0);
      
      scope.removeElement(elems[0]);
      expect(elems.length).toBe(0);

      expect(scope.exampleSentences.length).toBe(2);
      scope.addWrongExampleSentence();
      expect(scope.exampleSentences.length).toBe(3);
      expect(scope.exampleSentences[2].text).toBe('');
      expect(scope.exampleSentences[2].type).toBe('wrong');
      var exampleSentence = scope.addCorrectedExampleSentence();
      expect(scope.exampleSentences.length).toBe(4);
      expect(scope.exampleSentences[3].text).toBe('');
      expect(scope.exampleSentences[3].type).toBe('corrected');
      scope.removeExampleSentence(exampleSentence);
      expect(scope.exampleSentences.length).toBe(3);
    }));

    it('should not count markers in elementPosition()', inject(function($controller) {
      scope.addElement("foo");
      expect(scope.patternElements.length).toBe(1);
      expect(scope.elementPosition(scope.patternElements[0])).toBe(1);
      scope.addMarker();
      expect(scope.patternElements.length).toBe(3);
      //expect(scope.elementPosition(scope.patternElements[0])).toBe(1);  // marker
      expect(scope.elementPosition(scope.patternElements[1])).toBe(1);
      expect(scope.elementPosition(scope.patternElements[2])).toBe(1);  // marker
    }));
    
    it('should handle markers correctly', inject(function($controller) {
      scope.addElement("foo");
      expect(scope.patternElements.length).toBe(1);
      expect(scope.hasNoMarker()).toBeTruthy();
      scope.addMarker();
      expect(scope.hasNoMarker()).toBeFalsy();
      expect(scope.patternElements.length).toBe(3);
      expect(scope.patternElements[0].tokenType).toBe(scope.TokenTypes.MARKER);
      expect(scope.patternElements[2].tokenType).toBe(scope.TokenTypes.MARKER);
      scope.removeMarkers();
      expect(scope.hasNoMarker()).toBeTruthy();
      expect(scope.patternElements.length).toBe(1);
      expect(scope.patternElements[0].tokenValue).toBe("foo");
    }));

    it('should remove both markers in removeElement()', inject(function($controller) {
      scope.addElement("foo");
      scope.addMarker();
      scope.removeElement(scope.patternElements[0]);
      expect(scope.hasNoMarker()).toBeTruthy();

      scope.addMarker();
      scope.removeElement(scope.patternElements[2]);
      expect(scope.hasNoMarker()).toBeTruthy();
    }));
    
    it('should create elements', inject(function($controller) {
      expect(scope.addElement("hallo").regex).toBe(false);
      expect(scope.addElement("hallo", {regex: true}).regex).toBe(true);
    }));
    
    // testing XML here as it depends on the controller:
    it('should build XML', inject(function($controller) {
      expect(clean(scope.buildXml())).toContain("<pattern>");
      
      scope.setElement("hallo");
      expect(clean(scope.buildXml())).toContain("<token>hallo</token>");

      scope.setElement("hallo", {regex: true});
      expect(clean(scope.buildXml())).toContain("<token regexp='yes'>hallo</token>");

      scope.setElement("hallo", {negation: true});
      expect(clean(scope.buildXml())).toContain("<token negate='yes'>hallo</token>");

      scope.setElement("hallo", {regex: true, negation: true});
      expect(clean(scope.buildXml())).toContain("<token regexp='yes' negate='yes'>hallo</token>");

      scope.setElement("hallo", {regex: true, negation: true, inflected: true});
      expect(clean(scope.buildXml())).toContain("<token inflected='yes' regexp='yes' negate='yes'>hallo</token>");


      scope.setElement("", {posTag: 'NN', tokenType: scope.TokenTypes.POS_TAG});
      expect(clean(scope.buildXml())).toContain("<token postag='NN'></token>");

      scope.setElement("", {posTag: 'NN', posTagNegation: true, tokenType: scope.TokenTypes.POS_TAG});
      expect(clean(scope.buildXml())).toContain("<token postag='NN' negate_pos='yes'></token>");

      scope.setElement("", {posTag: 'NN', posTagRegex: true, tokenType: scope.TokenTypes.POS_TAG});
      expect(clean(scope.buildXml())).toContain("<token postag='NN' postag_regexp='yes'></token>");

      scope.setElement("", {posTag: 'NN', posTagRegex: true, posTagNegation: true, tokenType: scope.TokenTypes.POS_TAG});
      expect(clean(scope.buildXml())).toContain("<token postag='NN' postag_regexp='yes' negate_pos='yes'></token>");


      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG});
      expect(clean(scope.buildXml())).toContain("<token postag='NN'>hallo</token>");

      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: true});
      expect(clean(scope.buildXml())).toContain("<token postag='NN' postag_regexp='yes'>hallo</token>");

      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: true, regex: true});
      expect(clean(scope.buildXml())).toContain("<token regexp='yes' postag='NN' postag_regexp='yes'>hallo</token>");

      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: true, regex: true});
      expect(clean(scope.buildXml())).toContain("<token regexp='yes' postag='NN' postag_regexp='yes'>hallo</token>");

      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: true, regex: true, negation: true, posTagNegation: true});
      expect(clean(scope.buildXml())).toContain("<token regexp='yes' negate='yes' postag='NN' postag_regexp='yes' negate_pos='yes'>hallo</token>");


      scope.setElement("", {tokenType: scope.TokenTypes.ANY});
      expect(clean(scope.buildXml())).toContain("<token></token>");

      scope.addMarker();
      expect(clean(scope.buildXml())).toContain("<marker>");
      expect(clean(scope.buildXml())).toContain("</marker>");

      expect(clean(scope.buildXml())).toContain("<pattern>");
      scope.caseSensitive = true;
      expect(clean(scope.buildXml())).toContain("<pattern case_sensitive='yes'>");
    }));

    it('should build XML with exception elements', inject(function($controller) {
      var elem = scope.setElement("hallo");
      scope.addException(elem);
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception></exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem);
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception></exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException'});
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', regex: true});
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception regexp='yes'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', inflected: true});
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception inflected='yes'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', regex: true});
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception regexp='yes'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', regex: true, negation:true});
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception regexp='yes' negate='yes'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("");
      scope.addException(elem, {tokenType: scope.TokenTypes.POS_TAG, posTag: 'XTAG'});
      expect(clean(scope.buildXml())).toMatch("<token>\\s*<exception postag='XTAG'></exception>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'XTAG'});
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception postag='XTAG'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'XTAG', posTagRegex: true, posTagNegation: true});
      expect(clean(scope.buildXml())).toMatch("<token>hallo\\s*<exception postag='XTAG' postag_regexp='yes' negate_pos='yes'>myException</exception>\\s*</token>");
    }));

    it('should build XML with more examples', inject(function($controller) {
      // the default examples:
      expect(clean(scope.buildXml())).toContain("<example>");
      expect(clean(scope.buildXml())).toContain("<example correction=''>");
      
      var example = scope.addWrongExampleSentence();
      example.text = "example one";
      expect(clean(scope.buildXml())).toContain("<example correction=''>example one</example>");

      example = scope.addCorrectedExampleSentence();
      example.text = "example two";
      expect(clean(scope.buildXml())).toContain("<example correction=''>example one</example>");
      expect(clean(scope.buildXml())).toContain("<example>example two</example>");
    }));

    it('should optionally add marker', inject(function($controller) {
      expect(clean(scope.buildXml())).not.toContain("<marker>");
      expect(clean(scope.buildXml(true))).not.toContain("<marker>");
      scope.wrongSentenceWithMarker = "This <marker>are</marker> wrong.";
      expect(clean(scope.buildXml())).not.toContain("<marker>");
      expect(clean(scope.buildXml(true))).toContain("<marker>are</marker>");
    }));

    it('should consider attributes', inject(function($controller) {
      var elem = scope.setElement("hallo");
      elem.attributes = [{attName: 'myKey', attValue: 'myValue'}, {attName: 'myKey2', attValue: 'myValue2'}];
      expect(clean(scope.buildXml(true))).toContain("<token myKey='myValue' myKey2='myValue2'>hallo</token>");

      elem = scope.setElement(null, {tokenType: scope.TokenTypes.POS_TAG, posTag: 'POS'});
      elem.attributes = [{attName: 'myKey', attValue: 'myValue'}, {attName: 'myKey2', attValue: 'myValue2'}];
      expect(clean(scope.buildXml(true))).toContain("<token postag='POS' myKey='myValue' myKey2='myValue2'></token>");

      elem = scope.setElement("hallo", {tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'POS'});
      elem.attributes = [{attName: 'myKey', attValue: 'myValue'}, {attName: 'myKey2', attValue: 'myValue2'}];
      expect(clean(scope.buildXml(true))).toContain("<token postag='POS' myKey='myValue' myKey2='myValue2'>hallo</token>");

      elem = scope.setElement("hallo", {tokenType: scope.TokenTypes.ANY});
      elem.attributes = [{attName: 'myKey', attValue: 'myValue'}, {attName: 'myKey2', attValue: 'myValue2'}];
      expect(clean(scope.buildXml(true))).toContain("<token myKey='myValue' myKey2='myValue2'></token>");
    }));

    it('should consider attributes for exceptions', inject(function($controller) {
      var elem = scope.setElement("hallo");
      var attribute1 = {attName: 'myKey', attValue: 'myVal'};
      var attribute2 = {attName: 'myKey2', attValue: 'myVal2'};
      scope.addException(elem, {tokenValue: 'myException', attributes: [attribute1]});
      expect(clean(scope.buildXml(true))).toContain("<token>hallo<exception myKey='myVal'>myException</exception></token>");

      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', attributes: [attribute1, attribute2]});
      expect(clean(scope.buildXml(true))).toContain("<token>hallo<exception myKey='myVal' myKey2='myVal2'>myException</exception></token>");

      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenType: scope.TokenTypes.POS_TAG, posTag: 'XTAG', attributes: [attribute1]});
      expect(clean(scope.buildXml(true))).toContain("<token>hallo<exception postag='XTAG' myKey='myVal'></exception></token>");

      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'XTAG', attributes: [attribute1]});
      expect(clean(scope.buildXml(true))).toContain("<token>hallo<exception postag='XTAG' myKey='myVal'>myException</exception></token>");
    }));

    it('should support old regex-based POS tags as well as structured POS tags', inject(function($controller) {
      scope.setElement(null, {posTag: 'NN pos=noun', tokenType: scope.TokenTypes.POS_TAG, posTagRegex: false, regex: false});
      expect(clean(scope.buildXml(true))).toContain("<token postag='NN' pos='noun'></token>");

      scope.setElement("hallo", {posTag: 'NN pos=noun number=singular', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: false, regex: false});
      expect(clean(scope.buildXml(true))).toContain("<token postag='NN' pos='noun' number='singular'>hallo</token>");

      scope.setElement("hallo", {posTag: 'pos=noun number=singular N[xy]', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: false, regex: false});
      expect(clean(scope.buildXml(true))).toContain("<token pos='noun' number='singular' postag='N[xy]'>hallo</token>");

      scope.setElement("hallo", {posTag: 'pos=noun|verb number=singular', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: false, regex: false});
      expect(clean(scope.buildXml(true))).toContain("<token pos='noun verb' number='singular'>hallo</token>");
    }));

    it('should support old regex-based POS tags as well as structured POS tags for exceptions', inject(function($controller) {
      var elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: null, tokenType: scope.TokenTypes.POS_TAG, posTag: 'XX person=1|2'});
      expect(clean(scope.buildXml(true))).toContain("<token>hallo<exception postag='XX' person='1 2'></exception></token>");

      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'ex', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'XX person=1|2'});
      expect(clean(scope.buildXml(true))).toContain("<token>hallo<exception postag='XX' person='1 2'>ex</exception></token>");

      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'ex', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'person=1|2'});
      expect(clean(scope.buildXml(true))).toContain("<token>hallo<exception person='1 2'>ex</exception></token>");
    }));

    it('should extract message matches from message', inject(function($controller) {
      scope.extractMessageMatches("foo");
      expect(scope.messageMatches.length).toBe(0);
      scope.messageMatches = [];

      scope.setElement("hallo");

      scope.ruleMessage = "foo \\1";
      scope.extractMessageMatches(scope.ruleMessage);
      expect(scope.messageMatches.length).toBe(1);
      expect(scope.messageMatches[0].tokenNumber).toBe("1");
      expect(clean(scope.buildXml(true))).toContain('<message>foo <match no="1"/></message>');
      scope.messageMatches = [];

      scope.ruleMessage = "Did you mean \\1 or '\\1 blah'?";
      scope.extractMessageMatches(scope.ruleMessage);
      expect(scope.messageMatches.length).toBe(2);
      expect(scope.messageMatches[0].tokenNumber).toBe("1");
      expect(scope.messageMatches[1].tokenNumber).toBe("1");
      expect(clean(scope.buildXml(true))).toContain('<message>Did you mean <match no="1"/> or <suggestion><match no="1"/> blah</suggestion>?</message>');
      scope.messageMatches = [];

      scope.ruleMessage = "Did you mean \\1 or '\\1 blah' or '\\2 foo'?";
      scope.extractMessageMatches(scope.ruleMessage);
      expect(scope.messageMatches.length).toBe(3);
      expect(scope.messageMatches[0].tokenNumber).toBe("1");
      expect(scope.messageMatches[1].tokenNumber).toBe("1");
      expect(scope.messageMatches[2].tokenNumber).toBe("2");
      expect(clean(scope.buildXml(true))).toContain('<message>Did you mean <match no="1"/> or <suggestion><match no="1"/> blah</suggestion> or <suggestion><match no="2"/> foo</suggestion>?</message>');

      scope.messageMatches[0].caseConversion = scope.CaseConversion.ALL_LOWER;
      scope.messageMatches[1].caseConversion = scope.CaseConversion.ALL_UPPER;
      expect(clean(scope.buildXml(true))).toContain('<message>Did you mean <match no="1" case_conversion="alllower"/> or <suggestion><match no="1" case_conversion="allupper"/> blah</suggestion> or <suggestion><match no="2"/> foo</suggestion>?</message>');
    }));

  });
});
