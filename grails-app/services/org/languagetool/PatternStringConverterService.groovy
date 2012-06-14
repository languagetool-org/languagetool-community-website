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

import org.languagetool.rules.patterns.Element
import org.languagetool.rules.patterns.PatternRule
import org.languagetool.rules.Category
import org.languagetool.tokenizers.Tokenizer

class PatternStringConverterService {

    static transactional = true

    def convertToPatternRule(String patternString, Language lang) {
        List patternParts = getPatternParts(patternString, lang)
        List elements = []
        for (patternPart in patternParts) {
            boolean isRegex = isRegex(patternPart)
            elements.add(new Element(patternPart, false, isRegex, false))
        }
        PatternRule patternRule = new PatternRule("ID1", lang, elements, "empty description", "empty message", "empty short description")
        patternRule.setCategory(new Category("fake category"))
        return patternRule
    }

    // just a guess
    private boolean isRegex(patternPart) {
        return patternPart.find("[.|+*?\\[\\]]") != null
    }

    private List getPatternParts(String patternString, Language lang) {
        // First split at whitespace, then properly tokenize unless it's a regex. Only this way we will
        // properly tokenize "don't" but don't tokenize a regex like "foob.r":
        List simpleParts = patternString.split("\\s+")
        def tokenizer = lang.getWordTokenizer()
        List patternParts = []
        for (String simplePart in simpleParts) {
            if (isRegex(simplePart)) {
                patternParts.add(simplePart)
            } else {
                patternParts.addAll(getTokens(tokenizer, simplePart, lang))
            }
        }
        return patternParts
    }

    private List getTokens(Tokenizer tokenizer, String simplePart, Language lang) {
        List tokens = []
        List patternPartsWithWhitespace = tokenizer.tokenize(simplePart)
        for (patternPart in patternPartsWithWhitespace) {
            if (!patternPart.trim().isEmpty()) {
                if (lang.getShortName().equals(Language.CHINESE.getShortName())) {
                    // for some reason, tokens end with "/v" etc. in Chinese, cut that off:
                    patternPart = patternPart.replaceFirst("/.*", "")
                }
                tokens.add(patternPart)
            }
        }
        return tokens
    }

}
