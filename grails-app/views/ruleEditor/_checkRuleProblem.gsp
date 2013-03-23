<table style="border: 0px">
<tr>
    <td width="150"></td>
    <td>

        <div class="errors"><g:message code="ltc.editor.rule.problems"/>

            <ul>
                <g:if test="${isOff}">
                    <li><g:message code="ltc.editor.rule.not.enabled"/></li>
                </g:if>
                <g:else>
                    <g:each in="${problems}" var="problem">
                        <li>${problem.encodeAsHTML()}</li>
                    </g:each>
                    <li><g:message code="ltc.editor.rule.language.selection" args="${[params.language.encodeAsHTML()]}"/></li>
                </g:else>
            </ul>

        </div>

        <p style="width:450px;margin-top: 5px"><g:message code="ltc.editor.example.intro" args="${['http://www.languagetool.org/forum/']}"/></p>

        <g:if test="${hasRegex && !expertMode}">
            <p style="width:450px;margin-top: 5px"><g:message code="ltc.editor.regex.warning"/></p>
        </g:if>

    </td>
</tr>
</table>