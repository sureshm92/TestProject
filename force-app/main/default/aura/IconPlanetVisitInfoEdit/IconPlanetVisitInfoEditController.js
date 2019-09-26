/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        helper.getIconsResourceName(component,event,helper);
        helper.getIconDetails(component, event, helper);
    },
    saveIconsLegend: function (component, event, helper) {
        let params = event.getParam('arguments');
        helper.saveIconsLegend(component, event, helper, params.callback);
    },
    closeModal: function (component, event, helper) {
        let params = event.getParam('arguments');
        let callback;
        if (params) {
            callback = params.callback;
            callback();
        }
    },
    save: function (component, event, helper) {
        let params = event.getParam('arguments');
        let callback;
        let errorCallback;
        if (params) {
            callback = params.callback;
            errorCallback = params.errorCallback;
        }
        helper.saveIconsLegend(component, event, helper,callback,errorCallback);

    },

});