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

import org.languagetool.tagging.xx.DemoTagger

/**
 * Editor that helps with creating the XML for simple rules.
 * Supposed to replace RuleEditor2Controller when it's ready.
 */
class RuleEditor2Controller extends BaseController {

    def index() {
        String langCode = params.lang ? params.lang : "en"
        Language language = Language.getLanguageForShortName(langCode)
        [languages: Language.REAL_LANGUAGES, language: language]
    }

    def posTagInformation() {
        String langCode = params.lang ? params.lang : "en"
        Language language = Language.getLanguageForShortName(langCode)
        if (language.getTagger() && !(language.getTagger() instanceof DemoTagger)) {
            redirect(url: "https://raw.githubusercontent.com/languagetool-org/languagetool/master/languagetool-language-modules/" +
                    langCode + "/src/main/resources/org/languagetool/resource/" + langCode + "/tagset.txt")
        } else {
            [languages: Language.REAL_LANGUAGES, language: language]
        }
    }
}
