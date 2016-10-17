<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title>Admin: Users' spelling suggestions</title>
    <meta name="layout" content="main" />
</head>
<body>

<div class="body">

    <div class="dialog">

        <h1>Admin: Users' spelling suggestions</h1>

        <g:form action="editDone" method="post">
            <g:hiddenField name="password" value="${params.password.encodeAsHTML()}"/>
            <g:hiddenField name="language" value="${params.lang.encodeAsHTML()}"/>
            <g:hiddenField name="ids" value="${suggestionIds.join(',')}"/>

            <table>
                <tr>
                    <th>Use</th>
                    <th>Word</th>
                    <th>#</th>
                    <th>Suffixes</th>
                    <th>E-Mail</th>
                    <th>Date</th>
                </tr>
                <g:each in="${suggestions}" var="suggestion" status="i">
                    <tr style="${i % 2 == 0 ? '' : 'background-color: #eee'}">
                        <td><label><input type="checkbox" name="${suggestion.id}_use" checked="checked" /></label></td>
                        <td><a target="_blank" href='https://www.google.de/search?q="${suggestion.word}"'>${suggestion.word.encodeAsHTML()}</a></td>
                        <td style="text-align: right">${suggestionCounts.get(suggestion.word)}</td>
                        <td>
                            <label><input type="checkbox" name="${suggestion.id}_N" />/N</label>
                            <label><input type="checkbox" name="${suggestion.id}_S" />/S</label>
                            <label><input type="checkbox" name="${suggestion.id}_A" />/A</label>
                            <label><input type="checkbox" name="${suggestion.id}_E" />/E</label>
                        </td>
                        <td style="color:#999">${suggestion.email.encodeAsHTML()}</td>
                        <td style="color:#999"><g:formatDate date="${suggestion.date}" format="yyyy-MM-dd HH:mm"/></td>
                    </tr>
                </g:each>
            </table>
            <input type="submit" value="Continue"><br>all the items with "use" checked will be shown (and you need to add them
            to <tt>spelling.txt</tt>), all the others will be removed
            
        </g:form>

    </div>

</div>

</body>
</html>
