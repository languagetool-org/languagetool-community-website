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

    private final static int MAXIMUM_CHECK_AGE_IN_MINUTES = 3*60

    def beforeInterceptor = [action: this.&auth, except: ['list', 'index', 'feed']]

    def static allowedMethods = [markAsFixedOrFalseAlarm: 'POST']
    
    def index = {
        redirect(action:list,params:params)
    }

    def list = {
        if(!params.max) params.max = 10
        if(!params.offset) params.offset = 0
        if(!params.notFixedFilter) params.notFixedFilter = "1440"  // default to 24 hours
        String langCode = getLanguageCode()
        Calendar calendar = getCalender()
        int languageMatchCount = FeedMatches.countByLanguageCode(langCode)
        // Grouped Overview of Rule Matches:
        List matchesByRule = getMatchesByRule(calendar, langCode)
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
        List hiddenRuleIds = getHiddenRuleIds(langCode)
        List<FeedMatches> matches = getFeedMatches(calendar, langCode, hiddenRuleIds)
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
                le('editDate', calendar.getTime())
            }
            if (params.categoryFilter) {
                eq('ruleCategory', params.categoryFilter)
            }
            isNull('fixDate')
            eq('languageCode', langCode)
        }
        boolean latestCheckDateWarning = false
        Date latestCheckDate = FeedChecks.findByLanguageCode(langCode)?.checkDate
        if (latestCheckDate) {
            Calendar earliestDateStillOkay = new Date().toCalendar()
            earliestDateStillOkay.add(Calendar.MINUTE, - MAXIMUM_CHECK_AGE_IN_MINUTES)
            latestCheckDateWarning = latestCheckDate.before(earliestDateStillOkay.time)
        }
        Language langObj = Language.getLanguageForShortName(langCode)
        [ languageMatchCount: languageMatchCount, corpusMatchList: matches,
                languages: SortedLanguages.get(), lang: langCode, totalMatches: allMatchesCount,
                matchesByRule: matchesByRule, matchesByCategory: matchesByCategory, hiddenRuleIds: hiddenRuleIds, language: langObj,
                latestCheckDateWarning: latestCheckDateWarning, latestCheckDate: latestCheckDate]
    }

    private String getLanguageCode() {
        String langCode = "en"
        if (params.lang) {
            langCode = params.lang
        }
        return langCode
    }

    private Calendar getCalender() {
        Calendar calendar = Calendar.getInstance()
        if (params.notFixedFilter && params.notFixedFilter != "0") {
            calendar.set(Calendar.MINUTE, calendar.get(Calendar.MINUTE) - Integer.parseInt(params.notFixedFilter))
            calendar.set(Calendar.SECOND, 0)  // minute granularity is enough and enables use of MySQL cache (for a minute at least)
        }
        return calendar
    }

    private List<FeedMatches> getFeedMatches(cal, String langCode, List hiddenRuleIds) {
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
            firstResult(params.int('offset', 0))
            maxResults(params.int('max', 10))
            order('editDate', 'desc')
        }
        return matches
    }

    private List getHiddenRuleIds(String langCode) {
        List hiddenRuleIds = CorpusMatchController.getHiddenRuleIds(langCode, grailsApplication.config.disabledRulesPropFile)
        hiddenRuleIds.addAll(CorpusMatchController.getHiddenRuleIds(langCode, grailsApplication.config.disabledRulesForFeedPropFile))
        hiddenRuleIds
    }

    private List getMatchesByRule(cal, String langCode) {
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
        return matchesByRule
    }

    def feed = {
        Calendar calendar = getCalender()
        String langCode = getLanguageCode()
        Language lang = Language.getLanguageForShortName(langCode)
        List hiddenRuleIds = getHiddenRuleIds(langCode)
        if (params.int('max', 10) > 250) {
            params.max = 250
        }
        List<FeedMatches> matches = getFeedMatches(calendar, langCode, hiddenRuleIds)
        render(feedType:"rss", feedVersion:"2.0") {
            title = "${lang.getName()} Wikipedia Recent Changes Check"
            description = "LanguageTool applied to Wikipedia's recent changed feed"
            link = createLink(controller: 'feedMatches', action: 'list', 
                    params: [lang: lang.getShortName(), notFixedFilter:params.notFixedFilter,
                             categoryFilter:params.categoryFilter, filter:params.filter], absolute: true)
            matches.each { match ->
                def content = match.title.encodeAsHTML() +  "<br/><br/>: " +
                        StringTools.formatError(match.errorContext.encodeAsHTML())
                            .replace(' class="error">', ' class="error"><b>')
                            .replace('</span>', '</b></span>') +
                        " <a href='http://${match.languageCode.encodeAsURL()}.wikipedia.org/w/index.php?title=${match.title.replace(' ', '_').encodeAsURL()}&diff=${match.diffId}'>(diff)</a>" +
                        "<br/><br/>" +
                        match.ruleMessage.replace('<suggestion>', '"').replace('</suggestion>', '"') + "<br/>"
                def url = "http://${lang.getShortName()}.wikipedia.org/wiki/${match.title.replace(' ', '_')}"
                entry(match.ruleDescription) {
                    publishedDate = match.editDate
                    link = createLink(controller: 'wikiCheck', action: 'pageCheck', params: [url: url, enabled: match.ruleId], absolute: true)
                    content
                }
            }
        }
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