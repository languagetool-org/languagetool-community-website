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
 * A registration ticket with a manually generated code that can e.g.
 * be sent to the user via email to register at the website.
 */
class RegistrationTicket {

    String ticketCode
    Date generationDate
    User user

    public RegistrationTicket() {
    }

    public RegistrationTicket(User user, String secret) {
        String key = Math.random() + "/" + secret
        this.ticketCode = PasswordTools.hexMD5(key)
        this.generationDate = new Date()
        this.user = user
    }

}