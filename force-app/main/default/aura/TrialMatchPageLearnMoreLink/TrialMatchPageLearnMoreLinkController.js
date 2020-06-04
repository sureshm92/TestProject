/**
 * Created by Enugothula Srinath 
 * Date-21/05/2020
 */


({
    doInit: function(component,event, helper){
        component.set('v.initialized', true);
        helper.uploadReportData(component, function () {
            window.setTimeout($A.getCallback(function() {
                    helper.generateLearnMorePDF(component);
            }), 1000);
        })
    }
});