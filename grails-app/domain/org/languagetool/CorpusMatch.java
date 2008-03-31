package org.languagetool;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class CorpusMatch {
  
  private Long id;
  private String languageCode;
  private String ruleID;
  private String message;
  private String sourceURI;
  private String errorContext;
  private Date corpusDate;
  private Date checkDate;
  
  @Id
  @GeneratedValue
  public Long getId() {
      return id;
  }
  public void setId(Long id) {
      this.id = id;
  }

  public String getLanguageCode() {
    return languageCode;
  }
  public void setLanguageCode(String languageCode) {
    this.languageCode = languageCode;
  }
  public String getRuleID() {
    return ruleID;
  }
  public void setRuleID(String ruleID) {
    this.ruleID = ruleID;
  }
  public String getMessage() {
    return message;
  }
  public void setMessage(String message) {
    this.message = message;
  }
  public String getErrorContext() {
    return errorContext;
  }
  public void setErrorContext(String errorContext) {
    this.errorContext = errorContext;
  }
  public Date getCorpusDate() {
    return corpusDate;
  }
  public void setCorpusDate(Date corpusDate) {
    this.corpusDate = corpusDate;
  }
  public Date getCheckDate() {
    return checkDate;
  }
  public void setCheckDate(Date checkDate) {
    this.checkDate = checkDate;
  }
  public String getSourceURI() {
    return sourceURI;
  }
  public void setSourceURI(String sourceURI) {
    this.sourceURI = sourceURI;
  }
  
}
