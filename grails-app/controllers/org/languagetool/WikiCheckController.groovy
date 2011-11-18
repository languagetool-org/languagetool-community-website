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

  // disable some rules because of too many false alarms:
  private static final List<String> DEFAULT_DISABLED_RULES = 
    Arrays.asList("WHITESPACE_RULE", "UNPAIRED_BRACKETS", "UPPERCASE_SENTENCE_START", "COMMA_PARENTHESIS_WHITESPACE")
  private static final Map<String,List<String>> LANG_TO_DISABLED_RULES = new HashMap<String, List<String>>()
    
  static {
    LANG_TO_DISABLED_RULES.put("en", Arrays.asList("EN_QUOTES"))
    LANG_TO_DISABLED_RULES.put("de", Arrays.asList("DE_CASE", "DE_AGREEMENT", "PFEILE", "BISSTRICH", "AUSLASSUNGSPUNKTE", "MALZEICHEN"))
    LANG_TO_DISABLED_RULES.put("fr", Arrays.asList("FRENCH_WHITESPACE"))
    LANG_TO_DISABLED_RULES.put("pl", Arrays.asList("BRAK_SPACJI"))
  }
  
  private String CONVERT_URL_PREFIX = "http://community.languagetool.org/wikipediatotext/wikiSyntaxConverter/convert?url="
    
  def index = {
    if (params.url) {
      long startTime = System.currentTimeMillis()
      WikipediaQuickCheck checker = new WikipediaQuickCheck()
      checker.validateWikipediaUrl(new URL(params.url))
      URL plainTextUrl = new URL(CONVERT_URL_PREFIX + params.url)
      String plainText = download(plainTextUrl)
      if (plainText == '') {
        throw new Exception("No Wikipedia page content found at the given URL")
      }
      Language language = checker.getLanguage(new URL(params.url))
      if (params.disabled) {
        checker.setDisabledRuleIds(Arrays.asList(params.disabled.split(",")))
      } else {
        List<String> allDisabledRules = new ArrayList<String>(DEFAULT_DISABLED_RULES)
        List<String> langSpecificDisabledRules = LANG_TO_DISABLED_RULES.get(language.getShortName())
        if (langSpecificDisabledRules) {
          allDisabledRules.addAll(langSpecificDisabledRules)
        }
        checker.setDisabledRuleIds(allDisabledRules)
      }
      WikipediaQuickCheckResult result = checker.checkPage(plainText, language)
      params.lang = result.getLanguageCode()
      long runTime = System.currentTimeMillis() - startTime
      log.info("WikiCheck: ${params.url} (${runTime}ms)")
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
