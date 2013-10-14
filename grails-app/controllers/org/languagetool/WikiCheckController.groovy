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

import org.languagetool.dev.wikipedia.MarkupAwareWikipediaResult
import org.languagetool.dev.wikipedia.PageNotFoundException
import org.languagetool.dev.wikipedia.WikipediaQuickCheck
import org.languagetool.dev.wikipedia.WikipediaQuickCheckResult
import org.apache.commons.io.IOUtils
import java.util.regex.Pattern
import java.util.regex.Matcher

class WikiCheckController extends BaseController {

    private static final Pattern XML_TITLE_PATTERN = Pattern.compile("title=\"(.*?)\"")

    private String CONVERT_URL_PREFIX = "http://community.languagetool.org/wikipediatotext/wikiSyntaxConverter/convert?url="

    def index = {
        String langCode
        try {
            Language langObj = params.lang ? Language.getLanguageForShortName(params.lang) : null
            langCode = langObj ? langObj.getShortName() : 'en'
        } catch (IllegalArgumentException ignore) {
            langCode = 'en'
        }
        if (params.url) {
            long startTime = System.currentTimeMillis()
            bookmarkletSanityCheck()
            WikipediaQuickCheck checker = new WikipediaQuickCheck()
            String pageUrl = getPageUrl(params, checker, langCode)
            String pageEditUrl = getPageEditUrl(pageUrl)
            Language language = checker.getLanguage(new URL(pageUrl))
            if (params.disabled) {
                checker.setDisabledRuleIds(Arrays.asList(params.disabled.split(",")))
            } else {
                Properties langToDisabledRules = new Properties()
                langToDisabledRules.load(new FileInputStream(grailsApplication.config.disabledRulesPropFile))
                List<String> allDisabledRules = langToDisabledRules.getProperty("all").split(",")
                String langSpecificDisabledRulesStr = langToDisabledRules.get(language.getShortName())
                if (langSpecificDisabledRulesStr) {
                    List<String> langSpecificDisabledRules = langSpecificDisabledRulesStr.split(",")
                    if (langSpecificDisabledRules) {
                        allDisabledRules.addAll(langSpecificDisabledRules)
                    }
                }
                if (params.enabled) {
                    List enabled = Arrays.asList(params.enabled.split(","))
                    allDisabledRules.removeAll(enabled)
                }
                checker.setDisabledRuleIds(allDisabledRules)
            }

            MarkupAwareWikipediaResult result
            try {
                result = checker.checkPage(new URL(pageUrl))
            } catch (PageNotFoundException e) {
                throw new Exception(message(code:'ltc.wikicheck.page.not.found', args: [pageUrl]))
            }
            params.lang = language.getShortName()
            long runTime = System.currentTimeMillis() - startTime
            log.info("WikiCheck: ${params.url} (${runTime}ms)")
            [result: result, appliedRuleMatches: result.getAppliedRuleMatches(),
                    wikipediaSubmitUrl: getPageSubmitUrl(pageUrl),
                    wikipediaTitle: getPageTitle(pageUrl),
                    lang: language.getShortName(),
                    url: params.url,
                    realUrl: pageUrl,
                    realEditUrl: pageEditUrl,
                    disabledRuleIds: checker.getDisabledRuleIds(),
                    languages: SortedLanguages.get(),
                    langCode: langCode]
        } else {
            [languages: SortedLanguages.get(), langCode: langCode]
        }
    }

    private void bookmarkletSanityCheck() {
        if (params.url.contains("languagetool.org/wikiCheck/")) {
            throw new Exception("You clicked the WikiCheck bookmarklet - this link only works when you put it in your bookmarks and call the bookmark while you're on a Wikipedia page")
        }
    }

    /**
     * The old view that does not offer direct Wikipedia correction.
     */
    def showErrors = {
        String langCode
        try {
            Language langObj = params.lang ? Language.getLanguageForShortName(params.lang) : null
            langCode = langObj ? langObj.getShortName() : 'en'
        } catch (IllegalArgumentException ignore) {
            langCode = 'en'
        }
        if (params.url) {
            Properties langToDisabledRules = new Properties()
            langToDisabledRules.load(new FileInputStream(grailsApplication.config.disabledRulesPropFile))

            long startTime = System.currentTimeMillis()
            bookmarkletSanityCheck()
            WikipediaQuickCheck checker = new WikipediaQuickCheck()
            String pageUrl = getPageUrl(params, checker, langCode)
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
                List<String> allDisabledRules = langToDisabledRules.getProperty("all").split(",")
                String langSpecificDisabledRulesStr = langToDisabledRules.get(language.getShortName())
                if (langSpecificDisabledRulesStr) {
                    List<String> langSpecificDisabledRules = langSpecificDisabledRulesStr.split(",")
                    if (langSpecificDisabledRules) {
                        allDisabledRules.addAll(langSpecificDisabledRules)
                    }
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
                    languages: SortedLanguages.get(),
                    langCode: langCode]
        } else {
            [languages: SortedLanguages.get(), langCode: langCode]
        }
    }

    String getPageEditUrl(String url) {
        // In:  http://de.wikipedia.org/wiki/Berlin
        // Out: http://de.wikipedia.org/w/index.php?title=Berlin&action=edit
        return url.replace("/wiki/", "/w/index.php?title=") + "&action=edit"
    }

    String getPageSubmitUrl(String url) {
        return url.replace("http://", "https://").replace("/wiki/", "/w/index.php?title=") + "&action=submit"
    }

    String getPageTitle(String url) {
        int idx = url.indexOf("/wiki/")
        if (idx == -1) {
            throw new Exception("Could not extract title from '${url}'")
        }
        return url.substring(idx + "/wiki/".length())
    }

    private String getPageUrl(params, WikipediaQuickCheck checker, String langCode) {
        String pageUrl
        if (params.url.startsWith("random:")) {
            String lang = params.url.substring("random:".length())
            if (lang.length() < 2 || lang.length() > 3) {
                throw new Exception("Invalid language: " + lang)
            }
            URL randomUrl = new URL("http://" + lang + ".wikipedia.org/w/api.php?action=query&list=random&rnnamespace=0&rnlimit=1&format=xml")
            pageUrl = "http://" + lang + ".wikipedia.org/wiki/" + getRandomPageTitle(randomUrl).replace(' ', '_')
        } else if (params.url.startsWith("http://") || params.url.startsWith("https://")) {
            checker.validateWikipediaUrl(new URL(params.url))
            pageUrl = params.url
        } else {
            pageUrl = "http://" + langCode + ".wikipedia.org/wiki/" + params.url.replace(' ', '_')
        }
        return pageUrl
    }

    private String download(URL url) throws IOException {
        HttpURLConnection connection = (HttpURLConnection)url.openConnection()
        if (connection.getResponseCode() != 200) {
            throw new IOException("Server error for " +  url + ", code: " + connection.getResponseCode())
        }
        InputStream is = connection.getInputStream()
        try {
            StringWriter writer = new StringWriter()
            IOUtils.copy(is, writer, "utf-8")
            return writer.toString()
        } finally {
            is.close()
        }
    }

    private String getRandomPageTitle(URL randomUrl) throws IOException {
        String content = download(randomUrl)
        Matcher matcher = XML_TITLE_PATTERN.matcher(content)
        matcher.find()
        return matcher.group(1).replace("&amp;" ,"&")
    }

}
