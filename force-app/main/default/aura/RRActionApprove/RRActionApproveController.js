/**
 * Created by Igor Malyuta on 16.04.2019.
 */
({
    doExec : function (component, event, helper) {
        var params = event.getParam('arguments');
        component.set('v.text', params.title);
        component.set('v.leftBtnName',  params.leftBtnName);
        component.set('v.rightBtnName', params.rightBtnName);
        component.set('v.callback', params.callback);

        var popup = component.find('popup');
        popup.show();
        popup.set('v.closeCallback', function () {
            if(params.cancelCallback) params.cancelCallback();
        });
    },

    doSuccess : function (component) {
        component.get('v.callback')();
        component.find('popup').hide();
    },

    doCancel : function (component) {
        component.find('popup').hide();
    }
})