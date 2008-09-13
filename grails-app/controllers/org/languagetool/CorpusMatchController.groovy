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

import javax.mail.*
import javax.mail.internet.*
import de.danielnaber.languagetool.*

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

    def allowedMethods = [markUseful:'POST', markUseless:'POST']

    def index = {
      redirect(action:list,params:params)
    }

    def list = {
      if(!params.max) params.max = 10
      String langCode = "en"
      if (params.lang) {
          langCode = params.lang
      }
      [ corpusMatchList: CorpusMatch.findAllByLanguageCodeAndIsVisible(langCode, true, params),
        languages: Language.REAL_LANGUAGES ]
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
      //TODO: add performance debugging
      long t = System.currentTimeMillis()
      CorpusMatch corpusMatch = CorpusMatch.get(params.id)
      log.info("save opinion get: ${System.currentTimeMillis()-t}ms")
      t = System.currentTimeMillis()
      assert(corpusMatch)
      UserOpinion opinion = new UserOpinion(session.user, corpusMatch, opinionValue)
      if (!opinion.save()) {
        throw new Exception("Could not save user opinion: ${opinion.errors}")
      }
      log.info("save opinion save: ${System.currentTimeMillis()-t}ms")
    }

}