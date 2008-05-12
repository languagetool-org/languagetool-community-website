package org.languagetool

/**
 * Additional transient information added to a CorpusMatch.
 */
class CorpusMatchInfo implements Comparable {
  
  private CorpusMatch match
  private int opinion = -1
  
  CorpusMatchInfo(CorpusMatch match) {
    this.match = match
  }
  
  public int compareTo(Object o) {
    if (!o instanceof CorpusMatchInfo) {
      throw new Exception("not of type CorpusMatchInfo: $o")
    }
    CorpusMatchInfo otherMatchInfo = (CorpusMatchInfo)o;
    if (match.id < otherMatchInfo.match.id) {
      return 1
    } else if (match.id > otherMatchInfo.match.id) {
      return -1
    } else {
      return 0
    }
  }

}