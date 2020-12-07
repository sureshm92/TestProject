({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        var spinner = component.find('mainSpinner');
        spinner.show();
        var Usermode = communityService.getUserMode();
        component.set('v.userMode',Usermode);
        var commName = communityService.getCurrentCommunityName();
        if(commName.includes('Janssen'))
        component.set('v.isJanssen',true);
        var trialId = communityService.getUrlParameter('id');
        component.set('v.trialId', trialId);
        var siteId = communityService.getUrlParameter('siteId');
        component.set('v.siteId', siteId);
        communityService.executeAction(
            component,
            'getInitData',
            {
                trialId: trialId,
                siteId: siteId,
                userMode: Usermode,
                delegateId: communityService.getDelegateId(),
                sponsorName: communityService.getCurrentCommunityTemplateName()
            },
            function (returnValue) {
                var initData = JSON.parse(returnValue);
                component.set('v.peFilterData', initData.peFilterData);
                component.set('v.isDataLoaded', true);
                spinner.hide();
            }
        );
    },

    onClickMyReferrals: function (component, event, helper) {
        communityService.navigateToPage('my-referrals');
    },
    onClickCardView: function (component, event, helper) {
        communityService.navigateToPage('my-referrals');
    }
});