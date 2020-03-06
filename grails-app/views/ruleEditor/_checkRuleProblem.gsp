<br/>
<!-- do no modify:-->
<!--STOPCHECK-->

<table style="border: 0">
<tr>
    <td style="vertical-align:top">
        <img style="margin:5px" src="${resource(dir:'images', file:'exclamation.png')}" />
    </td>
    <td>

        <div><g:message code="ltc.editor.rule.problems"/>

            <ul>
                <g:each in="${problems}" var="problem">
                    <li>${problem}</li>
                </g:each>
                <li><g:message code="ltc.editor.rule.language.selection" args="${[language.getName().encodeAsHTML()]}"/></li>
            </ul>

        </div>

        <g:if test="${hasRegex && !expertMode}">
            <p style="width:450px;margin-top: 5px"><g:message code="ltc.editor.example.intro" args="${['http://www.languagetool.org/forum/']}"/></p>
            <p style="width:450px;margin-top: 5px"><g:message code="ltc.editor.regex.warning"/></p>
        </g:if>

    </td>
</tr>
</table>