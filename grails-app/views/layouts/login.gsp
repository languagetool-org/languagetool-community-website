<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title><g:message code="ltc.login.title"/></title>
        <g:render template="/layouts/css"/>
        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <g:layoutHead />
        <r:layoutResources/>
    </head>
    <body>

        <div class="header">&nbsp;
        
            <h1 class="logo"><a href="${request.getContextPath()}/"><g:message code="ltc.login.title"/></a></h1>
            
            <div class="login">&nbsp;</div>
        
        </div>
        
        <g:layoutBody />

        <g:render template="/layouts/analytics"/>
        
    </body>
</html>