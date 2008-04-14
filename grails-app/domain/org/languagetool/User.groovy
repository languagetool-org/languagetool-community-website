/*
 * Created on 16.02.2008
 */
package org.languagetool

import java.util.Date

class User {

    String username
    String password
    Date lastLoginDate
    Date registerDate  // null until email is confirmed
    boolean isAdmin = false
    
    static hasMany = [languagesConfigurations: LanguageConfiguration]
    static fetchMode = [languagesConfigurations:"eager"]    // avoid the "lazy" exception
    
    static constraints = {
      lastLoginDate(nullable: true)
      registerDate(nullable: true)
    }
    
    public User() {
    }
    
    public User(String userId, String password) {
      this.username = userId
      this.password = password
    }
    
}
