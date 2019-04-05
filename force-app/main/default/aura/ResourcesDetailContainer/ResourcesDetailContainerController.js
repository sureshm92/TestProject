({
    doInit: function (component, event, helper) {
        let spinner = component.find('spinner');
        if(spinner){ spinner.show(); }

        let resourceType = communityService.getUrlParameter('resourceType');
        let recId = communityService.getUrlParameter('id');
        let resId = communityService.getUrlParameter('resId');
        let homePage = document.location.hash;

        communityService.executeAction(component, 'getResourcesById', {
            resourceId: resId,
            resourceType: resourceType
        }, function (returnValue) {
            if (!returnValue.errorMessage) {
                component.set("v.resourceWrapper", returnValue.wrappers[0]);
                component.set("v.errorMessage", "");
            } else {
                component.set("v.errorMessage", returnValue.errorMessage);
            }
            let spinner = component.find('spinner');
            if(spinner){ spinner.hide(); }
        });

        if (resourceType) {
            component.set("v.resourceType", resourceType);
        }

        if (homePage === '#home') {
            component.set('v.backStudy', '');
        } else if (recId) {
            component.set("v.backStudy", "s/study-workspace?id=" + recId + "&tab=tab-resources");
        }

    },
})
