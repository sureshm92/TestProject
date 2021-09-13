/**
 * Created by Sravani Dasari
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            component.find('mainSpinner').show();

            communityService.executeAction(
                component,
                'getMatchCTPs',
                null,
                function (data) {
                    component.set('v.trialmatchCTPs', data.trialmatchctps);
                    component.set('v.partenrollid', data.partenrollid);
                    component.set('v.initialized', true);

                    if (!String.format) {
                        String.format = function (format) {
                            var args = Array.prototype.slice.call(arguments, 1);
                            return format.replace(/{(\d+)}/g, function (match, number) {
                                return typeof args[number] != 'undefined' ? args[number] : match;
                            });
                        };
                    }
                },
                null,
                function () {
                    component.find('mainSpinner').hide();
                }
            );
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doGenerateReport: function (component, event, helper) {
        let partenrollid = component.get('v.partenrollid');
        if (component.get('v.isMobileApp')) {
            communityService.executeAction(
                component,
                'getBase64fromTrialMatchApexPage',
                {
                    peId: partenrollid
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
            window.open('/gsk/apex/TrialMatchData?id=' + partenrollid, '_blank');
        else window.open('/apex/TrialMatchData?id=' + partenrollid, '_blank');
    }
});
