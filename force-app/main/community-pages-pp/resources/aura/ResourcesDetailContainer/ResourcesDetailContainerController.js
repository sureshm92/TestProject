({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        if (!communityService.isDummy()) {
            component.find('details-spinner').show();
            let resourceType = communityService.getUrlParameter('resourceType');
            let resId = communityService.getUrlParameter('resId');
            let retString = communityService.getUrlParameter('ret');
            component.set('v.lang', communityService.getUrlParameter('lang'));
            communityService.executeAction(component, 'getResourcesById', {
                resourceId: resId,
                resourceType: resourceType
            }, function (returnValue) {
                if (!returnValue.errorMessage) {
                    component.set('v.resourceWrapper', returnValue.wrappers[0]);

                    component.set('v.errorMessage', '');

                } else {

                    component.set('v.errorMessage', returnValue.errorMessage);
                }

                component.find('details-spinner').hide();

                component.set('v.initialized', true);

            });

            if (resourceType === 'Article') {

                component.set('v.bigTitle', $A.get("{!$Label.c.Resources_Article}"));

            } else if (resourceType === 'Video') {

                component.set('v.bigTitle', $A.get("{!$Label.c.Resources_Video}"));

            } else if (resourceType === 'Study_Document') {

                component.set('v.bigTitle', $A.get("{!$Label.c.Resources_Study_Document}"));

            }

            if (retString) {

                let retPage = communityService.getRetPage(retString);

                component.set('v.backStudy', retPage);

            } else {

                component.set('v.backStudy', '');

            }
        } else {

            component.find('builderStub').setPageName(component.getName());

        }
    }
});
