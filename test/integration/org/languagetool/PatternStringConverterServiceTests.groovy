/* LanguageTool Community
 * Copyright (C) 2012 Daniel Naber (http://www.danielnaber.de)
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
package org.languagetool

import grails.test.*
import org.languagetool.rules.patterns.PatternRule

class PatternStringConverterServiceTests extends GrailsUnitTestCase {

  def patternStringConverterService

  void testConverter() {
    PatternRule rule = patternStringConverterService.convertToPatternRule("bed English", Language.ENGLISH)
    def elements = rule.getElements()
    assertEquals(2, elements.size())

    assertEquals("bed", elements.get(0).getString())
    assertEquals(false, elements.get(0).isInflected())
    assertEquals(false, elements.get(0).isRegularExpression())

    assertEquals("English", elements.get(1).getString())
    assertEquals(false, elements.get(1).isInflected())
    assertEquals(false, elements.get(1).isRegularExpression())
  }

  void testConverterRegex1() {
    PatternRule rule = patternStringConverterService.convertToPatternRule("bed English|German", Language.ENGLISH)
    def elements = rule.getElements()
    assertEquals(2, elements.size())

    assertEquals("bed", elements.get(0).getString())
    assertEquals(false, elements.get(0).isInflected())
    assertEquals(false, elements.get(0).isRegularExpression())

    assertEquals("English|German", elements.get(1).getString())
    assertEquals(false, elements.get(1).isInflected())
    assertEquals(true, elements.get(1).isRegularExpression())
  }

  void testConverterRegex2() {
    PatternRule rule = patternStringConverterService.convertToPatternRule("[abc]bar", Language.ENGLISH)
    def elements = rule.getElements()
    assertEquals(1, elements.size())

    assertEquals("[abc]bar", elements.get(0).getString())
    assertEquals(false, elements.get(0).isInflected())
    assertEquals(true, elements.get(0).isRegularExpression())
  }

  void testConverterRegexWithDot() {
    PatternRule rule = patternStringConverterService.convertToPatternRule("b.r", Language.ENGLISH)
    def elements = rule.getElements()
    assertEquals(1, elements.size())

    assertEquals("b.r", elements.get(0).getString())
    assertEquals(false, elements.get(0).isInflected())
    assertEquals(true, elements.get(0).isRegularExpression())
  }

  void testConverterRegexWithParentheses() {
    PatternRule rule = patternStringConverterService.convertToPatternRule("(English|German)", Language.ENGLISH)
    def elements = rule.getElements()
    assertEquals(1, elements.size())

    assertEquals("(English|German)", elements.get(0).getString())
    assertEquals(false, elements.get(0).isInflected())
    assertEquals(true, elements.get(0).isRegularExpression())
  }

  void testConverterWithDash() {
    PatternRule rule = patternStringConverterService.convertToPatternRule("no-go", Language.ENGLISH)
    def elements = rule.getElements()
    assertEquals(1, elements.size())

    assertEquals("no-go", elements.get(0).getString())
    assertEquals(false, elements.get(0).isInflected())
    assertEquals(false, elements.get(0).isRegularExpression())
  }

  void testConverterWithContraction() {
    PatternRule rule = patternStringConverterService.convertToPatternRule("don't want", Language.ENGLISH)
    def elements = rule.getElements()
    assertEquals(4, elements.size())

    assertEquals("don", elements.get(0).getString())
    assertEquals(false, elements.get(0).isInflected())
    assertEquals(false, elements.get(0).isRegularExpression())

    assertEquals("'", elements.get(1).getString())
    assertEquals(false, elements.get(1).isInflected())
    assertEquals(false, elements.get(1).isRegularExpression())

    assertEquals("t", elements.get(2).getString())
    assertEquals(false, elements.get(2).isInflected())
    assertEquals(false, elements.get(2).isRegularExpression())

    assertEquals("want", elements.get(3).getString())
    assertEquals(false, elements.get(3).isInflected())
    assertEquals(false, elements.get(3).isRegularExpression())
  }

}
