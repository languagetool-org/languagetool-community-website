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
 * User voting on errors detected in a text corpus.
 */
class CorpusMatchController extends BaseController {

    /**
     * User finds the error detection wrong or useless.
     */
    public final static int NEGATIVE_OPINION = 0
    /**
     * User finds the error detection wrong or useful.
     */
    public final static int POSITIVE_OPINION = 1

    def beforeInterceptor = [action: this.&auth, except: ['list', 'index']]

    def static allowedMethods = [markUseful:'POST', markUseless:'POST']

    def index = {
        redirect(action:list,params:params)
    }

    def list = {
        if(!params.max) params.max = 10
        if(!params.offset) params.offset = 0
        String langCode = "en"
        if (params.lang) {
            langCode = params.lang
        }
        // Grouped Overview of Rule Matches:
        def matchByRuleCriteria = CorpusMatch.createCriteria()
        def matchesByRule = matchByRuleCriteria {
            eq('languageCode', langCode)
            eq('isVisible', true)
            projections {
                groupProperty("ruleID")
                count "ruleID", 'mycount'
            }
            order 'mycount', 'desc'
        }
        // Rule Matches for this language:
        def matchCriteria = CorpusMatch.createCriteria()
        def matches = matchCriteria {
            if (params.filter) {
                eq('ruleID', params.filter)
            }
            eq('languageCode', langCode)
            eq('isVisible', true)
            firstResult(params.int('offset'))
            maxResults(params.int('max'))
        }
        def allMatchesCriteria = CorpusMatch.createCriteria()
        def allMatchesCount = allMatchesCriteria.count {
            if (params.filter) {
                eq('ruleID', params.filter)
            }
            eq('languageCode', langCode)
            eq('isVisible', true)
        }
        Language langObj = Language.getLanguageForShortName(langCode)
        [ corpusMatchList: matches,
                languages: Language.REAL_LANGUAGES, lang: langCode, totalMatches: allMatchesCount,
                matchesByRule: matchesByRule, language: langObj]
    }

    def markUseful = {
        saveOpinion(session.user, POSITIVE_OPINION)
        render(text:message(code:'ltc.voted.useful'), contentType: "text/html", encoding:"UTF-8")
    }

    def markUseless = {
        saveOpinion(session.user, NEGATIVE_OPINION)
        render(text:message(code:'ltc.voted.useless'), contentType: "text/html", encoding:"UTF-8")
    }

    private void saveOpinion(User user, int opinionValue) {
        // TODO: avoid duplicate opinions
        CorpusMatch corpusMatch = CorpusMatch.get(params.id)
        assert(corpusMatch)
        UserOpinion opinion = new UserOpinion(session.user, corpusMatch, opinionValue)
        if (!opinion.save()) {
            throw new Exception("Could not save user opinion: ${opinion.errors}")
        }
    }

}