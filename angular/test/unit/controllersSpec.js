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
      expect(scope.buildXml()).toContain("<pattern>");
      
      scope.setElement("hallo");
      expect(scope.buildXml()).toContain("<token>hallo</token>");

      scope.setElement("hallo", {regex: true});
      expect(scope.buildXml()).toContain("<token regexp='yes'>hallo</token>");

      scope.setElement("hallo", {negation: true});
      expect(scope.buildXml()).toContain("<token negate='yes'>hallo</token>");

      scope.setElement("hallo", {regex: true, negation: true});
      expect(scope.buildXml()).toContain("<token regexp='yes' negate='yes'>hallo</token>");

      scope.setElement("hallo", {regex: true, negation: true, baseform: true});
      expect(scope.buildXml()).toContain("<token inflected='yes' regexp='yes' negate='yes'>hallo</token>");


      scope.setElement("", {posTag: 'NN', tokenType: scope.TokenTypes.POS_TAG});
      expect(scope.buildXml()).toContain("<token postag='NN'></token>");

      scope.setElement("", {posTag: 'NN', posTagNegation: true, tokenType: scope.TokenTypes.POS_TAG});
      expect(scope.buildXml()).toContain("<token postag='NN' negate_pos='yes'></token>");

      scope.setElement("", {posTag: 'NN', posTagRegex: true, tokenType: scope.TokenTypes.POS_TAG});
      expect(scope.buildXml()).toContain("<token postag='NN' postag_regexp='yes'></token>");

      scope.setElement("", {posTag: 'NN', posTagRegex: true, posTagNegation: true, tokenType: scope.TokenTypes.POS_TAG});
      expect(scope.buildXml()).toContain("<token postag='NN' postag_regexp='yes' negate_pos='yes'></token>");


      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG});
      expect(scope.buildXml()).toContain("<token postag='NN'>hallo</token>");
      
      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: true});
      expect(scope.buildXml()).toContain("<token postag='NN' postag_regexp='yes'>hallo</token>");
      
      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: true, regex: true});
      expect(scope.buildXml()).toContain("<token regexp='yes' postag='NN' postag_regexp='yes'>hallo</token>");
      
      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: true, regex: true});
      expect(scope.buildXml()).toContain("<token regexp='yes' postag='NN' postag_regexp='yes'>hallo</token>");

      scope.setElement("hallo", {posTag: 'NN', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTagRegex: true, regex: true, negation: true, posTagNegation: true});
      expect(scope.buildXml()).toContain("<token regexp='yes' negate='yes' postag='NN' postag_regexp='yes' negate_pos='yes'>hallo</token>");


      scope.setElement("", {tokenType: scope.TokenTypes.ANY});
      expect(scope.buildXml()).toContain("<token></token>");

      scope.addMarker();
      expect(scope.buildXml()).toContain("<marker>");
      expect(scope.buildXml()).toContain("</marker>");

      expect(scope.buildXml()).toContain("<pattern>");
      scope.caseSensitive = true;
      expect(scope.buildXml()).toContain("<pattern case_sensitive='yes'>");
    }));

    it('should build XML with exception elements', inject(function($controller) {
      var elem = scope.setElement("hallo");
      scope.addException(elem);
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception></exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem);
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception></exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException'});
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', regex: true});
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception regexp='yes'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', baseform: true});
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception inflected='yes'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', regex: true});
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception regexp='yes'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', regex: true, negation:true});
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception regexp='yes' negate='yes'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("");
      scope.addException(elem, {tokenType: scope.TokenTypes.POS_TAG, posTag: 'XTAG'});
      expect(scope.buildXml()).toMatch("<token>\\s*<exception postag='XTAG'></exception>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'XTAG'});
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception postag='XTAG'>myException</exception>\\s*</token>");
      
      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'XTAG', posTagRegex: true, posTagNegation: true});
      expect(scope.buildXml()).toMatch("<token>hallo\\s*<exception postag='XTAG' postag_regexp='yes' negate_pos='yes'>myException</exception>\\s*</token>");
    }));

    it('should build XML with more examples', inject(function($controller) {
      // the default examples:
      expect(scope.buildXml()).toMatch("<example type='correct'>");
      expect(scope.buildXml()).toMatch("<example type='incorrect'>");
      
      var example = scope.addWrongExampleSentence();
      example.text = "example one";
      expect(scope.buildXml()).toMatch("<example type='incorrect'>example one</example>");

      example = scope.addCorrectedExampleSentence();
      example.text = "example two";
      expect(scope.buildXml()).toMatch("<example type='incorrect'>example one</example>");
      expect(scope.buildXml()).toMatch("<example type='correct'>example two</example>");
    }));

    it('should optionally add marker', inject(function($controller) {
      expect(scope.buildXml()).not.toMatch("<marker>");
      expect(scope.buildXml(true)).not.toMatch("<marker>");
      scope.wrongSentenceWithMarker = "This <marker>are</marker> wrong.";
      expect(scope.buildXml()).not.toMatch("<marker>");
      expect(scope.buildXml(true)).toMatch("<marker>are</marker>");
    }));

    it('should consider attributes', inject(function($controller) {
      var elem = scope.setElement("hallo");
      elem.attributes = [{attName: 'myKey', attValue: 'myValue'}, {attName: 'myKey2', attValue: 'myValue2'}];
      expect(scope.buildXml(true)).toMatch("<token myKey='myValue' myKey2='myValue2'>hallo</token>");

      elem = scope.setElement(null, {tokenType: scope.TokenTypes.POS_TAG, posTag: 'POS'});
      elem.attributes = [{attName: 'myKey', attValue: 'myValue'}, {attName: 'myKey2', attValue: 'myValue2'}];
      expect(scope.buildXml(true)).toMatch("<token postag='POS' myKey='myValue' myKey2='myValue2'></token>");

      elem = scope.setElement("hallo", {tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'POS'});
      elem.attributes = [{attName: 'myKey', attValue: 'myValue'}, {attName: 'myKey2', attValue: 'myValue2'}];
      expect(scope.buildXml(true)).toMatch("<token postag='POS' myKey='myValue' myKey2='myValue2'>hallo</token>");

      elem = scope.setElement("hallo", {tokenType: scope.TokenTypes.ANY});
      elem.attributes = [{attName: 'myKey', attValue: 'myValue'}, {attName: 'myKey2', attValue: 'myValue2'}];
      expect(scope.buildXml(true)).toMatch("<token myKey='myValue' myKey2='myValue2'></token>");
    }));

    it('should consider attributes for exceptions', inject(function($controller) {
      var elem = scope.setElement("hallo");
      var attribute1 = {attName: 'myKey', attValue: 'myVal'};
      var attribute2 = {attName: 'myKey2', attValue: 'myVal2'};
      scope.addException(elem, {tokenValue: 'myException', attributes: [attribute1]});
      expect(scope.buildXml(true)).toMatch("<token>hallo<exception myKey='myVal'>myException</exception></token>");

      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', attributes: [attribute1, attribute2]});
      expect(scope.buildXml(true)).toMatch("<token>hallo<exception myKey='myVal' myKey2='myVal2'>myException</exception></token>");

      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenType: scope.TokenTypes.POS_TAG, posTag: 'XTAG', attributes: [attribute1]});
      expect(scope.buildXml(true)).toMatch("<token>hallo<exception postag='XTAG' myKey='myVal'></exception></token>");

      elem = scope.setElement("hallo");
      scope.addException(elem, {tokenValue: 'myException', tokenType: scope.TokenTypes.WORD_AND_POS_TAG, posTag: 'XTAG', attributes: [attribute1]});
      expect(scope.buildXml(true)).toMatch("<token>hallo<exception postag='XTAG' myKey='myVal'>myException</exception></token>");
    }));

  });
});
