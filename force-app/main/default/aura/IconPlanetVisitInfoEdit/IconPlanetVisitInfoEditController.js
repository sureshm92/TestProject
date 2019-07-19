/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        helper.getIconsResourceName(component,event,helper);
        helper.getIconDetails(component, event, helper);
    },
    saveIconsLegend: function (component, event, helper) {
        helper.saveIconsLegend(component, event, helper);

    },

});