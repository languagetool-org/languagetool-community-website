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
        List<AnalyzedSentence> analyzedSentences = getAnalyzedSentences(params.text, langObject)
        [analyzedSentences: analyzedSentences, language: langObject, languages: SortedLanguages.get(),
                textToCheck: params.text]
    }

    /**
     * Tokenize two example sentences for the rule editor and check the first (incorrect) sentence.
     */
    def tokenizeSentences = {
        Language lang = Language.getLanguageForShortName(params.lang)
        JLanguageTool lt = new JLanguageTool(lang)
        lt.activateDefaultPatternRules()
        List<String> tokens1 = getTokens(params.sentence1, lt)
        def ruleMatches = lt.check((String)params.sentence1)
        String ruleMatchesHtml
        if (ruleMatches.size() > 0) {
            ruleMatchesHtml = g.render(template: '/ruleMatches',
                    model: [matches: ruleMatches, textToCheck: params.sentence1, hideRuleLink: true])
        }
        List<String> tokens2 = getTokens(params.sentence2, lt)
        render(contentType: "text/json") {[
            'sentence1': tokens1,
            'sentence1Matches': ruleMatchesHtml,
            'sentence2': tokens2
        ]}
    }

    private List<String> getTokens(String text, JLanguageTool lt) {
        List<AnalyzedSentence> analyzedSentences = lt.analyzeText(text)
        List tokens = []
        for (AnalyzedSentence analyzedSentence : analyzedSentences) {
            AnalyzedTokenReadings[] readings = analyzedSentence.getTokensWithoutWhitespace()
            for (AnalyzedTokenReadings r : readings) {
                tokens.add(r.getToken())
            }
        }
        return tokens
    }

    /**
     * Show POS tagging etc, for embedding as a debugging help in rule editor.
     */
    def analyzeTextForEmbedding = {
        Language langObject = Language.getLanguageForShortName(params.lang)
        List<AnalyzedSentence> analyzedSentences = getAnalyzedSentences(params.text, langObject)
        [analyzedSentences: analyzedSentences, language: langObject, languages: SortedLanguages.get(),
                textToCheck: params.text]
    }

    private List<AnalyzedSentence> getAnalyzedSentences(String text, Language lang) {
        final int maxTextLen = grailsApplication.config.max.text.length
        if (text.size() > maxTextLen) {
            text = text.substring(0, maxTextLen)
            // TODO: won't show up, as we're embedded via Ajax
            flash.message = "The text is too long, only the first $maxTextLen characters have been checked"
        }
        JLanguageTool lt = new JLanguageTool(lang)
        lt.activateDefaultPatternRules()
        List<AnalyzedSentence> analyzedSentences = lt.analyzeText(text)
        return analyzedSentences
    }

}
