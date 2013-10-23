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

import java.util.Date

/**
 * An error detected by the grammar checker in a text corpus.
 */
class CorpusMatch {

    static constraints = {
        ruleDescription(nullable: true) // nullable because it was introduced later
        ruleSubID(nullable: true) // nullable because it was introduced later
    }

    String languageCode
    String ruleID
    String ruleSubID
    String ruleDescription
    String message
    String sourceURI
    String sourceType
    String errorContext
    Date corpusDate
    Date checkDate
    /**
     * Set to 0 if the match if outdated, i.e. when new matches have
     * been added to the database.
     */
    boolean isVisible

    static hasMany = [userOpinions: UserOpinion]

}
