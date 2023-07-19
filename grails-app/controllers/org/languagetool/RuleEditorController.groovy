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
import org.languagetool.Language
import org.languagetool.rules.RuleMatch
import org.languagetool.rules.CorrectExample
import org.languagetool.rules.patterns.PatternRule
import org.languagetool.dev.index.SearcherResult
import org.languagetool.rules.patterns.PatternRuleLoader
import org.languagetool.rules.IncorrectExample
import org.languagetool.dev.index.SearchTimeoutException
import org.languagetool.dev.index.Searcher

import java.nio.file.Files
import java.nio.file.Paths
import java.util.regex.Matcher
import java.util.regex.Pattern

/**
 * Editor that helps with creating the XML for simple rules.
 */
class RuleEditorController extends BaseController {

    def searchService

    int EXPERT_MODE_CORPUS_MATCH_LIMIT = 1000

    def index = {
        [languages: Languages.get(), languageNames: getSortedLanguageNames()]
    }

    def expert = {
        [languages: SortedLanguages.get(), languageNames: getSortedLanguageNames()]
    }

    private List getSortedLanguageNames() {
        List languages = Languages.get()
        List languageNames = []
        languages.each { languageNames.add(it.getName()) }
        languageNames.sort()
        return languageNames
    }

    def indexOverview = {
        for (lang in Languages.get()) {
          if (lang.isVariant()) {
            continue
          }
          String indexDirTemplate = grailsApplication.config.fastSearchIndex
          File indexDir = new File(indexDirTemplate.replace("LANG", lang.getShortCode()))
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
        if (params.xml.toUpperCase().contains("!ENTITY")) {
            // just an additional protection against XML external entity attacks
            throw new Exception("Invalid XML input, ENTITY is not allowed")
        }
        Language language
        try {
            language = getLanguage()
        } catch (Exception e) {
            // maybe it's a language code:
            language = Languages.getLanguageForShortCode(params.language)
        }
        PatternRuleLoader loader = new PatternRuleLoader()
        loader.setRelaxedMode(true)
        String userXml = params.xml
        boolean searchMode = false
        if (!userXml.contains("<message")) {
            userXml = userXml.replace("</pattern>", "</pattern>\n<message>fake message</message>")  // fake valid XML
            searchMode = true
        }
        if (!userXml.contains("<example")) {
            userXml = userXml.replace("</message>", "</message>\n<example>fake example</example>")  // fake valid XML
            searchMode = true
        }
        String fakeId = "_some_string_not_in_any_other_rule_1234"
        userXml = userXml.replaceFirst("<rule(.*?)id=['\"](.*?)['\"](.*?)>", "<rule\$1id='\$2${fakeId}'\$3>")  // https://github.com/languagetool-org/languagetool/issues/496
        String orig = userXml
        userXml = userXml.replaceFirst("default=['\"]temp_off['\"]", "")
        boolean isTempOff = !orig.equals(userXml)
        orig = userXml
        userXml = userXml.replaceFirst("default=['\"]off['\"]", "")
        boolean isOff = !orig.equals(userXml)
        userXml = userXml.replaceFirst('tags="([^"]*)picky([^"]*)"', 'tags="$1 $2"')
        userXml = userXml.replaceFirst("tags='([^']*)picky([^']*)'", 'tags="$1 $2"')
        String xmlForEntities = getEntityDefinitions(language)
        int additionalLines = xmlForEntities.split("\n").length
        String xml = xmlForEntities +
                "<rules lang=\"" + language.getShortCode() + "\"><category id=\"fakeId\" name=\"fakeCategory\">" + userXml + "</category></rules>"
        if (params.xml.trim().isEmpty()) {
            render(template: 'checkXmlProblem', model: [error: "No XML found"])
            return
        }
        XMLValidator validator = new XMLValidator()
        String xsd = JLanguageTool.getDataBroker().getRulesDir() + "/rules.xsd"
        try {
            validator.validateStringWithXmlSchema(xml, xsd, null)
        } catch (Exception e) {
            String message = e.getMessage()
            Pattern p = Pattern.compile(".*lineNumber: (\\d+).*")
            Matcher matcher = p.matcher(message)
            if (matcher.matches()) {
                int origLine = Integer.parseInt(matcher.group(1))
                message = message.replaceFirst("lineNumber: \\d+", "lineNumber: " + (origLine-additionalLines))
            }
            render(template: 'checkXmlProblem', model: [error: "XML validation failed: " + message])
            return
        }
        InputStream input = new ByteArrayInputStream(xml.getBytes())
        def rules = loader.getRules(input, "<form>", language)
        if (rules.size() == 0) {
            render(template: 'checkXmlProblem', model: [error: "No rule found in XML"])
            return
        } else if (rules.size() > 1) {
            render(template: 'checkXmlProblem', model: [error: "Found ${rules.size()} rules in XML - please specify only one rule in your XML. " +
                   "Note that '<or>...</or>' internally get expanded into more than one rule."])
            return
        }
        if (!(rules.get(0) instanceof PatternRule)) {
            render(template: 'checkXmlProblem', model: [error: "Sorry, only '<pattern>' rules are supported for now by the online rule editor, not <regexp> rules."])
            return
        }
        PatternRule patternRule = rules.get(0)
        List problems = []
        long startTime = System.currentTimeMillis()
        int timeoutMillis = grailsApplication.config.fastSearchTimeoutMillis
        int corpusMatchLimit = EXPERT_MODE_CORPUS_MATCH_LIMIT
        if (params.devMode == "true") {
            // allow developers to check more sentences
            timeoutMillis = timeoutMillis * 3
        }
        try {
            JLanguageTool lt = getLanguageToolWithOneRule(language, patternRule)
            if (!searchMode) {
                problems.addAll(checkExampleSentences(lt, patternRule, params.checkMarker != 'false'))
                if (problems.size() > 0) {
                    render(template: 'checkRuleProblem', model: [problems: problems, hasRegex: hasRegex(patternRule),
                                 expertMode: true, isOff: isOff, isTempOff: isTempOff, searchMode: searchMode, language: language])
                    return
                }
            }
            String incorrectExamples = getIncorrectExamples(patternRule)
            List<RuleMatch> incorrectExamplesMatches = lt.check(incorrectExamples)

            List<String> incorrectCorrections = []
            for (incorrectExample in patternRule.getIncorrectExamples()) {
                for (correction in incorrectExample.getCorrections()) {
                    String corrected = incorrectExample.getExample().replaceAll("<marker>.*?</marker>", correction)
                    List<RuleMatch> tmpMatches = lt.check(corrected)
                    if (tmpMatches.size() > 0 && !correction.isEmpty()) {
                        incorrectCorrections.addAll(corrected)
                    }
                }
            }
            
            startTime = System.currentTimeMillis()
            int skipDocs = params.skipDocs ? Integer.parseInt(params.skipDocs) : 0
            SearcherResult searcherResult = searchService.checkRuleAgainstCorpus(patternRule, language, skipDocs, corpusMatchLimit, timeoutMillis)
            long searchTime = System.currentTimeMillis() - startTime
            log.info("Checked XML in ${language}, timeout (${timeoutMillis}ms) triggered: ${searcherResult.resultIsTimeLimited}, time: ${searchTime}ms")
            int docsChecked
            int maxDocs
            if (searcherResult.getLuceneMatchCount() != 0) {
                docsChecked = searcherResult.getSkipHits() + searcherResult.getCheckedSentences()
                maxDocs = searcherResult.getLuceneMatchCount()
            } else {
                maxDocs = searcherResult.getNumDocs()
                docsChecked = maxDocs
            }
            render(view: '_corpusResult', model: [searcherResult: searcherResult, expertMode: true, limit: corpusMatchLimit,
                    incorrectExamples: incorrectExamples, incorrectExamplesMatches: incorrectExamplesMatches,
                    incorrectCorrections: incorrectCorrections, docsChecked: docsChecked, maxDocs: maxDocs,
                    isOff: isOff, isTempOff: isTempOff, searchMode: searchMode])
        } catch (SearchTimeoutException ignored) {
            long searchTime = System.currentTimeMillis() - startTime
            log.warn("Timeout checking XML in ${language}, timeout (${timeoutMillis}ms), time: ${searchTime}ms, pattern: ${patternRule}")
            problems.add("Sorry, there was a timeout when searching our Wikipedia data for matches. This can happen" +
                    " for patterns with some regular expressions, for example if the pattern starts with .*." +
                    " These kinds of patterns are currently not supported by this tool.")
            render(template: 'checkRuleProblem', model: [problems: problems, hasRegex: hasRegex(patternRule),
                    expertMode: true, isOff: isOff, isTempOff: isTempOff, searchMode: searchMode, language: language])
        } catch (Exception e) {
            log.error("Error checking XML in ${language}, pattern: ${patternRule}, XML input: ${xml}", e)
            problems.add("Sorry, an error occurred trying to check your rule: ${e.getMessage()}")
            render(template: 'checkRuleProblem', model: [problems: problems, hasRegex: hasRegex(patternRule),
                    expertMode: true, isOff: isOff, isTempOff: isTempOff, searchMode: searchMode, language: language])
        }
    }

    private String getEntityDefinitions(Language lang) {
        //String pathTemplate = "/home/dnaber/lt/git/languagetool/languagetool-language-modules/XX/src/main/resources/org/languagetool/rules/XX/grammar.xml"
        String pathTemplate = grailsApplication.config.grammarPathTemplate
        String filename = pathTemplate.replaceAll("XX", lang.getShortCode())
        def lines = Files.readAllLines(Paths.get(filename))
        boolean inDef = false
        StringBuilder result = new StringBuilder()
        for (String line  : lines) {
            if (line.trim().startsWith("<!DOCTYPE")) {
                inDef = true
            } else if (line.trim().startsWith("]>")) {
                result.append(line).append("\n")
                break
            }
            if (inDef) {
                result.append(line).append("\n")
            }
        }
        return result.toString()
    }

    private List<String> checkExampleSentences(JLanguageTool langTool, PatternRule patternRule, boolean checkMarker) {
        List<CorrectExample> correctExamples = patternRule.getCorrectExamples()
        List<IncorrectExample> incorrectExamples = patternRule.getIncorrectExamples()
        if (incorrectExamples.size() == 0) {
            throw new Exception("No incorrect example sentences found. Use <tt>&lt;example correction='...'&gt;...&lt;/example&gt;</tt>")
        }
        List problems = []
        problems.addAll(checkIncorrectExamples(incorrectExamples, langTool, checkMarker))
        problems.addAll(checkCorrectExamples(correctExamples, langTool))
        return problems
    }

    private List<String> checkIncorrectExamples(List<IncorrectExample> incorrectExamples, JLanguageTool langTool, boolean checkMarker) {
        List problems = []
        AnalysisController analysisController = new AnalysisController()
        for (incorrectExample in incorrectExamples) {
            String sentence = cleanMarkers(incorrectExample.getExample())
            List<AnalyzedSentence> analyzedSentences = langTool.analyzeText(sentence);
            List ruleMatches = []
            for (AnalyzedSentence sent : analyzedSentences) {
                ruleMatches.addAll(langTool.checkAnalyzedSentence(JLanguageTool.ParagraphHandling.NORMAL, langTool.getAllActiveRules(), sent))
            }
            if (ruleMatches.size() == 0) {
                if (incorrectExample.getExample().isEmpty()) {
                    // we accept this (but later display a warning) because it's handy to try some patterns
                    // without setting a sentence just to see the Wikipedia results
                } else {
                    String msg = message(code: 'ltc.editor.error.not.found', args: ['<b>'+sentence+'</b>'], encodeAs: 'None')
                    msg += "<br/>"
                    msg += message(code: 'ltc.editor.error.not.found.analysis')
                    msg += "<br/>"
                    List<AnalyzedSentence> analyzedSentences2 = analysisController.getAnalyzedSentences(sentence, langTool.getLanguage())
                    def analysisStr = g.render(template: '/analysis/analyzeTextForEmbedding', 
                            model: [analyzedSentences: analyzedSentences2, language: langTool.getLanguage(), languages: SortedLanguages.get(),
                            textToCheck: sentence])
                    msg += analysisStr
                    problems.add(msg)
                }
            } else if (ruleMatches.size() == 1) {
                def ruleMatch = ruleMatches.get(0)
                def expectedReplacements = []
                expectedReplacements.addAll(incorrectExample.corrections)
                expectedReplacements.sort()
                if (checkMarker) {
                    int expectedMatchStart = incorrectExample.getExample().indexOf("<marker>")
                    int expectedMatchEnd = incorrectExample.getExample().indexOf("</marker>") - "<marker>".length()
                    if (expectedMatchStart == -1 || expectedMatchEnd == -1) {
                        problems.add(message(code: 'ltc.editor.error.no.marker'))
                        break
                    }
                    if (!ruleMatch.getRule().isWithComplexPhrase()) {
                        if (ruleMatch.getFromPos() != expectedMatchStart) {
                            problems.add(message(code: 'ltc.editor.error.marker.start', args: [incorrectExample.getExample(), expectedMatchStart, ruleMatch.getFromPos()]))
                            break
                        }
                        if (ruleMatch.getToPos() != expectedMatchEnd) {
                            problems.add(message(code: 'ltc.editor.error.marker.end', args: [incorrectExample.getExample(), expectedMatchEnd, ruleMatch.getToPos()]))
                            break
                        }
                    }
                }
                def foundReplacements = new ArrayList<>(ruleMatches.get(0).getSuggestedReplacements())
                foundReplacements.sort()
                if (expectedReplacements.size() > 0 && !expectedReplacements.get(0).isEmpty() && expectedReplacements != foundReplacements) {
                    problems.add(message(code: 'ltc.editor.error.wrong.correction', args: [sentence, foundReplacements, expectedReplacements]))
                }
            } else {
                log.warn("Got ${ruleMatches.size()} matches, expected zero or one: ${incorrectExample}")
            }
        }
        return problems
    }

    private List<String> checkCorrectExamples(List<CorrectExample> correctExamples, JLanguageTool langTool) {
        List problems = []
        for (correctExample in correctExamples) {
            String sentence = cleanMarkers(correctExample.getExample())
            List unexpectedRuleMatches = langTool.check(sentence)
            if (unexpectedRuleMatches.size() > 0) {
                problems.add(message(code: 'ltc.editor.error.unexpected', args: [sentence]))
            }
        }
        return problems
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
            if (!patternRule.getId().equals(rule.getId())) {
                langTool.disableRule(rule.getId())
            }
        }
        langTool.addRule(patternRule)
        return langTool
    }

    private boolean hasRegex(PatternRule patternRule) {
        for (pToken in patternRule.getPatternTokens()) {
            if (pToken.isRegularExpression()) {
                return true
            }
        }
        return false
    }

    private Language getLanguage() {
        Language lang = Languages.getLanguageForName(params.language)
        if (!lang) {
            throw new Exception("No language '${params.language}' found")
        }
        lang
    }

}
