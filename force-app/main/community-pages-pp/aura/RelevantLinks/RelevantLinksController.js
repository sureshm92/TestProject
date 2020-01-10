/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

({
    doInit: function (component, event, helper) {
        console.log('init');
        communityService.executeAction(component, 'getInitData', {},
            function (initData) {
            component.set('v.isAvailable', initData.linksAvailable);
            console.log('linksAvailable' + JSON.stringify(initData.linksAvailable));
                if(component.get("v.isAvailable")){
                component.set('v.links', initData.resources);
                console.log('links' + JSON.stringify(initData.resources));
                component.find('spinner').hide();
            }
        });
    }
});