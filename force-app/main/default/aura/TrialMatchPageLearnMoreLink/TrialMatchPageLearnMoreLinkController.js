/**
 * Created by Enugothula Srinath 
 * Date-21/05/2020
 */


({
    doInit: function(component,event, helper){
        component.set('v.initialized', true);
    },
    doGenerateReport: function (component, event, helper) {
        helper.uploadReportData(component, function () {
            window.setTimeout($A.getCallback(function() {
                    helper.generateLearnMorePDF(component);
            }), 100);
        })
    }
});