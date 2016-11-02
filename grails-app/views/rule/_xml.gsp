
<div class="ruleXmlArea">

    <pre class='ruleXml'>${ruleAsXml.encodeAsHTML().replaceAll("&lt;(.*?)&gt;", "<span class='xmlTag'>&lt;\$1&gt;</span>")}</pre>

    <g:form style="margin-top: 8px" controller="ruleEditor" action="expert" method="post">
        <input name="xml" type="hidden" value="${ruleAsXml.encodeAsHTML()}"/>
        <input name="language" type="hidden" value="${language.getShortCode().encodeAsHTML()}"/>
        <g:submitButton name="${message(code:'ltc.rule.show.edit.xml')}"/>
    </g:form>

</div>
