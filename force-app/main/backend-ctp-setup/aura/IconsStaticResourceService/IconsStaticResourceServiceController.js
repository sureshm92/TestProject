/**
 * Created by dmytro.fedchyshyn on 16.07.2019.
 */

({
    doInit: function(component, event, helper){
        helper.getIconsUrl(component,event)
    },

    getIconsData: function (component, event, helper) {
        let iconsData = helper.getIconsNameAndDetail(component, event);
        return iconsData;
    },

    getIconsUrl: function (component, event, helper) {
        return component.get("v.iconsURL");
    }
});