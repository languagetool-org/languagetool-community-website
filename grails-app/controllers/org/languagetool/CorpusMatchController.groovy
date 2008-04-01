package org.languagetool

import javax.mail.*
import javax.mail.internet.*

class CorpusMatchController extends BaseController {
    
    private final static int NEGATIVE_OPINION = 0
    private final static int POSITIVE_OPINION = 1
    
    def beforeInterceptor = [action: this.&auth, except: []]

    // the delete, save and update actions only accept POST requests
    //FIXME:
    //def allowedMethods = [markUseful:'POST', markUseless:'POST']

    def markUseful = {
      saveOpinion(session.user, POSITIVE_OPINION)
      render "opinion saved"
    }

    def markUseless = {
      saveOpinion(session.user, NEGATIVE_OPINION)
      render "opinion saved"
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