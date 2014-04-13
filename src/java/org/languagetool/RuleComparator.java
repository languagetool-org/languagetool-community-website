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
package org.languagetool;

import java.util.Comparator;

import org.languagetool.rules.Rule;
import org.languagetool.rules.patterns.PatternRule;

enum SortDirection { asc, desc }
enum SortField { description, pattern, category }

/**
 * Enable sorting of rules after different criteria.
 * 
 * @author Daniel Naber
 */
public class RuleComparator implements Comparator<Rule> {

  private final SortField sortField;
  private final SortDirection sortDirection;
  
  RuleComparator(SortField sortField, SortDirection sortDirection) {
    this.sortField = sortField;
    this.sortDirection = sortDirection;
  }
  
  @Override
  public int compare(Rule r1, Rule r2) {
    int val;
    if (sortField == SortField.description) {
      val = r2.getDescription().compareToIgnoreCase(r1.getDescription());
    } else if (sortField == SortField.category) {
      val = r2.getCategory().getName().
          compareToIgnoreCase(r1.getCategory().getName());
    } else if (sortField == SortField.pattern) {
      String pattern1 = "[Java Rule]";
      String pattern2 = "[Java Rule]";
      if (r1 instanceof PatternRule) {
        pattern1 = ((PatternRule)r1).toPatternString();
      }
      if (r2 instanceof PatternRule) {
        pattern2 = ((PatternRule)r2).toPatternString();
      }
      val = pattern2.compareToIgnoreCase(pattern1);
    } else {
      throw new IllegalStateException();
    }
    if (sortDirection == SortDirection.asc) {
      val *= -1;
    }
    return val;
  }

}
