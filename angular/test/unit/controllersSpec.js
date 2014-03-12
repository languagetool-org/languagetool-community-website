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
  
  beforeEach(module('ruleEditor'));
  beforeEach(module('ruleEditor.services'));

  describe('RuleEditorCtrl', function() {

    it('should provide some basic elements manipulations', inject(function($controller) {
      var scope = {}, ctrl = $controller('RuleEditorCtrl', { $scope: scope });

      expect(scope.languageCode.code).toBe("en");
      expect(scope.languageCode.name).toBe("English");
      expect(scope.languageCodes.length).toBeGreaterThan(28);

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
    }));

    it('should not count markers in elementPosition()', inject(function($controller) {
      var scope = {}, ctrl = $controller('RuleEditorCtrl', { $scope: scope });

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
      var scope = {}, ctrl = $controller('RuleEditorCtrl', { $scope: scope });

      scope.addElement("foo");
      expect(scope.patternElements.length).toBe(1);
      expect(scope.hasNoMarker()).toBeTruthy();
      scope.addMarker();
      expect(scope.hasNoMarker()).toBeFalsy();
      expect(scope.patternElements.length).toBe(3);
      expect(scope.patternElements[0].tokenType).toBe("marker");
      expect(scope.patternElements[2].tokenType).toBe("marker");
      scope.removeMarkers();
      expect(scope.hasNoMarker()).toBeTruthy();
      expect(scope.patternElements.length).toBe(1);
      expect(scope.patternElements[0].tokenValue).toBe("foo");
    }));

    it('should remove both markers in removeElement()', inject(function($controller) {
      var scope = {}, ctrl = $controller('RuleEditorCtrl', { $scope: scope });

      scope.addElement("foo");
      scope.addMarker();
      scope.removeElement(scope.patternElements[0]);
      expect(scope.hasNoMarker()).toBeTruthy();

      scope.addMarker();
      scope.removeElement(scope.patternElements[2]);
      expect(scope.hasNoMarker()).toBeTruthy();
    }));
    
    it('should create elements', inject(function($controller) {
      var scope = {}, ctrl = $controller('RuleEditorCtrl', { $scope: scope });

      expect(scope.addElement("hallo").regex).toBe(false);
      expect(scope.addElement("hallo", {regex: true}).regex).toBe(true);
    }));
    
    // testing XML here as it depends on the controller:
    it('should build XML', inject(function($controller) {
      var scope = {}, ctrl = $controller('RuleEditorCtrl', { $scope: scope });

      expect(scope.buildXml()).toContain("<pattern>");
      
      scope.setElement("hallo");
      expect(scope.buildXml()).toContain("<token>hallo</token>");

      scope.setElement("hallo", {regex: true});
      expect(scope.buildXml()).toContain("<token regexp='yes'>hallo</token>");

      scope.setElement("hallo", {regex: true, negation: true});
      expect(scope.buildXml()).toContain("<token regexp='yes' negate='yes'>hallo</token>");

      scope.setElement("hallo", {negation: true});
      expect(scope.buildXml()).toContain("<token negate='yes'>hallo</token>");

      scope.setElement("NN", {tokenType: 'posTag'});
      expect(scope.buildXml()).toContain("<token postag='NN'></token>");

      scope.setElement("NN", {negation: true, tokenType: 'posTag'});
      expect(scope.buildXml()).toContain("<token postag='NN' negate_pos='yes'></token>");

      scope.setElement("NN", {regex: true, tokenType: 'posTag'});
      expect(scope.buildXml()).toContain("<token postag='NN' postag_regexp='yes'></token>");

      scope.setElement("NN", {regex: true, negation: true, tokenType: 'posTag'});
      expect(scope.buildXml()).toContain("<token postag='NN' postag_regexp='yes' negate_pos='yes'></token>");

      scope.addMarker();
      expect(scope.buildXml()).toContain("<marker>");
      expect(scope.buildXml()).toContain("</marker>");
      
      // TODO: test exception
      
    }));
    
  });
});
