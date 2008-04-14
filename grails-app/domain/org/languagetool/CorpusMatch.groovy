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
  
  static hasMany = [userOpinions: UserOpinion]
    
}
