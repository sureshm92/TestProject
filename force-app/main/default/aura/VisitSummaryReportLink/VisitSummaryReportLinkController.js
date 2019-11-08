/**
 * Created by Leonid Bartenev
 */

({
    doInit: function(component){
        component.set('v.initialized', true);
    },

    doGenerateReport: function (component, event, helper) {
        helper.uploadReportData(component, function () {
            window.setTimeout($A.getCallback(function() {
                    helper.generateReport(component);
            }), 100);
        })
    }

});