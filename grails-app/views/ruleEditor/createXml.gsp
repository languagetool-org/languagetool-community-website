<table style="border: 0px" xmlns="http://www.w3.org/1999/html">
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

            <p style="width:450px;margin-top: 0px; margin-bottom: 5px">This is the XML that you need to add inside a <tt>&lt;category&gt;</tt> in the file<br/>
                <tt>rules/${language.getShortName()}/grammar.xml</tt>. After re-starting LanguageTool, the rule
                will work locally for you.</p>

            <pre style="background-color: #eeeeee; padding: 10px">${xml.encodeAsHTML().replaceAll("&gt;(.*?)&lt;", "&gt;<strong>\$1</strong>&lt;")}</pre>

            <p style="width:450px;margin-top: 5px">LanguageTool rules can be much more powerful - this page
            can only create simple rules. See <a target="devdocumentation" href="http://www.languagetool.org/development/">our development documentation</a>
            for more features.</p>

        </g:else>
    </td>
</tr>
</table>
