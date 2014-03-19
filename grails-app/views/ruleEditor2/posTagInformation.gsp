<html>
<head>
    <meta name="layout" content="main" />
    <title>LanguageTool POS tag information</title>
</head>
<body>

<div class="body">

    <g:render template="/languageSelection"/>

    <p>${language.getName()} does not have an internal part-of-speech dictionary in LanguageTool yet.
    That means ${language.getName()} error detection rules can refer to words, but not to classes of words 
    like "all plural nouns". If you want to improve LanguageTool to support your language more extensively, please
    <a href="http://wiki.languagetool.org/make-languagetool-better">join us</a>.</p>

</div>
</body>
</html>
