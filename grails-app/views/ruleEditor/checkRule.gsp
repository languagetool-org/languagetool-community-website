
<g:if test="${searcherResult}">
    <g:set var="sentencesChecked" value="${formatNumber(number:searcherResult.getCheckedSentences(), type: 'number')}"/>

    <g:if test="${searcherResult.getMatchingSentences().size() == 0}">

        <p style="width:700px;">We've checked your pattern against ${sentencesChecked} sentences
        from <a href="http://www.wikipedia.org">Wikipedia</a> and found no matches.</p>

    </g:if>
    <g:else>

        <p style="width:700px;">We've checked your pattern against ${sentencesChecked} sentences
        from <a href="http://www.wikipedia.org">Wikipedia</a> and found the following matches.
        Please consider modifying your rule if these matches are false alarms.
        As this page does not support our full rule syntax you might want to learn
        more in <a target="devdocumentation" href="http://www.languagetool.org/development/">our development
        documentation</a>.</p>

        <ul style="margin-bottom: 30px">
            <g:each in="${searcherResult.getMatchingSentences()}" var="matchingSentence">
                <g:each in="${matchingSentence.getRuleMatches()}" var="match">
                    <li>
                        <span class="exampleSentence">${org.languagetool.gui.Tools.getContext(
                            match.getFromPos(), match.getToPos(),
                            matchingSentence.getSentence(),
                            100, "<span class='errorMarker'>", "</span>", true)}</span>
                    </li>
                </g:each>
            </g:each>
        </ul>

    </g:else>

</g:if>
<g:else>
</g:else>

<table style="border: 0px">
<tr>
    <td valign="top" width="150">Error Message</td>
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

<br/>
<div id="xml"></div>
