/* LanguageTool Community
 * Copyright (C) 2008 Daniel Naber (http://www.danielnaber.de)
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
 * The main page of the website.
 */
class HomepageController extends BaseController {

    /**
     * Display the site's main page.
     */
    def index = {
        String langCode = params.lang ? params.lang : "en"
        Language langObject = Language.getLanguageForShortName(langCode)
        render(view:'index',model:[langCode: langCode,
                lang: langCode,		// used in _corpusMatches.gsp
                languages: SortedLanguages.get(), language: langObject])
    }

    /**
     * Offer a simple form that works without JavaScript.
     */
    def simpleCheck = {
        List languages = SortedLanguages.get()
        String langCode = "en-US"
        if (params.lang) {
            langCode = params.lang
        }
        params.language = langCode
        params.lang = langCode
        Language language = Language.getLanguageForShortName(langCode)
        render(view: 'checkText', model:[languages: languages, language: language])
    }
    
    /**
     * Run the grammar checker on the given text.
     */
    def checkText = {
        List languages = SortedLanguages.get()
        String langStr = "en"
        if (params.language) {
            langStr = params.language
        } else if (params.lang) {
            langStr = params.lang
        }
        Language lang = Language.getLanguageForShortName(langStr)
        if (lang.hasVariant()) {
            lang = lang.getDefaultLanguageVariant()   // we need to select a variant because we want spell checking
        }
        JLanguageTool lt = new JLanguageTool(lang)
        lt.activateDefaultPatternRules()
        final int maxTextLen = grailsApplication.config.max.text.length
        final String text = params.text
        if (text.size() > maxTextLen) {
            text = text.substring(0, maxTextLen)
            flash.message = "The text is too long, only the first $maxTextLen characters have been checked"
        }
        List ruleMatches = lt.check(text)
        [matches: ruleMatches, lang: langStr, language: lang, languages: languages,
                textToCheck: params.text]
    }

}
