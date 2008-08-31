
<%@ page import="org.languagetool.StringTools" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title><g:message code="ltc.user.opinion.title"/></title>
    </head>
    <body>

        <div class="body">
            <g:render template="/languageSelection"/>

            <h1><g:message code="ltc.user.opinion.title"/></h1>

            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

            <div class="list">
                <table>
                    <thead>
                        <th><g:message code="ltc.user.opinion.votes"/></th>
                        <th><g:message code="ltc.user.opinion.match"/></th>
                    </thead>
                    <tbody>
                    <g:each in="${results}" status="i" var="opinion">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td>${opinion.counter}</td>
                            <td>
                                <g:if test="${opinion.corpusMatch?.message}">
                                 <g:link controller="rule" action="show"
                                 	id="${opinion.corpusMatch?.ruleID}"
                                 	params="[lang: params.lang]">${StringTools.formatError(opinion.corpusMatch?.message.encodeAsHTML())}</g:link><br />
                                 ${StringTools.formatError(opinion.corpusMatch?.errorContext.encodeAsHTML())}<br />
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
