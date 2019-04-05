({
    doInit: function (component, event, helper) {

        // let resourceType = new URL(window.location.href).searchParams.get("resourceType");
        let resourceType = communityService.getUrlParameter('resourceType');
        let recId = communityService.getUrlParameter('id');
        let resId = communityService.getUrlParameter('resId');
        let homePage = document.location.hash;

        communityService.executeAction(component, 'getResourcesById', {
            resourceId: resId
        }, function (returnValue) {
            component.set("v.resourceWrapper", returnValue[0]);
        }, function (errorResponse) {
            //todo add logic for handling errors like "no articles available" etc.
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