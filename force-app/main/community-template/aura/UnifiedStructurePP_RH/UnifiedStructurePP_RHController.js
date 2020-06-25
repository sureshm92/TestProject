/**
 * Created by Olga Skrynnikova on 6/16/2020.
 */

({
    doToggleGroup: function (component, event, helper) {
        let communityModes = component.get('v.communityModes');
        let selectedKey = event.currentTarget.dataset.groupId;
        if(selectedKey === 'pp') communityModes.isPPItemsCollapsed = !communityModes.isPPItemsCollapsed;
        if(selectedKey === 'rh') communityModes.isRHItemsCollapsed = !communityModes.isRHItemsCollapsed;
        component.set('v.communityModes', communityModes);
    },

    doSelectItem: function (component, event, helper) {
        const item = event.getParam('source');
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParam('source', item);
        onclickEvent.fire();
    },

    doOnClick: function (component, event) {
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParam('source', event.getSource());
        onclickEvent.fire();
    }
});