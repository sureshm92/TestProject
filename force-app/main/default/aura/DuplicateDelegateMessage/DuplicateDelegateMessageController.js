/**
 * Created by Nikita Abrazhevitch on 13-Jun-20.
 */

 ({
    labelCorrect: function (component, event, helper) {
        if(component.get('v.recordFound')){
        var delegateInfo = component.get('v.delegateDuplicateInfo');
        var label = $A.get('$Label.c.Duplicate_Delegate_Message');
        label = label.replace(new RegExp('##firstName', 'g'), delegateInfo.firstName);
        label = label.replace('##lastName', delegateInfo.lastName);
        component.set('v.duplicateMessage', label);
        }
    },

    doOnClick: function (component, event, helper) {
        var getAuraFromCalled = event.getSource();
        if(getAuraFromCalled.getLocalId())
        {
            component.set('v.BtnClicked',getAuraFromCalled.getLocalId());
        }
        component.getEvent('ddMessageButtonClick').fire();   
    } 
});