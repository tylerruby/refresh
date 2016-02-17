$(document).ready(function() {
    var app_link = $("#app_link");
    var link;

    if (!app_link) {
        return;
    }

    if (isMobile.Android()) {
        link = "http://www.google.com";
    } else if (isMobile.iOS()) {
        link = "http://www.apple.com";
    }

    if (link) {
        $(app_link).attr("href", link);
        $(app_link).attr("target", "_blank");
    }
});

