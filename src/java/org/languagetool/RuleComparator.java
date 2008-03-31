/*
 * Created on 16.02.2008
 */
package org.languagetool;

import java.util.Comparator;

import de.danielnaber.languagetool.rules.Rule;
import de.danielnaber.languagetool.rules.patterns.PatternRule;

enum SortDirection { asc, desc }
enum SortField { description, pattern, category }

/**
 * Enable sorting of rules after different criteria.
 * 
 * @author Daniel Naber
 */
public class RuleComparator implements Comparator<Rule> {

  private final SortField sortField;
  private SortDirection sortDirection;
  
  RuleComparator(SortField sortField, SortDirection sortDirection) {
    this.sortField = sortField;
    this.sortDirection = sortDirection;
  }
  
  public int compare(Rule r1, Rule r2) {
    int val = 0;
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
