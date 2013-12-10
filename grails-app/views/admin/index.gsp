<%@ page import="org.languagetool.CorpusMatch" %>
<%@ page import="org.languagetool.StringTools" %>
<html>
<head>
    <meta name="layout" content="main" />
    <title>Admin Area</title>
</head>
<body>

<div class="body">

    <h1>Admin Area</h1>

    <g:if test="${flash.message}">
        <div class="message">${flash.message}</div>
    </g:if>

    <h3>Admins (${admins.size()})</h3>

    <ul>
        <g:each in="${admins}" var="admin">
            <li>${admin.username}</li>
        </g:each>
    </ul>

    <h3 style="margin-top: 15px">Users (${totalUsers})</h3>
    
    <table>
        <tr>
            <th>Username</th>
            <th>Register Date</th>
            <th>Last Login</th>
        </tr>
        <g:each in="${users}" var="user">
            <tr>
                <td>${user.username.encodeAsHTML()}</td>
                <td class="metaInfo"><g:formatDate date="${user.registerDate}" format="yyyy-MM-dd"/></td>
                <td class="metaInfo"><g:formatDate date="${user.lastLoginDate}" format="yyyy-MM-dd"/></td>
            </tr>
        </g:each>
    </table>
    <g:link params="${[maxUsers: -1]}">Show all users</g:link>

</div>

</body>
</html>
