package org.languagetool

import java.sql.DriverManager
import java.sql.ResultSet
import java.sql.Connection
import java.sql.ResultSet
import java.sql.Statement
import org.hibernate.*

/**
 * Show simple statistics about UserOpinions.
 */
class EvaluationController extends BaseController {
    
    def dataSource       // will be injected
    SessionFactory sessionFactory       // will be injected automatically
  
    def index = {
      // TODO: use UserOpinion.withCriteria
      def hibSession = sessionFactory.getCurrentSession()
      Connection conn = dataSource.getConnection()
      Statement st = conn.createStatement()
      ResultSet rs = st.executeQuery("""SELECT corpus_match_id,
          count(*) AS count FROM user_opinion
          WHERE opinion = ${CorpusMatchController.NEGATIVE_OPINION}
          GROUP BY user_opinion.corpus_match_id
          ORDER by count DESC""")
      List results = []
      while (rs.next()) {
        OpinionResult or = new OpinionResult(counter:rs.getInt("count"),
            ruleId:rs.getInt("corpus_match_id"))
        results.add(or)
      }
      [results: results]
    }

}

class OpinionResult {
    int counter
    int ruleId
}
