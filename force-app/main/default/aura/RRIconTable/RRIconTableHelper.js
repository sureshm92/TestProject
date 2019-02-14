/**
 * Created by Leonid Bartenev
 */
({
    getIconsNames: function (iconsURL, callback) {
        var x = new XMLHttpRequest();
        x.open("GET", iconsURL, true);
        x.onreadystatechange = function () {
            if (x.readyState === 4 && x.status === 200) {
                var doc = x.responseXML;
                var symbols = doc.getElementsByTagName('symbol');
                var symbolNames = [];
                for(var i= 0; i < symbols.length; i++) symbolNames.push(symbols[i].id);
                callback(symbolNames);
            }
        };
        x.send(null);
    },
    getInfoForFilterInfoAndSummaryInfo: function (component) {
        var action = component.get('c.getFilterInfoAndSummaryInfo');
        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS" && response.getReturnValue()) {

                var initData = JSON.parse(response.getReturnValue());

                component.set("v.summaryContainers", initData.summaryContainers);
                component.set("v.filterInfo", initData.filterInfo);
            } else {
                communityService.logErrorFromResponse(response);
            }
        });
        $A.enqueueAction(action);
    }
})