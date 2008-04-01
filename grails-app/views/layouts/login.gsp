<html>
    <head>
        <title><g:layoutTitle default="Grails" /></title>
        <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'main.css')}" />
        <link rel="shortcut icon" href="${createLinkTo(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
        <g:layoutHead />
        <g:javascript library="application" />
    </head>
    <body>

        <h1 class="logo"><a href="${createLinkTo(dir:'',file:'')}">LanguageTool Community</a></h1>
        
        <g:layoutBody />		
    </body>	
</html>