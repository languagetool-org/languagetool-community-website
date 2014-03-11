<div class="header">&nbsp;
    <%
        String homeLink = request.getContextPath();
        if (homeLink.equals("")) {
            homeLink = "/";
        }
        if (params.lang && params.lang != 'auto') {
            homeLink += "?lang=" + params.lang;
        }
    %>
    <table style="border: 0">
        <tr>
            <td valign="top">
                <h1 class="logo"><g:link url="${homeLink}"><g:message code="ltc.title"/></g:link></h1>
    
                <h3 class="sublogo"><g:message code="ltc.subtitle"/></h3>
            </td>
            <td valign="top">
                <g:if test="${session.user}">
                    <div class="login"><g:message code="ltc.logged.in" args="${[session.user.username.encodeAsHTML()]}"/> -
                    <g:if test="${session.user.isAdmin}">
                        <g:link controller="admin">Admin</g:link> -
                    </g:if>
                    <g:link controller="user" action="logout"><g:message code="ltc.logout"/></g:link>
                    -
                    <g:link controller="user" action="settings"><g:message code="ltc.settings"/></g:link>
                    </div>
                </g:if>
                <g:else>
                    <div class="login">
                        <g:link controller="user" action="login"><g:message code="ltc.login"/></g:link>
                    </div>
                </g:else>
                <div class="imprint">
                    <a href="http://languagetool.org/contact/"><g:message code="ltc.imprint"/></a>
                </div>
            </td>
        </tr>
    </table>
</div>
