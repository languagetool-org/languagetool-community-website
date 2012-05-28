<table style="border: 0px">
<tr>
    <td width="150"></td>
    <td>

        <div class="errors">There are problems with your rule:

            <ul>
                <g:each in="${problems}" var="problem">
                    <li>${problem.encodeAsHTML()}</li>
                </g:each>
            </ul>

        </div>

        <p style="width:450px;margin-top: 5px">The examples sentences are used to test your rule. Your first
        example sentence should contain the error so it can be found with the "Wrong words" pattern.
        The second example sentence should not contain the error.
        If you need help, <a href="http://www.languagetool.org/forum/">please ask in our forum</a>.</p>

        <g:if test="${hasRegex}">
            <p style="width:450px;margin-top: 5px">Note that you have used special characters like the dot (<tt>.</tt>),
            a question mark (<tt>?</tt>), or similar. This means that the word with that character is interpreted
            as a <a href="http://en.wikipedia.org/wiki/Regular_expression">regular expression</a>. If you
            don't want that you have to write your XML manually for now, as this tool sometimes cannot safely
            tell what you mean by those characters.</p>
        </g:if>

    </td>
</tr>
</table>