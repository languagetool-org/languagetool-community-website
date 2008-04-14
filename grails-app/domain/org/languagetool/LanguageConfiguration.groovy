/*
 * Created on 24.02.2008
 */
package org.languagetool

import java.util.HashSet
import java.util.Set

class LanguageConfiguration {

  String language
  
  static hasMany = [disabledRules: DisabledRule]
  
  static belongsTo = User
  static fetchMode = [disabledRules:"eager"]    // avoid the "lazy" exception
  
}
