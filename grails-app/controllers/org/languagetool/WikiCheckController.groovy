/* LanguageTool Community 
 * Copyright (C) 2011 Daniel Naber (http://www.danielnaber.de)
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

import org.languagetool.dev.wikipedia.WikipediaQuickCheck
import org.languagetool.dev.wikipedia.WikipediaQuickCheckResult

class WikiCheckController extends BaseController {
  
  def index = {
    if (params.url) {
      log.info("WikiCheck: " + params.url)
      WikipediaQuickCheck checker = new WikipediaQuickCheck()
      String langCode = params.url.substring("http://".length(), "http://xx".length())
      if (langCode != 'de') {
        throw new Exception("Sorry, only 'de' (German) is supported for now (your language was: '${langCode}')")
      }
      String plainText = checker.getMediaWikiContent(new URL(params.url))
      Language language = Language.GERMAN
      WikipediaQuickCheckResult result = checker.checkPage(plainText, language)
      params.lang = result.getLanguageCode()
      [result: result, matches: result.getRuleMatches(), textToCheck: result.getText(),
              lang: result.getLanguageCode(),
              url: params.url, disabledRuleIds: checker.getDisabledRuleIds()]
    } else {
      []
    }
  }

}
