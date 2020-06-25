/**
 * Created by Nargiz Mamedova on 6/19/2020.
 */

({
    doOnClick: function (component, event) {
        if(!component.get('v.itemValue')){
            const currentMode = communityService.getCurrentCommunityMode();
            if (currentMode.userMode === 'Participant') {
                let modes = component.get('v.modes');
                let item = modes[0];
                if(modes[0].subItems.length > 0) {
                    item = modes[0].subItems[0];
                }
                component.set('v.itemValue', item);
            }
        }

        component.getEvent('onclick').fire();
        if(component.get('v.closeAfterClick')){
            var menuSelectEvent = component.getEvent('menuSelect');
            menuSelectEvent.setParams({
                selectedItem: component,
                'hideMenu': true
            });
            menuSelectEvent.fire();
        }

        event.stopPropagation();
    }
});