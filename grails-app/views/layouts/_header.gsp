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
                <div class="imprint">
                    <a href="http://languagetool.org/contact/"><g:message code="ltc.imprint"/></a>
                </div>
            </td>
        </tr>
    </table>
</div>
