
<%@ page import="org.languagetool.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title>User Opinions on the Corpus Matches</title>
    </head>
    <body>

        <div class="body">
            <h1>User Opinions on the Corpus Matches</h1>

            <g:render template="/languageSelection"/>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

            <div class="list">
                <table>
                    <tbody>
                    <g:each in="${results}" status="i" var="opinion">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td>${opinion.counter}</td>
                            <td>
                                <g:if test="${opinion.corpusMatch?.message}">
                                 ${StringTools.formatError(opinion.corpusMatch?.message.encodeAsHTML())}<br />
                                 ${StringTools.formatError(opinion.corpusMatch?.errorContext.encodeAsHTML())}
                                </g:if>
                            </td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
