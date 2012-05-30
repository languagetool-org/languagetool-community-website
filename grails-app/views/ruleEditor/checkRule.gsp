<table style="border: 0px">
<tr>
    <td width="150">Error Message</td>
    <%
    String preset = "Did you mean \"bad\"?";
    %>
    <td><g:textField id="message"
            onkeypress="return handleReturnForXmlCreation(event);"
            onfocus="\$('message').setStyle({color: 'black'})"
            onblur="\$('messageBackup').value = \$('message').value"
            class="preFilledField" type="text" name="message"
            value='${messagePreset ? messagePreset : preset}'/>
        <br/>
        <span class="metaInfo">Use double quotes to mark the correction.</span>
    </td>
</tr>
<tr>
    <td>Rule Name<br/>
        <span class="metaInfo">optional</span>
    </td>
    <td><g:textField id="name"
            onkeypress="return handleReturnForXmlCreation(event);"
            onfocus="\$('name').setStyle({color: 'black'})"
            onblur="\$('nameBackup').value = \$('name').value"
            class="preFilledField" type="text" name="name"
            value="${(namePreset || messagePreset) ? namePreset.encodeAsHTML() : 'confusion of bed/bad'}"/>
        <!--<br/>
        <span class="metaInfo">Example: confusion of bed/bad</span>-->
    </td>
</tr>
<tr>
    <td></td>
    <td>
        <g:submitToRemote name="createXmlButton" onLoading="startLoad('createXmlSpinner')" onComplete="stopLoad('createXmlSpinner')" action="createXml" update="xml" value="Create XML"/>
        <img id="createXmlSpinner" style="display: none" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
    </td>
</tr>
</table>

<script type="text/javascript">
    document.ruleForm.message.select();
</script>

<div id="xml"></div>
