<div class="header">&nbsp;
    <%
        String homeLink = request.getContextPath();
        if (homeLink.equals("")) {
            homeLink = "/";
        }
        if (params.lang) {
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
                <div class="imprint">
                    <a href="https://languagetool.org/legal/"><g:message code="ltc.imprint"/></a> &middot;
                    <a href="https://languagetool.org/privacy/"><g:message code="ltc.privacy"/></a>
                </div>
            </td>
        </tr>
    </table>
</div>
