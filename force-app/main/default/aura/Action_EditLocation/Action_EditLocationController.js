/**
 * Created by user on 21-Aug-19.
 */

({
    doExecute: function(component, event, helper){
        var params = event.getParam('arguments');
        var account = JSON.parse(JSON.stringify(params.account));
        component.set('v.account', account);
        if (params.callback) component.set('v.callback', $A.getCallback(params.callback));
        component.find('editLocation').show();
    },
});