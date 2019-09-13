({
    doInit: function (component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.ignoreUpdates", true);
        var selectedParent = component.get("v.piSelectedParent");
        var URLParentId = communityService.getUrlParameter('id');
        if((selectedParent === undefined || selectedParent === '') && URLParentId !== undefined && URLParentId !=='' ){
            selectedParent = URLParentId;
        }
        communityService.executeAction(component, 'getInitData', {
            userMode: component.get('v.userMode'),
            parentId: selectedParent?selectedParent:communityService.getDelegateId()
        }, function (returnValue) {
            debugger;
            var initData = JSON.parse(returnValue);
            component.set("v.delegates", initData.delegates);
            component.set("v.delegateOptions", initData.delegateOptions);
            component.set("v.showSpinner", false);
            component.set("v.hasStudies", initData.hasStudies);
            selectedParent = component.get("v.piSelectedParent");
            if(selectedParent === undefined || selectedParent === ''){
                component.set("v.piDelegateParents", initData.piDelegateParents);
                component.set("v.piSelectedParent", initData.piSelectedParent);
            }
            component.set("v.ignoreUpdates", false);

        })
    },

    inviteTeamMembers: function (component, event, helper) {
        var selectedParent = component.get("v.piSelectedParent");
        communityService.navigateToPage('new-team-member'+(selectedParent?'?id='+selectedParent:''));
    }

})