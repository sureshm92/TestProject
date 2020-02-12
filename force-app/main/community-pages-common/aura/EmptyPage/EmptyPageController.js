/**
 * Created by Nargiz Mamedova on 10/21/2019.
 */

({
    doInit: function (component, event, helper) {
        let action = component.get('c.getPermission');
        action.setParams({
            ctpId : component.get('v.recordId'),
            feature : component.get('v.featureName')
        });
        action.setCallback(this,function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set('v.hasAccess', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
});