<!doctype html>
<html ng-app="ruleEditor">
    <head>
        <title><g:layoutTitle default="Grails" /></title>
        <link type="text/css" rel="stylesheet" href="${resource(dir:'css',file:'main.css')}" />
        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <g:layoutHead />
        <r:layoutResources/>
    </head>
    <body ng-controller="RuleEditorCtrl">

        <g:render template="/layouts/header"/>

        <div id="mainContent">
            <g:layoutBody />
        </div>

        <g:render template="/layouts/analytics"/>

    </body>
</html>