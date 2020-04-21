/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event, helper) {
        component.find('spinner').hide();
        var params = event.getParam('arguments');
        component.set('v.messageText', params.messageText);
        component.set('v.callback', params.callback);
        component.find('deleteDelegateDialog').show();
    },

    doYes: function (component, event, helper) {
        component.find('spinner').show();
        component.get('v.callback')();

        component.find('spinner').hide();
        component.find('deleteDelegateDialog').hide();
    },

    doNo: function (component, event, helper) {
        component.find('deleteDelegateDialog').hide();
    }
})