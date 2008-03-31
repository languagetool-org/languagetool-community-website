/*
 * Created on 24.02.2008
 */
package org.languagetool;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class LanguageConfiguration {

  private Long id;
  
  private String language;
  
  public LanguageConfiguration() {
  }
  
  public LanguageConfiguration(String languageCode) {
    this.language = languageCode;
  }
  
  @Id
  @GeneratedValue
  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getLanguage() {
    return language;
  }

  public void setLanguage(String languageCode) {
    this.language = languageCode;
  }

/*  private Set<String> disabledRuleIds;

  public Set<String> getDisabledRuleIds() {
    return disabledRuleIds;
  }

  public void setDisabledRuleIds(Set<String> disabledRuleIds) {
    this.disabledRuleIds = disabledRuleIds;
  }*/
  
}
