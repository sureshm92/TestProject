/**
 * Created by Yehor Dobrovolskyi
 */({
    setResourceAction: function (component, resource) {
        component.set('v.resource', resource);
        console.log(resource);
        communityService.executeAction(component, 'setResourceAction', {
            resourceId: resource.resourceId,
            isFavorite: resource.isFavorite,
            isVoted: resource.isVoted
        });
    },
})