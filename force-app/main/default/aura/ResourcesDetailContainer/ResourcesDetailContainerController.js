({
    doInit : function (component, event, helper) {

        // let resourceType = new URL(window.location.href).searchParams.get("resourceType");
        let resourceType = communityService.getUrlParameter('resourceType');
        let recId = communityService.getUrlParameter('id');
        let resId = communityService.getUrlParameter('resId');

        communityService.executeAction(component, 'getResourcesById', {
            resourceId: resId
        }, function (returnValue) {
            component.set("v.resource", returnValue[0]);
        }, function (errorResponse) {
            //todo add logic for handling errors like "no articles available" etc.
        });

        if (resourceType) {
            component.set("v.resourceType", resourceType);
        }
        // component.set("v.backStudy", document.referrer);

        if (recId) {
            component.set("v.backStudy", "s/study-workspace?id=" + recId + "&tab=tab-resources");
        }
    },
})