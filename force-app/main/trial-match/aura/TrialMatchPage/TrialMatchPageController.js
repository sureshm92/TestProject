/**
 * Created by Sravani Dasari
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            component.find('mainSpinner').show();

            communityService.executeAction(component, 'getMatchCTPs', null, function (data) {
                component.set('v.trialmatchCTPs', data.trialmatchctps);
                component.set('v.peid', data.trialmatchctps.participantid);
                component.set('v.initialized', true);

                if (!String.format) {
                    String.format = function (format) {
                        var args = Array.prototype.slice.call(arguments, 1);
                        return format.replace(/{(\d+)}/g, function (match, number) {
                            return typeof args[number] != 'undefined' ? args[number] : match;
                        });
                    };
                }
            }, null, function () {
                component.find('mainSpinner').hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doGenerateReport: function (component, event, helper) {
        var peid = component.get('v.peid');
        window.open('trial-match-print-view?id=' + peid, '_blank');
    }
});