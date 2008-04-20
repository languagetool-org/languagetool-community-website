package org.languagetool

import org.hibernate.*
import de.danielnaber.languagetool.*

class HomepageController extends BaseController {

    SessionFactory sessionFactory       // will be injected automatically
  
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
        SQLQuery q = hibSession.createSQLQuery("SELECT * FROM corpus_match WHERE " +
            "language_code = ? ORDER BY RAND() LIMIT $maxCorpusMatches")
        q.setString(0, langCode)
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
        render(view:'index',model:[matches: matches, langCode: langCode,
                                   languages: Language.REAL_LANGUAGES])
    }

    def checkText = {
        String lang = "en"
        if (params.lang) lang = params.lang
        JLanguageTool lt = new JLanguageTool(Language.getLanguageForShortName(lang))
        lt.activateDefaultPatternRules()
        // TODO: load user configuration
        final int maxTextLen = grailsApplication.config.max.text.length
        final String text = params.text
        if (text.size() > maxTextLen) {
          text = text.substring(0, maxTextLen)
          flash.message = "The text is too long, only the first $maxTextLen characters have been checked"
        }
        List ruleMatches = lt.check(text)
        [matches: ruleMatches, lang: lang, textToCheck: params.text]
    }
    
}
