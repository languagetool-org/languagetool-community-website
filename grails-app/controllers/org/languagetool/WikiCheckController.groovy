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
import java.util.regex.Pattern
import java.util.regex.Matcher

class WikiCheckController extends BaseController {

  // disable some rules because of too many false alarms:
  private static final List<String> DEFAULT_DISABLED_RULES = 
    Arrays.asList("WHITESPACE_RULE", "UNPAIRED_BRACKETS", "UPPERCASE_SENTENCE_START", "COMMA_PARENTHESIS_WHITESPACE")
  private static final Map<String,List<String>> LANG_TO_DISABLED_RULES = new HashMap<String, List<String>>()

  private static final Pattern XML_TITLE_PATTERN = Pattern.compile("title=\"(.*?)\"")
    
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
      if (params.url.contains("languagetool.org/wikiCheck/")) {
          throw new Exception("You clicked the WikiCheck bookmarklet - this link only works when you put it in your bookmarks and call the bookmark while you're on a Wikipedia page")
      }
      WikipediaQuickCheck checker = new WikipediaQuickCheck()
      String pageUrl = getPageUrl(params, checker)
      String pageEditUrl = getPageEditUrl(pageUrl)
      URL plainTextUrl = new URL(CONVERT_URL_PREFIX + pageUrl.replace(' ', '_'))
      String plainText = download(plainTextUrl)
      if (plainText == '') {
        throw new Exception("No Wikipedia page content found at the given URL: " + plainTextUrl + " (page url: " + pageUrl + ")")
      }
      Language language = checker.getLanguage(new URL(pageUrl))
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
              url: params.url,
              realUrl: pageUrl,
              realEditUrl: pageEditUrl,
              disabledRuleIds: checker.getDisabledRuleIds(),
              plainText: plainText]
    } else {
      []
    }
  }

  String getPageEditUrl(String url) {
    // In:  http://de.wikipedia.org/wiki/Berlin
    // Out: http://de.wikipedia.org/w/index.php?title=Berlin&action=edit
    return url.replace("/wiki/", "/w/index.php?title=") + "&action=edit"
  }

  private String getPageUrl(params, WikipediaQuickCheck checker) {
    String pageUrl
    if (params.url.startsWith("random:")) {
      String lang = params.url.substring("random:".length())
      if (lang.length() < 2 || lang.length() > 3) {
        throw new Exception("Invalid language: " + lang)
      }
      URL randomUrl = new URL("http://" + lang + ".wikipedia.org/w/api.php?action=query&list=random&rnnamespace=0&rnlimit=1&format=xml")
      pageUrl = "http://" + lang + ".wikipedia.org/wiki/" + getRandomPageTitle(randomUrl)
    } else {
      checker.validateWikipediaUrl(new URL(params.url))
      pageUrl = params.url
    }
    return pageUrl
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

  private String getRandomPageTitle(final URL randomUrl) throws IOException {
    final String content = download(randomUrl)
    final Matcher matcher = XML_TITLE_PATTERN.matcher(content)
    matcher.find()
    return matcher.group(1)
  }

}
