/* LanguageTool Community 
 * Copyright (C) 2016 Daniel Naber (http://www.danielnaber.de)
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

import org.languagetool.rules.*
import org.languagetool.rules.ngrams.ConfusionProbabilityRule

/**
 * Get information about error rules as JSON.
 */
class RuleApiController extends BaseController {

    /*def beforeInterceptor = {
        header("Access-Control-Allow-Origin", "*")
        header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
    }*/

    def exampleSentences() {
        if (!params.lang) {
            throw new RuntimeException("'lang' parameter missing")
        }
        if (!params.ruleId) {
            throw new RuntimeException("'ruleId' parameter missing")
        }
        Language lang = Languages.getLanguageForShortCode(params.lang)
        JLanguageTool lt = new JLanguageTool(lang)
        String ngramDir = grailsApplication.config.ngramindex
        // save quite some memory if confusion rule is not needed:
        if (ngramDir && params.ruleId == ConfusionProbabilityRule.RULE_ID) {
            lt.activateLanguageModelRules(new File(ngramDir))
        }
        List<Rule> rules = lt.getAllRules()
        List<Rule> foundRules = []
        for (Rule rule : rules) {
            if (rule.getId() == params.ruleId) {
                foundRules.add(rule)
            }
        }
        if (foundRules.size() == 0) {
            throw new RuntimeException("Rule '" + params.ruleId + "' not found for language " + lang +
                    " (LanguageTool version/date: " + JLanguageTool.VERSION + "/" + JLanguageTool.BUILD_DATE + ", total rules of language: " + rules.size() + ")")
        }

        List<Map> result = []
        result.add([warning: '*** This is not a public API - it may change anytime ***'])
        for (Rule foundRule : foundRules) {
            for (CorrectExample example : foundRule.getCorrectExamples()) {
                Map<String,String> subMap = new HashMap<>()
                subMap.put("status", "correct")
                subMap.put("sentence", example.getExample())
                result.add(subMap)
            }
            for (IncorrectExample example : foundRule.getIncorrectExamples()) {
                Map subMap = new HashMap()
                subMap.put("status", "incorrect")
                subMap.put("sentence", example.example)
                subMap.put("corrections", example.corrections)
                result.add(subMap)
            }
        }

        response.setHeader("Access-Control-Allow-Origin", "*")
        render(contentType: 'text/json') {
            results = result
        }
    }
    
}
