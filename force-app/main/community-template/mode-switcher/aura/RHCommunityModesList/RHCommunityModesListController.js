/**
 * Created by Andrii Kryvolap
 */
({
    doToggleGroup: function (component, event, helper) {
        let communityModes = component.get('v.communityModes');
        let selectedGroupId = event.currentTarget.dataset.groupId;

        for (let i=0; i<communityModes.rhModeItems.length; i++ ){
            if (communityModes.rhModeItems[i].itemType === selectedGroupId){
                communityModes.rhModeItems[i].isCollapsed = !communityModes.rhModeItems[i].isCollapsed;
            }
        }
        component.set('v.communityModes', communityModes);
    },

    doOnclick: function (component, event, helper) {
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParam('source', event.getSource());
        onclickEvent.fire();
    }
});