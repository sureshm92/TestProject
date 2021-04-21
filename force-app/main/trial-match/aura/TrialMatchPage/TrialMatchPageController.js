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
        var pdfData;
        if (component.get('v.isMobileApp')) {
            communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            );
            
            communityService.executeAction(
                component,
                'getBase64fromTrialMatchApexPage',
                {
                    peId: 'a0B1F000005ILEkUAO'                  
                },
                function (returnValue) {
                  alert(returnValue);
                  communityService.navigateToPage('mobile-pdf-viewer?pdfData='+returnValue);   
                }
            );
          
           return;
        }
        var partenrollid = component.get('v.partenrollid');
        var pageurl = window.location.href;
        if (pageurl.includes('gsk')) window.open('/gsk/apex/TrialMatchData?id=' + partenrollid, '_blank');
        else window.open('/apex/TrialMatchData?id=' + partenrollid, '_blank');
    }
});
