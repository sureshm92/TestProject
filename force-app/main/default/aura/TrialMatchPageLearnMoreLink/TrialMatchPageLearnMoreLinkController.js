/**
 * Created by Sravani Dasari
 * Date-21/05/2020
 */

({
    doGenerateReport: function (component, event, helper) {
        const ctpId = component.get('v.ctpId');
        if (component.get('v.isMobileApp')) {
            communityService.executeAction(
                component,
                'getBase64LearnMoreData',
                {
                    ctpId: ctpId
                },
                function (returnValue) {
                    communityService.navigateToPage('mobile-pdf-viewer?pdfData=' + returnValue);
                },
                function (error) {
                    communityService.showToast(
                        'error',
                        'error',
                        $A.get('$Label.c.TST_Something_went_wrong')
                    );
                    communityService.logErrorFromResponse(error);
                }
            );
            return;
        }
        var pageurl = window.location.href;
        if (pageurl.includes('gsk'))
            window.open('/gsk/apex/TrialMatchLearnMorePage?CTPId=' + ctpId);
        else window.open('/apex/TrialMatchLearnMorePage?CTPId=' + ctpId);
    }
});
