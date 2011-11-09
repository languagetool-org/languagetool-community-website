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
import org.apache.commons.io.IOUtils

class WikiCheckController extends BaseController {
  
  String CONVERT_URL_PREFIX = "http://community.languagetool.org/wikipediatotext/wikiSyntaxConverter/convert?url="
    
  def index = {
    if (params.url) {
      log.info("WikiCheck: " + params.url)
      WikipediaQuickCheck checker = new WikipediaQuickCheck()
      String langCode = params.url.substring("http://".length(), "http://xx".length())
      // TODO: remove this restriction
      if (langCode != 'de') {
        throw new Exception("Sorry, only 'de' (German) is supported for now (your language was: '${langCode}')")
      }
      URL plainTextUrl = new URL(CONVERT_URL_PREFIX + params.url)
      String plainText = download(plainTextUrl)
      if (plainText == '') {
        throw new Exception("No page content found at the given URL")
      }
      Language language = Language.GERMAN
      WikipediaQuickCheckResult result = checker.checkPage(plainText, language)
      params.lang = result.getLanguageCode()
      [result: result, matches: result.getRuleMatches(), textToCheck: result.getText(),
              lang: result.getLanguageCode(),
              url: params.url, disabledRuleIds: checker.getDisabledRuleIds(),
              plainText: plainText]
    } else {
      []
    }
  }
    
  private String download(final URL url) throws IOException {
    final HttpURLConnection connection = (HttpURLConnection)url.openConnection()
    if (connection.getResponseCode() != 200) {
      throw new IOException("Server error for " +  url + ", code: " + connection.getResponseCode())
    }
    final InputStream is = connection.getInputStream()
    try {
      StringWriter writer = new StringWriter()
      IOUtils.copy(is, writer, "utf-8")
      return writer.toString()
    } finally {
      is.close()
    }
  }

}
