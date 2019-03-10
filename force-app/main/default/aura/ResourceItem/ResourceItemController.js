(
    {
        navigateToPage : function (component, event, helper) {
            var resource = component.get("v.resource");
            var recId = communityService.getUrlParameter('id');
            communityService.navigateToPage("resources?resourceType=" + resource.type + "&id=" + recId + '&resId=' + resource.resourceId);
        },

        doFavorite : function (component, event, helper) {
            var resource = component.get('v.resource');
            resource.isFavorite = !resource.isFavorite;
            helper.setResourceAction(component, resource);
        },

        doVote : function (component, event, helper) {
            var resource = component.get('v.resource');
            resource.isVoted = !resource.isVoted;
            helper.setResourceAction(component, resource);
        },
    }
)