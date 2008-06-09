
<%@ page import="org.languagetool.CorpusMatch" %>
<%@ page import="org.languagetool.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title>Corpus Matches</title>
    </head>
    <body>

        <div class="body">

            <g:render template="/languageSelection"/>

            <h1>Corpus Matches</h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

            <div class="list">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Match</th>
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${corpusMatchList}" status="i" var="match">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td>${match.id?.encodeAsHTML()}</td>
                        
                            <td>
                                ${StringTools.formatError(match.message.encodeAsHTML())}<br />
                                ${StringTools.formatError(match.errorContext.encodeAsHTML())}<br />
                                <span class="additional">URI: <g:link class="additional" url="${match.sourceURI}">${match.sourceURI.encodeAsHTML()}</g:link></span>
                                <span class="additional">Check date: ${StringTools.formatDate(match.checkDate).encodeAsHTML()}</span>
                            </td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${CorpusMatch.countByLanguageCode(params.lang)}" 
                    params="${params}"/>
            </div>
        </div>
    </body>
</html>
