/**
 * Created by Leonid Bartenev
 */

({
    doInit: function (component) {
        component.set('v.initialized', true);
    },

    doGenerateReport: function (component, event, helper) {
        if (component.get('v.initialized') && component.get('v.isMobileApp')) {
            communityService.showInfoToast(
                'Info!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            );
            return;
        }
        helper.uploadReportData(component, function () {
            window.setTimeout(
                $A.getCallback(function () {
                    helper.generateReport(component);
                }),
                100
            );
        });
    }
});
