/*
 * Created on 16.02.2008
 */
package org.languagetool;

import java.util.Date;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.PrimaryKeyJoinColumn;

@Entity
public class User {
    private Long id;
    private String username;
    private String password;
    private Date lastLoginDate;
    private Date registerDate;  // null until email is confirmed
    //private List<Language> languages;
    private boolean isAdmin = false;
    private UserConfiguration config;

    public User() {
    }
    
    public User(String userId, String password) {
      this.username = userId;
      this.password = password;
      //this.config = new UserConfiguration();
    }
    
    @Id
    @GeneratedValue
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getUsername() {
        return username;
    }
    public void setUsername(String title) {
        this.username = title;
    }
    public Date getLastLoginDate() {
      return lastLoginDate;
    }
    public void setLastLoginDate(Date lastLoginDate) {
      this.lastLoginDate = lastLoginDate;
    }
    public Date getRegisterDate() {
      return registerDate;
    }
    public void setRegisterDate(Date registerDate) {
      this.registerDate = registerDate;
    }
    /*public List<Language> getLanguages() {
      return languages;
    }
    public void setLanguages(List<Language> languages) {
      this.languages = languages;
    }*/
    public boolean isAdmin() {
      return isAdmin;
    }
    public void setAdmin(boolean isAdmin) {
      this.isAdmin = isAdmin;
    }
    public String getPassword() {
      return password;
    }
    public void setPassword(String Password) {
      this.password = Password;
    }
    
    public String toString() {
      return username;
    }

    @OneToOne(cascade = CascadeType.ALL)
    @PrimaryKeyJoinColumn
    public UserConfiguration getConfig() {
      return config;
    }

    public void setConfig(UserConfiguration config) {
      this.config = config;
    }
}
