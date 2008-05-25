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

import org.hibernate.*
import de.danielnaber.languagetool.*

/**
 * The main page of the website.
 */
class HomepageController extends BaseController {

    SessionFactory sessionFactory       // will be injected automatically
  
    /**
     * Display the site's main page.
     */
    def index = {
        request.setCharacterEncoding("UTF-8")
        response.setCharacterEncoding("UTF-8")
        String langCode = "en"
        if (params.lang) {
          langCode = params.lang
        } else {
          params.lang = "en"
        }
        def hibSession = sessionFactory.getCurrentSession()
        final int maxCorpusMatches = 3
        SQLQuery q
        if (params.ids) {
          // user logged in specifically to vote, we don't show random
          // items in this case:
          q = hibSession.createSQLQuery("SELECT * FROM corpus_match WHERE " +
            "language_code = ? AND (id = ? OR id = ? OR id = ?) LIMIT $maxCorpusMatches")
          q.setString(0, langCode)
          String[] lastShownIds = params.ids.split(",")
          int i = 1
          for (String id in lastShownIds) {
            q.setString(i, id)
            i++
          }
        } else {
          q = hibSession.createSQLQuery("SELECT * FROM corpus_match WHERE " +
            "language_code = ? AND is_visible = 1 ORDER BY RAND() LIMIT $maxCorpusMatches")
          q.setString(0, langCode)
        }
        q.addEntity("match", CorpusMatch.class)
        def matches = []
        for (match in q.list()) {
          CorpusMatchInfo cmi = new CorpusMatchInfo((CorpusMatch)match)
          if (session.user) {
            UserOpinion opinion = UserOpinion.findByUserAndCorpusMatch(session.user, match)
            if (opinion) {
              cmi.opinion = opinion.opinion
            }
          }
          matches.add(cmi)
        }
        // force some order so we show the same order again as before login
        // (people might log in specifically to vote, we don't show random
        // items in that case):
        Collections.sort(matches)
        render(view:'index',model:[matches: matches, langCode: langCode,
                                   languages: Language.REAL_LANGUAGES])
    }

    /**
     * Run the grammar checker on the given text.
     */
    def checkText = {
        String lang = "en"
        if (params.lang) lang = params.lang
        JLanguageTool lt = new JLanguageTool(Language.getLanguageForShortName(lang))
        lt.activateDefaultPatternRules()
        // load user configuration:
        LanguageConfiguration langConfig = null
        if (session.user) {
          langConfig = RuleController.getLangConfigforUser(lang, session)
          if (langConfig) {
            for (disRule in langConfig.disabledRules) {
              lt.disableRule(disRule.ruleID)
            }
          }
        }
        final int maxTextLen = grailsApplication.config.max.text.length
        final String text = params.text
        if (text.size() > maxTextLen) {
          text = text.substring(0, maxTextLen)
          flash.message = "The text is too long, only the first $maxTextLen characters have been checked"
        }
        List ruleMatches = lt.check(text)
        // TODO: count only disabledRules for the current language
        [matches: ruleMatches, lang: lang, textToCheck: params.text,
           disabledRules: langConfig?.disabledRules]
    }
    
}
