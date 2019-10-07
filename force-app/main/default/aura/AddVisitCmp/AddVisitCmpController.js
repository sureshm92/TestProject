/**
 * Created by AlexKetch on 7/26/2019.
 */
({

    shiftRight: function (component, event, helper) {
        helper.shiftRight(component, event, helper);
    },
    shiftLeft: function (component, event, helper) {
        helper.shiftLeft(component, event, helper);

    },
    closeModal: function (component, event, helper) {
        let params = event.getParam('arguments');
        let callback;
        if (params) {
            callback = params.callback;
            callback();
        }
    },
    handleSuccess: function (component, event, helper) {
        helper.getCallback()(component.find('mainSpinner'));
    },
    save: function (component, event, helper) {
        debugger;
        let params = event.getParam('arguments');
        let callback;
        let errorCallback;
        if (params) {
            callback = params.callback;
            errorCallback = params.errorCallback;
        }
        component.find('mainSpinner').show();

        let icons = component.get('v.selectedIcons');
        let iconsName = [];
        for (let i = 0; i < icons.length; i++){
            iconsName.push(icons[i].id);
        }
        let strCoins = iconsName.join(';');
        component.find('splittedIcons').set('v.value', strCoins);
        let name = component.find('nameId').get("v.value");
        if (name === null) {
            component.find('mainSpinner').hide();
            errorCallback(function () {
                helper.notify({
                    "title": "Name Is Empty",
                    "message": "Complete Name field.",
                    "type": "error"
                })
            });
        } else {
            helper.addCallback(callback);
            component.find('editForm').submit();
        }
    },

})