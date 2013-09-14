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

import org.apache.commons.lang.StringEscapeUtils;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.regex.Pattern;

public class StringTools {
  
  private StringTools() {
    // static methods only, no public constructor
  }
  
  public static String formatDate(Date date) {
    final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    return sdf.format(date);
  }
  
  /**
   * Return a shortened copy of a string.
   * 
   * @param s the string to shorten
   * @param maxLen the maximum length of the new string (without marker)
   * @param marker appended to the end of the string if it was shortened
   * @since 0.9.3
   */
  public static String shorten(String s, int maxLen, String marker) {
    if (s.length() > maxLen) {
      return s.substring(0, maxLen) + marker;
    }
    return s;
  }
  
  public static String formatError(String s) {
    return s.replaceAll("&lt;suggestion&gt;", "<span class=\"correction\">").
      replaceAll("&lt;/suggestion&gt;", "</span>").
      replaceAll("&lt;err&gt;", "<span class=\"error\">").
      replaceAll("&lt;/err&gt;", "</span>");
  }

  /** Remove the "<err>" markup */
  public static String cleanError(String s) {
    return s.replaceAll("<err>", "").replaceAll("</err>", "");
  }

  /**
   * @param text the text to be escaped
   * @param searchString the string to be searched (case-insensitively) and marked with a span in {@code text}
   */
  public static String escapeHtmlAndHighlightMatches(String text, String searchString) {
    if (searchString == null) {
      return StringEscapeUtils.escapeHtml(text);
    }
    text = text.replaceAll("(?i)(" + Pattern.quote(searchString) + ")", "<span class='filterMatch'>$1</span>");
    text = StringEscapeUtils.escapeHtml(text);
    text = text.replaceAll("&lt;span class='filterMatch'&gt;", "<span class='filterMatch'>");
    text = text.replaceAll("&lt;/span&gt;", "</span>");
    return text;
  }

}
