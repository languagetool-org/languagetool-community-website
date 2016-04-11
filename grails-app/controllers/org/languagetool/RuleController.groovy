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

import org.languagetool.remote.CheckConfiguration
import org.languagetool.remote.CheckConfigurationBuilder
import org.languagetool.remote.RemoteLanguageTool
import org.languagetool.remote.RemoteResult
import org.languagetool.rules.*
import org.languagetool.rules.patterns.*

/**
 * Display error rules.
 */
class RuleController extends BaseController {

    def index = { redirect(action:list,params:params) }

    def list = {
        int max = 10
        int offset = 0
        if (!params.lang) params.lang = "en"
        if (params.offset) offset = Integer.parseInt(params.offset)
        if (params.max) max = Integer.parseInt(params.max)
        String langCode = getLanguageCode()
        Language langObj = Languages.getLanguageForShortName(langCode)
        JLanguageTool lt = new JLanguageTool(langObj)
        List<Rule> rules = lt.getAllRules()
        List<String> categories = getCategories(rules)
        if (params.filter || params.categoryFilter) {
            rules = filterRules(rules, params.filter, params.categoryFilter)
        }
        if (params.sort) {
            def sortF = SortField.pattern
            if (params.sort == 'description') sortF = SortField.description
            if (params.sort == 'category') sortF = SortField.category
            Collections.sort(rules, new RuleComparator(sortF,
                    params.order == 'desc' ? SortDirection.desc : SortDirection.asc));
        }
        int ruleCount = rules.size()
        if (ruleCount == 0) {
            rules = []
        } else {
            rules = rules[offset..Math.min(rules.size()-1, offset+max-1)]
        }
        [ruleList: rules, ruleCount: ruleCount, languages: SortedLanguages.get(), language: langObj,
                categories: categories, categoryFilter: params.categoryFilter]
    }

    private List<String> getCategories(List<Rule> rules) {
        Set<String> categorySet = new HashSet()
        for (rule in rules) {
            categorySet.add(rule.getCategory().getName())
        }
        List<String> categories = new ArrayList(categorySet)
        Collections.sort(categories)
        return categories
    }

    private filterRules(List rules, String filter, String categoryFilter) {
        filter = filter.toLowerCase()
        List filtered = []
        for (rule in rules) {
            String catName = rule.category.name.toLowerCase()
            if (categoryFilter && !catName.equalsIgnoreCase(categoryFilter)) {
                continue
            }
            // match pattern:
            if (rule instanceof PatternRule) {
                PatternRule pRule = (PatternRule)rule
                if (pRule.toPatternString().toLowerCase().contains(filter)) {
                    filtered.add(rule)
                    continue
                }
            }
            // match description or id:
            if (rule.description.toLowerCase().contains(filter) || rule.id.toLowerCase() == filter) {
                filtered.add(rule)
                continue
            }
            // match category:
            if (catName.contains(filter)) {
                filtered.add(rule)
            }
        }
        return filtered
    }

    /**
     * Check a given text with a single rule.
     */
    def checkTextWithRule = {
        // get all information needed to display "show" page:
        String langCode = "en"
        if (params.lang) langCode = params.lang
        Language langObj = Languages.getLanguageForShortName(langCode)
        JLanguageTool lt = new JLanguageTool(langObj)
        Rule selectedRule = getSystemRuleById(params.id, params.subId, lt)
        if (!selectedRule) {
            flash.message = "No rule with id ${params.id.encodeAsHTML()}"
            redirect(action:list)
        }
        // now actually check the text using remote server (to save memory in this process):
        String text = params.text
        int maxTextLen = grailsApplication.config.max.text.length
        if (text.size() > maxTextLen) {
            text = text.substring(0, maxTextLen)
            flash.message = "The text is too long, only the first $maxTextLen characters have been checked"
        }
        CheckConfiguration config = new CheckConfigurationBuilder(langCode).enabledRuleIds(params.id).enabledOnly().build()
        RemoteLanguageTool remoteLt = new RemoteLanguageTool(new URL(grailsApplication.config.api.server.url))
        RemoteResult result = remoteLt.check(text, config)
        render(view:'show', model: [ hideRuleLink: true, rule: selectedRule,
                textToCheck: params.text, matches: result.getMatches(), ruleId: params.id, language: langObj],
                contentType: "text/html", encoding: "utf-8")
    }

    def show = {
        String langCode = getLanguageCode()
        Language langObj = Languages.getLanguageForShortName(langCode)
        Rule selectedRule = getRuleById(params.id, params.subId, langCode)
        if (!selectedRule) {
            log.warn("No rule with id ${params.id}, subId ${params.subId} and language ${langCode}")
            flash.message = "No rule with id ${params.id.encodeAsHTML()}, subId ${params.subId.encodeAsHTML()}"
            redirect(action:list)
            return
        }
        String textToCheck = ""
        if (params.textToCheck) {
            textToCheck = params.textToCheck
        }
        String ruleSubId = null
        if (selectedRule instanceof PatternRule) {
            ruleSubId = ((PatternRule)selectedRule).getSubId()
        }
        render(view:'show', model: [rule: selectedRule, ruleSubId: ruleSubId,
                ruleId: params.id, textToCheck: textToCheck, language: langObj],
                contentType: "text/html", encoding: "utf-8")
    }

    def showRuleXml = {
        String langCode = getLanguageCode()
        Language language = Languages.getLanguageForShortName(langCode)
        PatternRuleId id = params.subId ? new PatternRuleId(params.id, params.subId) : new PatternRuleId(params.id)
        PatternRuleXmlCreator ruleXmlCreator = new PatternRuleXmlCreator()
        String ruleAsXml = ruleXmlCreator.toXML(id, language)
        render(template: 'xml', model: [ruleAsXml: ruleAsXml, language: language])
    }

    private String getLanguageCode() {
        String lang = "en"
        if (params.lang) {
            lang = params.lang
        }
        assert(lang)
        return lang
    }

    private Rule getRuleById(String id, String subId, String lang) {
        JLanguageTool lt = new JLanguageTool(Languages.getLanguageForShortName(lang))
        // ngram rule is not listed anyway, so we don't need to get it here either (and save quite some memory):
        /*String ngramDir = grailsApplication.config.ngramindex
        if (ngramDir) {
            lt.activateLanguageModelRules(new File(ngramDir))
        }*/
        return getSystemRuleById(id, subId, lt)
    }

    private Rule getSystemRuleById(String id, String subId, JLanguageTool lt) {
        log.debug("Getting system rule with id '$id'")
        Rule selectedRule = null
        List rules = lt.getAllRules()
        for (Rule rule in rules) {
            boolean subIdMatchIfNeeded = true
            if (rule instanceof PatternRule && subId != null) {
                PatternRule pRule = (PatternRule) rule
                subIdMatchIfNeeded = pRule.subId == subId
            }
            if (rule.id == params.id && subIdMatchIfNeeded) {
                selectedRule = rule
                break
            }
        }
        return selectedRule
    }

}
