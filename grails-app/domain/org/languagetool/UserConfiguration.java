/*
 * Created on 24.02.2008
 */
package org.languagetool;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;

@Entity
public class UserConfiguration {
  
  private Long id;

  private List<LanguageConfiguration> languagesConfigurations = new ArrayList<LanguageConfiguration>();

  @Id
  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  @OneToMany
  public List<LanguageConfiguration> getLanguagesConfigurations() {
    return languagesConfigurations;
  }

  public void setLanguagesConfigurations(List<LanguageConfiguration> languageConfigs) {
    this.languagesConfigurations = languageConfigs;
  }

  public void addLanguagesConfiguration(LanguageConfiguration languageConfig) {
    this.languagesConfigurations.add(languageConfig);
  }

}
