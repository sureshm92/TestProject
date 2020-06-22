/**
 * Created by Andrii Kryvolap
 */
({
    doToggleGroup: function (component, event, helper) {
        let communityModes = component.get('v.communityModesList');
        let selectedGroupId = event.currentTarget.dataset.groupId;

        for (let i=0; i<communityModes.length; i++ ){
            if (communityModes[i].itemType === selectedGroupId){
                communityModes[i].isCollapsed = !communityModes[i].isCollapsed;
            }
        }
        component.set('v.communityModesList', communityModes);
    },

    doOnclick: function (component, event, helper) {
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParam('source', event.getSource());
        onclickEvent.fire();
    }
});