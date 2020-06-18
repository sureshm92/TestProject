/**
 * Created by Nikita Abrazhevitch on 13-Jun-20.
 */

({
    labelCorrect:function(component, event, helper){
        var delegateInfo = component.get('v.delegateDuplicateInfo');
    	var label = $A.get('$Label.c.Duplicate_Delegate_Message');
    	label = label.replace(new RegExp('##firstName', 'g'), delegateInfo.firstName);
    	label = label.replace('##lastName',delegateInfo.lastName);
    	component.set('v.duplicateMessage', label);
    },

    doOnClick: function (component, event, helper) {
        component.getEvent('ddMessageButtonClick').fire();
    },
});