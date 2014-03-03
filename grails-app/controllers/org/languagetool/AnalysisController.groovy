/* LanguageTool Community
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
package org.languagetool

/**
 * Showing LanguageTool's text analysis for debugging.
 */
class AnalysisController extends BaseController {

    def index = {
        String langCode = params.lang ? params.lang : "en"
        Language langObject = Language.getLanguageForShortName(langCode)
        [language: langObject, languages: SortedLanguages.get()]
    }

    /**
     * Show POS tagging etc, mostly for debugging purposes.
     */
    def analyzeText = {
        String langCode = params.lang ? params.lang : "en"
        Language langObject = Language.getLanguageForShortName(langCode)
        final int maxTextLen = grailsApplication.config.max.text.length
        final String text = params.text
        if (text.size() > maxTextLen) {
            text = text.substring(0, maxTextLen)
            flash.message = "The text is too long, only the first $maxTextLen characters have been checked"
        }
        JLanguageTool lt = new JLanguageTool(langObject)
        lt.activateDefaultPatternRules()
        List<AnalyzedSentence> analyzedSentences = lt.analyzeText(text)
        [analyzedSentences: analyzedSentences, language: langObject, languages: SortedLanguages.get(),
                textToCheck: params.text]
    }

}
