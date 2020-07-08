({
    pageNavigate: function (event, pageName) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": pageName
        });
        urlEvent.fire();
    },
})