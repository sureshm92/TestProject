/**
 * Created by Nargiz Mamedova on 6/19/2020.
 */

({
    doOnClick: function (component, event) {
        const currentMode = communityService.getCurrentCommunityMode();
        const itemValue = component.get('v.itemValue');

        if (currentMode.userMode === 'Participant') {
            if (!itemValue) {
                let modes = component.get('v.modes');
                let item = modes[0];
                if (item.subItems.length > 0) {
                    item = item.subItems[0];
                }
                component.set('v.itemValue', item);
            } else if (itemValue.delegateId === currentMode.currentDelegateId){
                component.set('v.itemValue', null);
            }
        }

        component.getEvent('onclick').fire();
        if (component.get('v.closeAfterClick')) {
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