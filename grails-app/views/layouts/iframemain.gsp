<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title><g:layoutTitle default="Grails" /></title>
        <link type="text/css" rel="stylesheet" href="${resource(dir:'css',file:'iframe.css')}" />
        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <g:layoutHead />
        <g:javascript library="application" />
    </head>
    <body>

        <div id="mainContent">
            <g:layoutBody />
        </div>

    <!-- Piwik -->
    <script type="text/javascript">
    var pkBaseURL = (("https:" == document.location.protocol) ? "https://openthesaurus.stats.mysnip-hosting.de/" : "http://openthesaurus.stats.mysnip-hosting.de/");
    document.write(unescape("%3Cscript src='" + pkBaseURL + "piwik.js' type='text/javascript'%3E%3C/script%3E"));
    </script><script type="text/javascript">
    try {
    var piwikTracker = Piwik.getTracker(pkBaseURL + "piwik.php", 3);
    piwikTracker.trackPageView();
    piwikTracker.enableLinkTracking();
    } catch( err ) {}
    </script><noscript><p><img src="http://openthesaurus.stats.mysnip-hosting.de/piwik.php?idsite=3" style="border:0" alt="" /></p></noscript>
    <!-- End Piwik Tracking Code -->

    </body>	
</html>