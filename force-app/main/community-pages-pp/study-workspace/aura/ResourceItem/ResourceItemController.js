(
    {
        navigateToPage : function (component, event, helper) {
            var resourceWrapper = component.get("v.resourceWrapper");
            var recId = communityService.getUrlParameter('id');
            communityService.navigateToPage("resources?resourceType=" + resourceWrapper.resource.RecordType.DeveloperName + "&id=" + recId + '&resId=' + resourceWrapper.resource.Id + '&ret=' + communityService.createRetString());
        },

        doFavorite : function (component, event, helper) {
            var resourceWrapper = component.get('v.resourceWrapper');
            resourceWrapper.isFavorite = !resourceWrapper.isFavorite;
            helper.setResourceAction(component, resourceWrapper);
        },

        doVote : function (component, event, helper) {
            var resourceWrapper = component.get('v.resourceWrapper');
            resourceWrapper.isVoted = !resourceWrapper.isVoted;
            helper.setResourceAction(component, resourceWrapper);
        },
    }
)