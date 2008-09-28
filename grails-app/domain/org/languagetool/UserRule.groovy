/* LanguageTool Community 
 * Copyright (C) 2008 Daniel Naber (http://www.danielnaber.de)
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
 * USA
 */
 
package org.languagetool

import de.danielnaber.languagetool.AnalyzedSentence
import de.danielnaber.languagetool.rules.*
import de.danielnaber.languagetool.rules.patterns.*
import de.danielnaber.languagetool.Language

/**
 * An individual user's rule.
 */
class UserRule {

   boolean isPublic
   User user
   String lang
   String originalRuleId
   
   //FIXME: are these needed at all now that we generate PatternRule on-the-fly??
   String pattern
   String description
   String message
   
   static constraints = {
     originalRuleId(nullable: true)
     pattern(maxSize:5000)
   }
   
   PatternRule toPatternRule(boolean useInternalId) {
     final PatternRuleLoader loader = new PatternRuleLoader()
     String extPattern = "<rules lang=\"${lang}\">" + pattern + "</rules>"
     InputStream xmlStream = new ByteArrayInputStream(extPattern.getBytes());
     final List<PatternRule> rules = loader.getRules(xmlStream, "[xml stream]");
     if (rules.size() != 1) {
       throw new Exception("Unexpected length of rule list: ${rules.size()}, pattern: $pattern")
     }
     PatternRule rule = rules.get(0)
     rule.setCategory(new Category("User Rules"))
     return rule
   }
   
}
