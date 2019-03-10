({
    doInit : function (component, event, helper) {

        // let resourceType = new URL(window.location.href).searchParams.get("resourceType");
        let resourceType = communityService.getUrlParameter('resourceType');

        if (resourceType) {
            component.set("v.resourceType", resourceType);
        }
        // component.set("v.backStudy", document.referrer);

        let recId = communityService.getUrlParameter('id');
        if (recId) {
            component.set("v.backStudy", "/s/study-workspace?id=" + recId + "&tab=tab-resources");
        }
    },
})