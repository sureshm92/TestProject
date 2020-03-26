/**
 * Created by Leonid Bartenev
 */
({
    doMenuItemSelected: function (component, event, helper) {
        const menuItemCmp = event.getSource();
        const translationItem = menuItemCmp.get('v.itemValue');
        helper.viewResource(component.get('v.resourceWrapper').resource, translationItem.languageCode);
    },

    doNavigateDefault: function (component, event, helper) {
        const resourceWrapper = component.get('v.resourceWrapper');
        helper.viewResource(resourceWrapper.resource, resourceWrapper.translations[0].languageCode);
    }

})