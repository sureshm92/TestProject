/**
 * Created by Enugothula Srinath
 * Date-21/05/2020
 */

({
    doInit: function (component, event, helper) {
        component.set('v.initialized', true);
    },

    doGenerateReport: function (component, event, helper) {
        if (component.get('v.initialized') && component.get('v.isMobileApp')) {
            communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            );
            return;
        }
      /**  helper.uploadReportData(component, function () {
            window.setTimeout(
                $A.getCallback(function () {
                    helper.generateLearnMorePDF(component);
                }),
                100
            );
        }); **/
        const ctpId = component.get('v.ctpId');    
        var pageurl = window.location.href;
        if (pageurl.includes('gsk')) window.open('/gsk/apex/TrialMatchLearnMorePage?CTPId='+ctpId);
        else window.open('/apex/TrialMatchLearnMorePage?CTPId='+ctpId);
    }
});