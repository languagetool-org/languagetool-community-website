<table style="border: 0">
<tr>
    <td width="150" valign="top">XML</td>
    <td valign="top">
        <g:if test="${error}">
            <div class="errors">${error.encodeAsHTML()}</div>
            <script type="text/javascript">
                document.ruleForm.message.select();
            </script>
        </g:if>
        <g:else>

            <p style="width:450px;margin-top: 0; margin-bottom: 5px"><g:message code="ltc.editor.xml.intro" args="${[language.getShortName()]}"/></p>

            <pre style="background-color: #eeeeee; padding: 10px">${xml.encodeAsHTML().replaceAll("&gt;(.*?)&lt;", "&gt;<strong>\$1</strong>&lt;")}</pre>

            <p style="width:450px;margin-top: 5px"><g:message code="ltc.editor.documentation.link"/></p>
            
            <g:render template="submitRule"/>

            <p style="width:450px;"><g:message code="ltc.editor.continue.with.xml"/></p>
            
            <g:form action="expert" method="post" target="ltRuleEditor">
                <input name="xml" type="hidden" value="${xml.encodeAsHTML()}"/>
                <input name="language" type="hidden" value="${params.language.encodeAsHTML()}"/>
                <g:submitButton name="${message(code:'ltc.editor.edit.xml')}"/>
            </g:form>

        </g:else>
    </td>
</tr>
</table>
