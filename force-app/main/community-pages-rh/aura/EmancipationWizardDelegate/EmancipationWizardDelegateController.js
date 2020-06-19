/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */
({

    checkFields: function (component, event, helper) {
        var delegateItem = component.get('v.delegateItem');

        if (event.getSource().getLocalId() == 'delEmail') {
            delegateItem.First_Name__c = null;
            delegateItem.Last_Name__c = null;
        }
        delegateItem.isConnected = false;
        delegateItem.isDuplicate = false;
        component.set('v.delegateItem', delegateItem);
        component.set('v.isDuplicate', false);
        var isValid = (delegateItem.Email__c && communityService.isValidEmail(delegateItem.Email__c)) &&
            delegateItem.First_Name__c && delegateItem.First_Name__c.trim() &&
            delegateItem.Last_Name__c && delegateItem.Last_Name__c.trim();
        component.set('v.isValid', isValid);
        if(isValid && event.getType()==='aura:valueInit')  helper.doCheckContact(component,event);
    },

    checkContact: function (component, event,helper) {
        helper.doCheckContact(component,event);
    },

    doConnect : function (component) {
        component.find('spinner').show();

        let isConnected = true && component.get('v.delegateItem.isConnected');
        let parent = component.get('v.parent');

        let delegateS = JSON.parse(JSON.stringify(component.get('v.delegateItem')));
        delete delegateS.selectedOption;
        delete delegateS.statesDelegateLVList;
        delete delegateS.continueDelegateMsg;
        delete delegateS.isConnected;
        delete delegateS.fromStart;

        console.log('participantS: ' + JSON.stringify(parent.get('v.participant')));
        console.log('delegateS: ' + JSON.stringify(delegateS));
        console.log('studySiteId: ' + parent.get('v.pe.Study_Site__c'));
        console.log('isConnected: ' + isConnected);

        communityService.executeAction(component, 'connectDelegateToPatient', {
            participantS: JSON.stringify(parent.get('v.participant')),
            delegateS: JSON.stringify(delegateS),
            studySiteId: parent.get('v.pe.Study_Site__c'),
            isConnected: isConnected
        }, function (returnValue) {
            component.set('v.delegateItem.isConnected', returnValue.isConnected);
            component.set('v.delegateItem.Contact__c', returnValue.contactId);
            component.set('v.delegateItem.Id', returnValue.participantId);
            component.set('v.delegateItem.continueDelegateMsg', $A.get('$Label.c.PG_Ref_L_Delegate_continue_be_delegate').replace('##delegateName', component.get('v.delegateItem.First_Name__c') + ' ' + component.get('v.delegateItem.Last_Name__c')));
            component.find('spinner').hide();
        }, function (returnValue) {
            console.log(' ERROR!: ' + returnValue);
            component.find('spinner').hide();
            communityService.showErrorToast('', "Emancipation process - connect/disconnect delegate action failed! Description: " + returnValue);
        })
    },

    approveDelegate:function(component, event, helper){
        component.set('v.useThisDelegate', true);
    },

});