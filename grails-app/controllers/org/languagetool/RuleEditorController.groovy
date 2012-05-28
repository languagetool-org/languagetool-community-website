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

import org.languagetool.rules.patterns.PatternRule

/**
 * Editor that helps with creating the XML for simple rules.
 */
class RuleEditorController extends BaseController {

    def patternStringConverterService

    def index = {
        List languages = Language.REAL_LANGUAGES
        List languageNames = []
        languages.each { languageNames.add(it.getName()) }
        [languages: Language.REAL_LANGUAGES, languageNames: languageNames.sort()]
    }

    def checkRule = {
        Language language = getLanguage()
        PatternRule patternRule = createPatternRule(language)
        JLanguageTool langTool = getLanguageToolWithOneRule(language, patternRule)
        List expectedRuleMatches = langTool.check(params.incorrectExample1)
        List unexpectedRuleMatches = langTool.check(params.correctExample1)
        List problems = []
        List shortProblems = []
        if (expectedRuleMatches.size() == 0) {
            problems.add("The rule did not find an error in the given example sentence with an error")
            shortProblems.add("errorNotFound")
        }
        if (unexpectedRuleMatches.size() > 0) {
            problems.add("The rule found an error in the given example sentence that is not supposed to contain an error")
            shortProblems.add("unexpectedErrorFound")
        }
        if (problems.size() == 0) {
            log.info("Checked rule: valid - LANG: ${language.getShortName()} - PATTERN: ${params.pattern} - BAD: ${params.incorrectExample1} - GOOD: ${params.correctExample1}")
            [messagePreset: params.messageBackup, namePreset: params.nameBackup]
        } else {
            log.info("Checked rule: invalid - LANG: ${language.getShortName()} - PATTERN: ${params.pattern} - BAD: ${params.incorrectExample1} - GOOD: ${params.correctExample1} - ${shortProblems}")
            render(template: 'checkRuleProblem', model: [problems: problems, hasRegex: hasRegex(patternRule)])
        }
    }

    private JLanguageTool getLanguageToolWithOneRule(Language lang, PatternRule patternRule) {
        JLanguageTool langTool = new JLanguageTool(lang)
        for (rule in langTool.getAllActiveRules()) {
            langTool.disableRule(rule.getId())
        }
        langTool.addRule(patternRule)
        return langTool
    }

    boolean hasRegex(PatternRule patternRule) {
        for (element in patternRule.getElements()) {
            if (element.isRegularExpression()) {
                return true
            }
        }
        return false
    }

    private Language getLanguage() {
        Language lang = Language.getLanguageForName(params.language)
        if (!lang) {
            throw new Exception("No language '${params.language}' found")
        }
        lang
    }

    private PatternRule createPatternRule(Language lang) {
        return patternStringConverterService.convertToPatternRule(params.pattern, lang)
    }

    def createXml = {
        if (!params.message || params.message.trim().isEmpty()) {
            log.info("Create rule XML: missing message parameter")
            [error: "Please fill out the 'Error Message' field"]
        } else {
            log.info("Create rule XML: okay")
            String message = getMessage()
            String correctSentence = params.correctExample1.encodeAsHTML()
            Language language = getLanguage()
            String incorrectSentence = getIncorrectSentenceWithMarker(language)
            String name = params.name ? params.name : "Name of rule"
            String xml = createXml(name, message, incorrectSentence, correctSentence)
            [xml: xml, language: language]
        }
    }

    private String getIncorrectSentenceWithMarker(Language language) {
        PatternRule patternRule = createPatternRule(language)
        JLanguageTool langTool = getLanguageToolWithOneRule(language, patternRule)
        String incorrectSentence = params.incorrectExample1
        List expectedRuleMatches = langTool.check(params.incorrectExample1)
        if (expectedRuleMatches.size() == 1) {
            StringBuilder sb = new StringBuilder(incorrectSentence)
            sb.insert(expectedRuleMatches.get(0).toPos, "</marker>")
            sb.insert(expectedRuleMatches.get(0).fromPos, "<marker>")
            incorrectSentence = sb.toString().encodeAsHTML().replace("&lt;marker&gt;", "<marker>").replace("&lt;/marker&gt;", "</marker>")
        } else {
            throw new Exception("Sorry, got ${expectedRuleMatches.size()} rule matches for the example sentence, " +
                    "expected exactly one. Sentence: '${incorrectSentence}', Rule matches: ${expectedRuleMatches}")
        }
        return incorrectSentence
    }

    private String createXml(String name, String message, String incorrectSentence, String correctSentence) {
        Language lang = getLanguage()
        PatternRule patternRule = createPatternRule(lang)
        String xml = """<rule id="RULE_1" name="${name.encodeAsHTML()}">
    <pattern>\n"""
        for (element in patternRule.getElements()) {
            if (element.isRegularExpression()) {
                xml += "        <token regexp=\"true\">${element.getString()}</token>\n"
            } else {
                xml += "        <token>${element.getString()}</token>\n"
            }
        }
        xml += """    </pattern>
    <message>${message}</message>
    <example type="incorrect">${incorrectSentence}</example>
    <example type="correct">${correctSentence}</example>
</rule>"""
        xml
    }

    private String getMessage() {
        String message = params.message.encodeAsHTML()
        message = message.replaceAll("['\"](.*?)['\"]", "<suggestion>\$1</suggestion>")
        message = message.replaceAll("&quot;(.*?)&quot;", "<suggestion>\$1</suggestion>")
        return message
    }
}
