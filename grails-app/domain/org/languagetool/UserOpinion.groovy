package org.languagetool

import java.util.Date

class UserOpinion {
  
  Long id
  Date date
  int opinion
  User user
  CorpusMatch corpusMatch

  public UserOpinion() {
  }
  
  public UserOpinion(User user, CorpusMatch corpusMatch, int opinion) {
    this.user = user
    this.corpusMatch = corpusMatch
    this.opinion = opinion
    date = new Date()
  }
  
}
