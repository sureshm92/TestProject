/**
 * Created by Olga Skrynnikova on 6/16/2020.
 */

({
    doToggleGroup: function (component, event, helper) {
        let communityModes = component.get('v.communityModes');
        let selectedKey = event.currentTarget.dataset.groupId;
        let ppstr = 'pp';
        let rhstr = 'rh';
        if(selectedKey == ppstr) communityModes.isPPItemsCollapsed = !communityModes.isPPItemsCollapsed;
        if(selectedKey == rhstr) communityModes.isRHItemsCollapsed = !communityModes.isRHItemsCollapsed;
        component.set('v.communityModes', communityModes);
    },

});