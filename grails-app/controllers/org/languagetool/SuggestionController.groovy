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

import ltcommunity.Suggestion

/**
 * Get user suggestion for words that might be added to the dictionary.
 */
class SuggestionController {
    
    def index() {
        if (!params.lang) {
            throw new Exception("Parameter 'lang' needs to be set")
        }
        if (!params.word) {
            throw new Exception("Parameter 'word' needs to be set")
        }
        Language lang = Languages.getLanguageForShortName(params.lang)
        def bundle = JLanguageTool.getMessageBundle(lang)
        String i18nLanguage = bundle.getString(lang.getShortName())
        [language: lang, i18nLanguage: i18nLanguage]
    }

    def suggestWord() {
        log.info("Saving word suggestion: ${params.word}, language ${params.languageCode}, email ${params.email}")
        Suggestion s = new Suggestion()
        s.date = new Date()
        s.word = params.word
        s.languageCode = params.languageCode
        s.email = params.email
        s.save(failOnError: true)
        []
    }
    
    def feed() {
        String password = grailsApplication.config.suggestion.password
        if (!password || password.trim().isEmpty()) {
            throw new Exception("'suggestion.password' needs to be set in Config.groovy")
        }
        if (params.password != password) {
            throw new Exception("Invalid password")
        }
        render(feedType:"rss", feedVersion:"2.0") {
            title = "LanguageTool Word Suggestions"
            description = "Words that should be added to LanguageTool's spell dictionary, as suggested by users"
            link = createLink(controller: 'suggestion', action: 'feed', absolute: true)
            List suggestions
            if (params.lang) {
                suggestions = Suggestion.findAllByLanguageCode(params.lang, [max: 100, sort:'date', order:'desc'])
            } else {
                suggestions = Suggestion.findAll([max: 100, sort:'date', order:'desc'])
            }
            suggestions.each { suggestion ->
                entry("${suggestion.word} - language: ${suggestion.languageCode}, email: ${suggestion.email}") {
                    publishedDate = suggestion.date
                    "Language: ${suggestions.languageCode}\n" +
                        "Word: ${suggestions.word}\n" +
                        "Email: ${suggestions.email}\n" +
                        "Date: ${suggestions.date}\n"
                }
            }
        }
    }
}
