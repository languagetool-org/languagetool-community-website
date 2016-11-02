<html>
<head>
    <meta name="layout" content="main" />
    <title>Example Sentences with Errors - LanguageTool</title>
</head>
<body>

<div class="body">

    <h1>Example Sentences with Errors</h1>
    
    <g:if test="${examples.size() == 0}">
        Sorry, we don't have example sentences yet for ${language.encodeAsHTML()}.
        Maybe you'd like to <a href="https://languagetool.org/support/">send us some?</a>
    </g:if>
    <g:else>
        <p>Click on one of the sentences to start the rule editor.</p>

        <ul style="margin-top: 10px">
            <g:each in="${examples}" var="example">
                <li><g:link action="index" params="${[wrong: example, lang: language.getShortCode()]}">${example.encodeAsHTML()}</g:link></li>
            </g:each>
        </ul>
    </g:else>

</div>

</body>
</html>
