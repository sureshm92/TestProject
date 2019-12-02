/**
 * Created by Yehor Dobrovolskyi
 */({
    setResourceAction: function (component, resourceWrapper) {
        component.set('v.resourceWrapper', resourceWrapper);
        console.log(resourceWrapper);
        communityService.executeAction(component, 'setResourceAction', {
            resourceId: resourceWrapper.resource.Id,
            isFavorite: resourceWrapper.isFavorite,
            isVoted: resourceWrapper.isVoted
        });
    },
})