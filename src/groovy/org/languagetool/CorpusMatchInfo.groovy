package org.languagetool

/**
 * Additional transient information added to a CorpusMatch.
 */
class CorpusMatchInfo {
  
  private CorpusMatch match
  private int opinion = -1
  
  CorpusMatchInfo(CorpusMatch match) {
    this.match = match
  }
  
}