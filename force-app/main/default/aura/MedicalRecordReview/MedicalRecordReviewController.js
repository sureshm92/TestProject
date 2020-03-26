/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        if(!communityService.isInitialized()) return;
        if(communityService.getUserMode() !== 'HCP') communityService.navigateToPage('');
        var spinner = component.find('mainSpinner');
        spinner.show();
        var recId = communityService.getUrlParameter("id");
        var hcpeId = communityService.getUrlParameter("hcpeid");
        var delegateId = communityService.getDelegateId();

        if(recId){
            component.set('v.trialId', recId);
            component.set('v.hcpeId', hcpeId);
            communityService.executeAction(component, 'getInitData', {
                trialId: recId,
                hcpeId: hcpeId,
                delegateId : delegateId
            }, function (returnValue) {
                var initData = JSON.parse(returnValue);
                var searchData = {
                    participantId : ''
                };
                component.set('v.searchData', searchData);
                component.set("v.hcpEnrollment", initData.hcpEnrollment);
                component.set("v.hcpContact", initData.hcpContact);
                component.set("v.accessUserLevel", initData.delegateAccessLevel);
                component.set("v.trial", initData.trial);
                component.set("v.actions", initData.actions);
                spinner.hide();
            }, null, function () {
                spinner.hide();
            })
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


})