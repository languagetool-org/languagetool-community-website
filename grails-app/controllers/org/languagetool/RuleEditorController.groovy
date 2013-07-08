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

import org.apache.lucene.store.SimpleFSDirectory
import org.languagetool.rules.RuleMatch
import org.languagetool.rules.patterns.PatternRule
import org.languagetool.dev.index.SearcherResult
import org.languagetool.rules.patterns.PatternRuleLoader
import org.languagetool.rules.IncorrectExample
import org.languagetool.dev.index.SearchTimeoutException
import org.languagetool.dev.index.Searcher

/**
 * Editor that helps with creating the XML for simple rules.
 */
class RuleEditorController extends BaseController {

    def patternStringConverterService
    def searchService

    int CORPUS_MATCH_LIMIT = 20
    int EXPERT_MODE_CORPUS_MATCH_LIMIT = 100

    def index = {
        List languageNames = getLanguageNames()
        [languages: Language.REAL_LANGUAGES, languageNames: languageNames.sort()]
    }

    def expert = {
        List languageNames = getLanguageNames()
        [languages: Language.REAL_LANGUAGES, languageNames: languageNames.sort()]
    }

    private List getLanguageNames() {
        List languages = Language.REAL_LANGUAGES
        List languageNames = []
        languages.each { languageNames.add(it.getName()) }
        languageNames
    }

    def checkRule = {
        Language language = getLanguage()
        PatternRule patternRule = createPatternRule(language)
        List problems = []
        List shortProblems = []
        JLanguageTool langTool = getLanguageToolWithOneRule(language, patternRule)
        checkExampleSentences(langTool, patternRule, problems, shortProblems, false)
        if (problems.size() == 0) {
          SearcherResult searcherResult = null
          boolean timeOut = false
          try {
              searcherResult = searchService.checkRuleAgainstCorpus(patternRule, language, CORPUS_MATCH_LIMIT)
          } catch (SearchTimeoutException e) {
              log.info("Timeout exception: " + e + " - LANG: ${language.getShortNameWithVariant()} - PATTERN: ${params.pattern}")
              timeOut = true
          }
          log.info("Checked rule: valid - LANG: ${language.getShortNameWithVariant()} - PATTERN: ${params.pattern} - BAD: ${params.incorrectExample1} - GOOD: ${params.correctExample1}")
          [messagePreset: params.messageBackup, namePreset: params.nameBackup,
                  searcherResult: searcherResult, limit: CORPUS_MATCH_LIMIT, timeOut: timeOut]
        } else {
            log.info("Checked rule: invalid - LANG: ${language.getShortNameWithVariant()} - PATTERN: ${params.pattern} - BAD: ${params.incorrectExample1} - GOOD: ${params.correctExample1} - ${shortProblems}")
            render(template: 'checkRuleProblem', model: [problems: problems, hasRegex: hasRegex(patternRule), expertMode: false])
        }
    }

    def indexOverview = {
        for (lang in Language.REAL_LANGUAGES) {
          if (lang.isVariant()) {
            continue
          }
          String indexDirTemplate = grailsApplication.config.fastSearchIndex
          File indexDir = new File(indexDirTemplate.replace("LANG", lang.getShortName()))
          if (indexDir.isDirectory()) {
            def directory = SimpleFSDirectory.open(indexDir)
            try {
              Searcher searcher = new Searcher(directory)
              render "${lang}: ${formatNumber(number:searcher.getDocCount(), type: 'number')} docs<br/>"
            } finally {
              directory.close()
            }
          } else {
            render "No index found: ${lang}<br/>"
          }
      }
    }

    def checkXml = {
        Language language = getLanguage()
        PatternRuleLoader loader = new PatternRuleLoader()
        loader.setRelaxedMode(true)
        String xml = "<rules lang=\"" + language.getShortName() + "\"><category name=\"fakeCategory\">" + params.xml + "</category></rules>"
        if (xml.trim().isEmpty()) {
            render(template: 'checkXmlProblem', model: [error: "No XML found"])
            return
        }
        xml = xml.replaceAll("&([a-zA-Z]+);", "&amp;\$1;")  // entities otherwise lead to an error
        final InputStream input = new ByteArrayInputStream(xml.getBytes())
        def rules = loader.getRules(input, "<form>")
        if (rules.size() == 0) {
            render(template: 'checkXmlProblem', model: [error: "No rule found in XML"])
            return
        } else if (rules.size() > 1) {
            render(template: 'checkXmlProblem', model: [error: "Found ${rules.size()} rules in XML - please specify only one rule in your XML"])
            return
        }
        PatternRule patternRule = rules.get(0)
        List problems = []
        List shortProblems = []
        JLanguageTool langTool = getLanguageToolWithOneRule(language, patternRule)
        checkExampleSentences(langTool, patternRule, problems, shortProblems, true)
        if (problems.size() > 0) {
            render(template: 'checkRuleProblem', model: [problems: problems, hasRegex: hasRegex(patternRule),
                    expertMode: true, isOff: patternRule.isDefaultOff()])
            return
        }
        String incorrectExamples = getIncorrectExamples(patternRule)
        List<RuleMatch> incorrectExamplesMatches = langTool.check(incorrectExamples)
        int timeoutMillis = grailsApplication.config.fastSearchTimeoutMillis
        long startTime = System.currentTimeMillis()
        try {
            SearcherResult searcherResult = searchService.checkRuleAgainstCorpus(patternRule, language, EXPERT_MODE_CORPUS_MATCH_LIMIT)
            long searchTime = System.currentTimeMillis() - startTime
            log.info("Checked XML in ${language}, timeout (${timeoutMillis}ms) triggered: ${searcherResult.resultIsTimeLimited}, time: ${searchTime}ms")
            render(view: '_corpusResult', model: [searcherResult: searcherResult, expertMode: true, limit: EXPERT_MODE_CORPUS_MATCH_LIMIT,
                    incorrectExamples: incorrectExamples, incorrectExamplesMatches: incorrectExamplesMatches])
        } catch (SearchTimeoutException ignored) {
            long searchTime = System.currentTimeMillis() - startTime
            log.warn("Timeout checking XML in ${language}, timeout (${timeoutMillis}ms), time: ${searchTime}ms, pattern: ${patternRule}")
            problems.add("Sorry, there was a timeout when searching our Wikipedia data for matches. This can happen" +
                    " for patterns with some regular expressions, for example if the pattern starts with .*." +
                    " These kinds of patterns are currently not supported by this tool.")
            render(template: 'checkRuleProblem', model: [problems: problems, hasRegex: hasRegex(patternRule),
                    expertMode: true, isOff: patternRule.isDefaultOff()])
            return
        }
    }

    private void checkExampleSentences(JLanguageTool langTool, PatternRule patternRule, List problems, List shortProblems, boolean checkMarker) {
        List<String> correctExamples = patternRule.getCorrectExamples()
        if (correctExamples.size() == 0) {
            throw new Exception("No correct example sentences found")
        }
        List<IncorrectExample> incorrectExamples = patternRule.getIncorrectExamples()
        if (incorrectExamples.size() == 0) {
            throw new Exception("No incorrect example sentences found")
        }
        for (incorrectExample in incorrectExamples) {
            String sentence = cleanMarkers(incorrectExample.getExample())
            List ruleMatches = langTool.check(sentence)
            if (ruleMatches.size() == 0) {
                problems.add("The rule did not find the expected error in '${sentence}'")
                shortProblems.add("errorNotFound")
            } else if (ruleMatches.size() == 1) {
                def ruleMatch = ruleMatches.get(0)
                def expectedReplacements = incorrectExample.corrections.sort()
                if (checkMarker) {
                    int expectedMatchStart = incorrectExample.getExample().indexOf("<marker>")
                    int expectedMatchEnd = incorrectExample.getExample().indexOf("</marker>") - "<marker>".length()
                    if (expectedMatchStart == -1 || expectedMatchEnd == -1) {
                        problems.add("No <marker> found in incorrect example sentence")
                        break
                    }
                    if (!ruleMatch.getRule().isWithComplexPhrase()) {
                        if (ruleMatch.getFromPos() != expectedMatchStart) {
                            problems.add("Unexpected start position of <marker>...</marker> in incorrect example sentence: " + expectedMatchStart +  " but expected " + ruleMatch.getFromPos())
                            break
                        }
                        if (ruleMatch.getToPos() != expectedMatchEnd) {
                            problems.add("Unexpected end position of <marker>...</marker> in incorrect example sentence: " + expectedMatchEnd +  " but expected " + ruleMatch.getToPos())
                            break
                        }
                    }
                }
                def foundReplacements = ruleMatches.get(0).getSuggestedReplacements().sort()
                if (expectedReplacements.size() > 0 && expectedReplacements != foundReplacements) {
                    problems.add("Found wrong correction(s) in '${sentence}: '${foundReplacements}' but expected '${expectedReplacements}'")
                    shortProblems.add("wrongCorrection")
                }
            } else {
                log.warn("Got ${ruleMatches.size()} matches, expected zero or one: ${incorrectExample}")
            }
        }
        for (correctExample in correctExamples) {
            String sentence = cleanMarkers(correctExample)
            List unexpectedRuleMatches = langTool.check(sentence)
            if (unexpectedRuleMatches.size() > 0) {
                problems.add("The rule found an unexpected error in '${sentence}'")
                shortProblems.add("unexpectedErrorFound")
            }
        }
    }

    private String getIncorrectExamples(PatternRule patternRule) {
        List<IncorrectExample> incorrectExamples = patternRule.getIncorrectExamples()
        StringBuilder examples = new StringBuilder()
        for (incorrectExample in incorrectExamples) {
            String sentence = cleanMarkers(incorrectExample.getExample())
            examples.append(sentence)
            examples.append("\n")
        }
        return examples
    }

    private String cleanMarkers(String message) {
        return message.replace("<marker>", "").replace("</marker>", "")
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
        PatternRule patternRule = patternStringConverterService.convertToPatternRule(params.pattern, lang)
        patternRule.setCorrectExamples(Collections.<String>singletonList(params.correctExample1))
        def incorrectExample = new IncorrectExample(params.incorrectExample1)
        patternRule.setIncorrectExamples(Collections.singletonList(incorrectExample))
        return patternRule
    }

    def createXml = {
        if (!params.message || params.message.trim().isEmpty()) {
            log.info("Create rule XML: missing message parameter")
            [error: "Please fill out the 'Error Message' field"]
        } else {
            log.info("Create rule XML: okay")
            String message = getMessage()
            String correctSentence = encodeXml(params.correctExample1)
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
            incorrectSentence = encodeXml(sb.toString()).replace("&lt;marker&gt;", "<marker>").replace("&lt;/marker&gt;", "</marker>")
        } else {
            throw new Exception("Sorry, got ${expectedRuleMatches.size()} rule matches for the example sentence, " +
                    "expected exactly one. Sentence: '${incorrectSentence}', Rule matches: ${expectedRuleMatches}")
        }
        return incorrectSentence
    }

    private encodeXml(String s) {
        return s.replace("<string>", "").replace("</string>", "")
    }

    private String createXml(String name, String message, String incorrectSentence, String correctSentence) {
        Language lang = getLanguage()
        PatternRule patternRule = createPatternRule(lang)
        String ruleId = createRuleIdFromName(name)
        String xml = """<rule id="${encodeXml(ruleId)}" name="${encodeXml(name)}">
    <pattern>\n"""
        for (element in patternRule.getElements()) {
            if (element.isRegularExpression()) {
                xml += "        <token regexp=\"yes\">${element.getString()}</token>\n"
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

    String createRuleIdFromName(String name) {
        return name.toUpperCase().replaceAll("[\\s/]+", "_").replaceAll("[^A-Z_]", "")
    }

    private String getMessage() {
        String message = encodeXml(params.message)
        message = message.replaceAll("\"(.*?)\"", "<suggestion>\$1</suggestion>")
        message = message.replaceAll("&quot;(.*?)&quot;", "<suggestion>\$1</suggestion>")
        return message
    }
}
