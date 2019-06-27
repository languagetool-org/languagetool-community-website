<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title>Admin: Users' spelling suggestions</title>
    <meta name="layout" content="main" />
    <g:javascript library="jquery" />
</head>
<body>

<div class="body">

    <div class="dialog">

        <h1>Admin: Users' spelling suggestions (max. ${limit})</h1>
        
        Only showing words that have been suggested at least
        <select id="minOcc" name="minOcc" onchange="window.location.href='./edit?password=${params.password}&lang=${params.lang}&max=${params.max}&minOcc=' + document.getElementById('minOcc').value">
            <g:each in="${(1..5).toList()}" var="count" >
                <g:if test="${minOcc == count}">
                    <option selected>${count}</option>
                </g:if>
                <g:else>
                    <option>${count}</option>
                </g:else>
            </g:each>
        </select>
        times.

        <g:form action="editDone" method="post">
            <g:hiddenField name="password" value="${params.password.encodeAsHTML()}"/>
            <g:hiddenField name="language" value="${params.lang.encodeAsHTML()}"/>
            <g:hiddenField name="ids" value="${suggestionIds.join(',')}"/>

            <table>
                <tr>
                    <th>Use</th>
                    <th>Count</th>
                    <th>Word</th>
                    <th>LT Suggestions</th>
                    <th title="number of occurrences in the Google ngram corpus">#</th>
                    <th></th>
                    <th>Suffixes</th>
                    <th>E-Mail</th>
                    <th>Date</th>
                </tr>
                <g:each in="${suggestions}" var="suggestion" status="i">
                    <tr style="${i % 2 == 0 ? '' : 'background-color: #eee'}">
                        <td><label><input type="checkbox" name="${suggestion.id}_use" checked="checked" /></label></td>
                        <td>${word2Count.get(suggestion.word)}</td>
                        <td>
                            <a target="_blank" href='https://www.google.de/search?q="${suggestion.word}"'>${suggestion.word.encodeAsHTML()}</a>
                            <g:set var="pattern" value="^[a-zA-ZöäüÖÄÜßéèÈÉ.-]+\$"/>
                            <g:if test="${lang == de && !suggestion.word.matches(pattern)}">
                                <br>Note: does not match ${pattern}
                            </g:if>
                        </td>
                        <td>${ltSuggestions.get(suggestion.word) != null ? ltSuggestions.get(suggestion.word).join(", ") : "-"}</td>
                        <td style="text-align: right">${suggestionCounts.get(suggestion.word)}</td>
                        <td>
                            <g:remoteLink action="hide" id="${suggestion.id}" update="message${suggestion.id}"
                                          params="${[password: params.password, word:suggestion.word]}"
                                          title="remove this item from this list (will not show up again after reload)">
                                Remove
                            </g:remoteLink>
                            <div id="message${suggestion.id}"></div>
                        <td>
                            <input type="text" name="${suggestion.id}_word" value="${suggestion.word.encodeAsHTML()}" /><br>
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
            <input type="submit" value="Continue">
            <ul>
                <li>all the items with "use" checked will be shown (and you need to add them to <tt>spelling.txt</tt>), all the others will be removed</li>
                <li>the count does not consider a trailing dot, if any</li>
            </ul>
            
        </g:form>

    </div>

</div>

</body>
</html>
