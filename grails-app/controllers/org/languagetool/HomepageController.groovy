package org.languagetool

import org.hibernate.*
import de.danielnaber.languagetool.Language

class HomepageController extends BaseController {

    SessionFactory sessionFactory       // will be injected automatically
  
    def index = {
        String langCode = "en"
        if (params.lang) {
          langCode = params.lang
        } else {
          params.lang = "en"
        }
        def hibSession = sessionFactory.getCurrentSession()
        SQLQuery q = hibSession.createSQLQuery("SELECT * FROM CorpusMatch WHERE " +
            "languageCode = ? ORDER BY RAND() LIMIT 3")
        q.setString(0, langCode)
        q.addEntity("match", CorpusMatch.class)
        def matches = []
        for (match in q.list()) {
          matches.add((CorpusMatch)match)
        }
        render(view:'index',model:[matches : matches, langCode:langCode,
                                   languages: Language.REAL_LANGUAGES])
    }
    
}
