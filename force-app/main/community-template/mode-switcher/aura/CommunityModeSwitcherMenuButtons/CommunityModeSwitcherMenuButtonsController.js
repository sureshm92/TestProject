/**
 * Created by Andrii Kryvolap
 */
({
    doRefresh: function (component, event, helper) {
        helper.initButtonsMap();
        let switcherType = component.get('v.type');
        let buttonItems = helper.buttonsMap[switcherType];
        component.set('v.buttonItems', buttonItems);
    },

    doNavigateToItem: function (component, event, helper) {
        const item = event.getSource();
        const itemValue = item.get('v.itemValue');
        communityService.navigateToPage(itemValue);
        component.set('v.reset', true);
        component.set('v.reset', false);
    }
})