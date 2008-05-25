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

import de.danielnaber.languagetool.*
import java.sql.DriverManager
import java.sql.ResultSet
import java.sql.Connection
import java.sql.ResultSet
import java.sql.Statement
import org.hibernate.*

/**
 * Overview of votes submitted by users.
 */
class UserOpinionController extends BaseController {
    
    def dataSource       // will be injected
    SessionFactory sessionFactory       // will be injected automatically

    def index = {
      redirect(action:list,params:params)
    }

    def list = {
      // TODO: use UserOpinion.withCriteria
      def hibSession = sessionFactory.getCurrentSession()
      Connection conn = dataSource.getConnection()
      Statement st = conn.createStatement()
      String langCode = "en"
      if (params.lang) {
          langCode = params.lang
      }
      Language testLang = Language.getLanguageForShortName(langCode)
      if (!testLang) {
        throw new Exception("unknown language")
      }
      String sql = """SELECT corpus_match_id,
        count(*) AS count FROM user_opinion, corpus_match
        WHERE
          user_opinion.corpus_match_id = corpus_match.id AND
          opinion = ${CorpusMatchController.NEGATIVE_OPINION} AND
          corpus_match.language_code = '${langCode}'
        GROUP BY user_opinion.corpus_match_id
        ORDER by count DESC"""
      ResultSet rs = st.executeQuery(sql)
      List results = []
      while (rs.next()) {
        OpinionResult or = new OpinionResult(counter:rs.getInt("count"),
            corpusMatch:CorpusMatch.get(rs.getInt("corpus_match_id")))
        results.add(or)
      }
      [results: results, languages: Language.REAL_LANGUAGES]
    }

}

class OpinionResult {
  int counter
  CorpusMatch corpusMatch
}
