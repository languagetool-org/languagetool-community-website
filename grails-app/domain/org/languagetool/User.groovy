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

/**
 * A User of the community website.
 */
class User {

    String username
    String password
    Date lastLoginDate
    Date registerDate  // null until email is confirmed
    boolean isAdmin = false

    static hasMany = [languagesConfigurations: LanguageConfiguration]
    static fetchMode = [languagesConfigurations:"eager"]    // avoid the "lazy" exception

    static constraints = {
        username(unique: true)
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
