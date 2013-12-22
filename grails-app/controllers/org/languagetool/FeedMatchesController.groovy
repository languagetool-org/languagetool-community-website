/* LanguageTool Community 
 * Copyright (C) 2013 Daniel Naber (http://www.danielnaber.de)
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

class FeedMatchesController extends BaseController {

    def beforeInterceptor = [action: this.&auth, except: ['list', 'index']]

    def static allowedMethods = [markAsFixedOrFalseAlarm: 'POST']
    
    def index = {
        redirect(action:list,params:params)
    }

    def list = {
        if(!params.max) params.max = 10
        if(!params.offset) params.offset = 0
        if(!params.notFixedFilter) params.notFixedFilter = "1440"  // default to 24 hours
        String langCode = "en"
        if (params.lang) {
            langCode = params.lang
        }
        Calendar cal = Calendar.getInstance()
        if (params.notFixedFilter && params.notFixedFilter != "0") {
            cal.set(Calendar.MINUTE, cal.get(Calendar.MINUTE) - Integer.parseInt(params.notFixedFilter))
        }
        int languageMatchCount = FeedMatches.countByLanguageCode(langCode)
        // Grouped Overview of Rule Matches:
        def matchByRuleCriteria = FeedMatches.createCriteria()
        def matchesByRule = matchByRuleCriteria {
            // fixDate = null: neither fixed in Wikipedia (then it would also have the fixDiffId set) 
            // nor marked as 'fixed or false alarm' by a user (then it wouldn't have fixDiffId set either):
            isNull('fixDate')
            eq('languageCode', langCode)
            if (params.notFixedFilter && params.notFixedFilter != "0") {
                le('editDate', cal.getTime())
            }
            if (params.categoryFilter) {
                eq('ruleCategory', params.categoryFilter)
            }
            projections {
                groupProperty("ruleId")
                count "ruleId", 'mycount'
                property("ruleDescription")
            }
            order 'mycount', 'desc'
        }
        def matchByCategoryCriteria = FeedMatches.createCriteria()
        def matchesByCategory = matchByCategoryCriteria {
            isNull('fixDate')
            eq('languageCode', langCode)
            projections {
                groupProperty("ruleCategory")
                count "ruleCategory", 'mycount'
                property("ruleCategory")
            }
            order 'mycount', 'desc'
        }
        // Rule Matches for this language:
        List hiddenRuleIds = CorpusMatchController.getHiddenRuleIds(langCode, grailsApplication.config.disabledRulesPropFile)
        hiddenRuleIds.addAll(CorpusMatchController.getHiddenRuleIds(langCode, grailsApplication.config.disabledRulesForFeedPropFile))
        def matchCriteria = FeedMatches.createCriteria()
        def matches = matchCriteria {
            if (params.filter) {
                eq('ruleId', params.filter)
            } else {
                not {
                    inList('ruleId', hiddenRuleIds)
                }
            }
            if (params.notFixedFilter && params.notFixedFilter != "0") {
                le('editDate', cal.getTime())
            }
            if (params.categoryFilter) {
                eq('ruleCategory', params.categoryFilter)
            }
            isNull('fixDate')
            eq('languageCode', langCode)
            firstResult(params.int('offset'))
            maxResults(params.int('max'))
            order('editDate', 'desc')
        }
        def allMatchesCriteria = FeedMatches.createCriteria()
        def allMatchesCount = allMatchesCriteria.count {
            if (params.filter) {
                eq('ruleId', params.filter)
            } else {
                not {
                    inList('ruleId', hiddenRuleIds)
                }
            }
            if (params.notFixedFilter && params.notFixedFilter != "0") {
                le('editDate', cal.getTime())
            }
            if (params.categoryFilter) {
                eq('ruleCategory', params.categoryFilter)
            }
            isNull('fixDate')
            eq('languageCode', langCode)
        }
        Language langObj = Language.getLanguageForShortName(langCode)
        [ languageMatchCount: languageMatchCount, corpusMatchList: matches,
                languages: SortedLanguages.get(), lang: langCode, totalMatches: allMatchesCount,
                matchesByRule: matchesByRule, matchesByCategory: matchesByCategory, hiddenRuleIds: hiddenRuleIds, language: langObj]
    }

    // called via Ajax
    def markAsFixedOrFalseAlarm = {
        FeedMatches match = FeedMatches.get(params.id)
        if (!match) {
            throw new Exception("Feed match id #${params.id} not found")
        }
        match.fixDate = new Date()
        match.save(failOnError: true)
        log.info("User ${session.user.username} has marked feed match #${params.id} as 'fixed or false alarm'")
        render "ok"
    }
}