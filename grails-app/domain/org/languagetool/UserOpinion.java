package org.languagetool;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;

@Entity
public class UserOpinion {
  
  private Long id;
  private Date date;
  private int opinion;
  private User user;
  private CorpusMatch corpusMatch;

  public UserOpinion() {
  }
  
  public UserOpinion(User user, CorpusMatch corpusMatch, int opinion) {
    this.user = user;
    this.corpusMatch = corpusMatch;
    this.opinion = opinion;
    date = new Date();
  }
  
  @Id
  @GeneratedValue
  public Long getId() {
      return id;
  }
  public void setId(Long id) {
      this.id = id;
  }
  public Date getDate() {
    return date;
  }
  public void setDate(Date date) {
    this.date = date;
  }
  public int getOpinion() {
    return opinion;
  }
  public void setOpinion(int opinion) {
    this.opinion = opinion;
  }
  @ManyToOne
  public User getUser() {
    return user;
  }
  public void setUser(User user) {
    this.user = user;
  }

  @ManyToOne
  public CorpusMatch getCorpusMatch() {
    return corpusMatch;
  }
  public void setCorpusMatch(CorpusMatch corpusMatch) {
    this.corpusMatch = corpusMatch;
  }
  
}
