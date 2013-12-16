/* LanguageTool Community 
 * Copyright (C) 2011 Daniel Naber (http://www.danielnaber.de)
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
import javax.servlet.http.Cookie
import org.languagetool.UserController
import org.languagetool.DurationSession

class SessionRestoreFilters {
    
    def filters = {
        restoreSessionFilter(controller:'*', action:'*') {
            before = {
                restoreSessionIfPossible(session, request)
                return true
            }
        }
    }

    private void restoreSessionIfPossible(def session, def request) {
        if (!session.user) {
            // user doesn't have a login session yet. look at cookies so users can stay logged in (almost) forever:
            DurationSession dSession = getDurationSession(request)
            if (dSession) {
                session.user = dSession.user
            }
        }
    }
    
    private DurationSession getDurationSession(request) {
        Cookie[] cookies = request.getCookies()
        for (cookie in cookies) {
            // "loginCookie" is the long-term cookie used to identify users
            // so they don't have to re-login on each visit:
            if (cookie.getName() == UserController.LOGIN_COOKIE_NAME) {
                DurationSession dSession = DurationSession.findBySessionId(cookie.getValue())
                if (dSession) {
                    log.debug("Using user's old session found in cookie: ${dSession.user}")
                    return dSession
                }
                break
            }
        }
        return null
    }
    
}
