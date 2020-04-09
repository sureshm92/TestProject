/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        if(!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            if (communityService.getUserMode() !== 'HCP') communityService.navigateToPage('');
            let spinner = component.find('mainSpinner');
            spinner.show();
            let recId = communityService.getUrlParameter('id');
            let hcpeId = communityService.getUrlParameter('hcpeid');
            let delegateId = communityService.getDelegateId();

            if (recId) {
                component.set('v.trialId', recId);
                component.set('v.hcpeId', hcpeId);
                communityService.executeAction(component, 'getInitData', {
                    trialId: recId,
                    hcpeId: hcpeId,
                    delegateId: delegateId
                }, function (returnValue) {
                    let initData = JSON.parse(returnValue);
                    let searchData = {
                        participantId: ''
                    };
                    component.set('v.searchData', searchData);
                    component.set('v.hcpEnrollment', initData.hcpEnrollment);
                    component.set('v.hcpContact', initData.hcpContact);
                    component.set('v.accessUserLevel', initData.delegateAccessLevel);
                    component.set('v.trial', initData.trial);
                    component.set('v.actions', initData.actions);
                }, null, function () {
                    spinner.hide();
                })
            }
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },

    doStartMRR: function (component) {
        communityService.navigateToPage('medical-record-review?id=' + component.get('v.trialId'));
    },

    doReferPatient: function (component) {
        communityService.navigateToPage('referring?id=' + component.get('v.trialId') + '&peid=' + component.get('v.searchResult').pe.Id);
    },

    doClearForm: function (component) {
        component.set('v.searchResult', undefined);
        component.set('v.searchData', {
            participantId : ''
        });
        component.set('v.mrrResult', 'Pending');
    },

    doMRRResultChanged: function () {
        window.scrollTo(0, 0);
    }
});