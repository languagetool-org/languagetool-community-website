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

import org.apache.commons.io.IOUtils
import org.languagetool.rules.patterns.PatternRuleId
import org.languagetool.rules.patterns.PatternRuleXmlCreator
import org.languagetool.tagging.xx.DemoTagger

/**
 * Editor that helps with creating the XML for rules.
 * Supposed to replace RuleEditorController when it's ready.
 */
class RuleEditor2Controller extends BaseController {

    def index() {
        Language language = Languages.getLanguageForShortName(params.lang ? params.lang : "en")
        String ruleXml = ''
        if (params.id) {
            PatternRuleId id = params.subId ? new PatternRuleId(params.id, params.subId) : new PatternRuleId(params.id)
            PatternRuleXmlCreator ruleXmlCreator = new PatternRuleXmlCreator()
            ruleXml = ruleXmlCreator.toXML(id, language).replace("\n", "__NL__").replace("\\", "\\\\")
        }
        [languages: Languages.get(), language: language, ruleXml: ruleXml]
    }

    def posTagInformation() {
        String langCode = params.lang ? params.lang : "en"
        Language language = Languages.getLanguageForShortName(langCode)
        if (language.getTagger() && !(language.getTagger() instanceof DemoTagger)) {
            redirect(url: "https://github.com/languagetool-org/languagetool/blob/master/languagetool-language-modules/" +
                    "${langCode}/src/main/resources/org/languagetool/resource/${langCode}/tagset.txt")
        } else {
            [languages: Languages.get(), language: language]
        }
    }
    
    def examples() {
        Language language = Languages.getLanguageForShortName(params.lang ? params.lang : "en")
        def path = "/examples/" + language.getShortName() + ".txt"
        InputStream stream = RuleEditor2Controller.class.getResourceAsStream(path)
        List examples = []
        if (stream) {
            examples = IOUtils.readLines(stream)
            examples = examples.findAll { e -> !e.startsWith("#") && !e.trim().isEmpty() }
        } else {
            log.info("No example file found: ${path}")
        }
        [examples: examples, language: language, languages: SortedLanguages.get()]
    }
}
