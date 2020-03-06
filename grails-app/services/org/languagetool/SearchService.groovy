/* LanguageTool Community
 * Copyright (C) 2012 Daniel Naber (http://www.danielnaber.de)
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

import org.apache.lucene.store.SimpleFSDirectory
import org.languagetool.dev.index.SearcherResult
import org.languagetool.dev.index.UnsupportedPatternRuleException
import org.languagetool.rules.patterns.PatternRule
import org.languagetool.dev.index.Searcher
import org.apache.lucene.index.DirectoryReader

class SearchService {

    def grailsApplication

    SearcherResult checkRuleAgainstCorpus(PatternRule patternRule, Language language, int skipDocs, int maxHits, int timeoutMillis) throws UnsupportedPatternRuleException {
        log.info("Checking rule against ${language} corpus: ${patternRule.getPatternTokens()}, timeout: ${timeoutMillis}ms, skipDocs: ${skipDocs}, maxHits: ${maxHits}")
        String indexDirTemplate = grailsApplication.config.fastSearchIndex
        File indexDir = new File(indexDirTemplate.replace("LANG", language.getShortCode()))
        if (indexDir.isDirectory()) {
            // NIOFSDirectory and MMapDirectory (as returned by FSDirectory.open()) don't play together 
            // with using Thread.interrupt(), so use SimpleFSDirectory:
            SearcherResult searcherResult = null
            def directory = SimpleFSDirectory.open(indexDir.toPath())
            try {
                Searcher searcher = new Searcher(directory, "fieldLowercase")
                DirectoryReader indexReader = DirectoryReader.open(directory)
                try {
                    log.info("${language} index size: ${indexReader.numDocs()}")
                    searcher.setSkipHits(skipDocs)
                    searcher.setMaxHits(maxHits + skipDocs)
                    searcher.setMaxSearchTimeMillis(timeoutMillis)
                    searcherResult = searcher.findRuleMatchesOnIndex(patternRule, language)
                } finally {
                    indexReader.close()
                }
            } finally {
                directory.close()
            }
            log.info("getMatchingSentences(): ${searcherResult.getMatchingSentences().size()}")
            return searcherResult
        } else {
            throw new NoDataForLanguageException(language, indexDir)
        }
    }
}
