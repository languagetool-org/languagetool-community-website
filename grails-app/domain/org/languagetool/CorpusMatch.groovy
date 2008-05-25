package org.languagetool

import java.util.Date

class CorpusMatch {
  
  String languageCode
  String ruleID
  String message
  String sourceURI
  String errorContext
  Date corpusDate
  Date checkDate
  /**
   * Set to 0 if the match if outdated, i.e. when new matches have
   * been added to the database.
   */
  boolean isVisible
  
  static hasMany = [userOpinions: UserOpinion]

}
