package org.languagetool

import org.hibernate.*
import de.danielnaber.languagetool.Language

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
    
}
