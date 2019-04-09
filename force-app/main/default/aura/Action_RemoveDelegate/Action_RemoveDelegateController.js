/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event, hepler) {
        component.find('spinner').hide();
        var params = event.getParam('arguments');
        component.set('v.delegateContact', params.delegateContact);
        component.set('v.messageText', params.messageText);
        component.set('v.callback', params.callback);
        component.find('deleteDelegateDialog').show();
    },

    doYes: function (component, event, hepler) {
        component.find('spinner').show();
        communityService.executeAction(component, 'removePatientDelegate', {
            delegate: JSON.stringify(component.get('v.delegateContact'))
        }, function () {
            var callback = component.get('v.callback');
            component.find('deleteDelegateDialog').hide();
            if(callback) callback();
        });
    },

    doNo: function (component, event, hepler) {
        component.find('deleteDelegateDialog').hide();
    }
})