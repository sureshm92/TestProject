/**
 * Created by Igor Malyuta on 16.04.2019.
 */
({
    doExec : function (component, event, helper) {
        var params = event.getParam('arguments');
        component.set('v.callback', $A.getCallback(params.callback));
        var popup = component.find('popup');
        popup.show();
        popup.set('v.closeCallback', $A.getCallback(params.cancelCallback));
    },

    doSuccess : function (component) {
        component.get('v.callback')();
        component.find('popup').hide();
    },

    doCancel : function (component) {
        component.find('popup').cancel();
    },

    doUpdateHtmlMessage: function (component, event, helper) {
        var message = component.get('v.message');
        var htmlMessage = message.replace(new RegExp('\\n', 'g'), '<br/>');
        component.set('v.htmlMessage', htmlMessage);
    }
})