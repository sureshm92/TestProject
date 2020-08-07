({
    doInit: function (component, event, hepler) {
        if (!communityService.isInitialized()) return;
        var spinner = component.find('mainSpinner');
        spinner.show();
        if (communityService.getCurrentCommunityTemplateName() === $A.get("$Label.c.Janssen_Community_Template_Name")){
            communityService.navigateToPage('');
        }
        component.set('v.userMode', communityService.getUserMode());
        var trialId = communityService.getUrlParameter('id');
        component.set('v.trialId', trialId);
        var siteId = communityService.getUrlParameter('siteId');
        component.set('v.siteId', siteId);
        if(!communityService.isDummy()) {
        component.set('v.isInitialized', true);
            } else {
            component.find('builderStub').setPageName(component.getName());
        }
        spinner.hide();
    },
})