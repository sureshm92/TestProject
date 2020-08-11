/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */
({

    checkFields: function (component, event, helper) {
        var delegateItem = component.get('v.delegateItem');

        if (event.getSource().getLocalId() == 'delEmail') {
            delegateItem.First_Name__c = null;
            delegateItem.Last_Name__c = null;
            component.set('v.delegateEmailWasChanged',true);
        }
        delegateItem.isConnected = false;
        delegateItem.isDuplicate = false;
        component.set('v.delegateItem', delegateItem);
        component.set('v.isDuplicate', false);
        var isValid = (delegateItem.Email__c && communityService.isValidEmail(delegateItem.Email__c)) &&
            delegateItem.First_Name__c && delegateItem.First_Name__c.trim() &&
            delegateItem.Last_Name__c && delegateItem.Last_Name__c.trim();
        component.set('v.isValid', isValid);
        if(isValid && event.getType()==='aura:valueInit')  helper.doCheckContact(component,event,helper);
    },

    checkContact: function (component, event, helper) {
        helper.doCheckContact(component,event,helper);
    },

    doConnect: function (component, event, helper) {
        helper.doCheckContact(component, event, helper,true);
    },

    approveDelegate:function(component, event, helper){
        component.set('v.useThisDelegate', true);
    },

});