/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */
({

    checkFields: function (component, event) {
        console.log('checkFields');
        var delegateItem = component.get('v.delegateItem');

        if (event.getSource().getLocalId() == 'delEmail') {
            delegateItem.First_Name__c = null;
            delegateItem.Last_Name__c = null;
        }

        delegateItem.isConnected = false;
        delegateItem.isDuplicate = false;
        component.set('v.delegateItem', delegateItem);
        component.set('v.isDuplicate', false);
        console.log('delegateItem.Email__c>>>>',delegateItem.Email__c);
        console.log('communityService.isValidEmail(delegateItem.Email__c)>>>>>>',communityService.isValidEmail(delegateItem.Email__c));
        console.log('delegateItem.First_Name__c>>>>',delegateItem.First_Name__c);
        console.log('delegateItem.Last_Name__c>>>>',delegateItem.Last_Name__c);
        if(delegateItem.First_Name__c) console.log('delegateItem.First_Name__c.trim()>>>>',delegateItem.First_Name__c.trim());
        if(delegateItem.Last_Name__c) console.log('delegateItem.Last_Name__c.trim()>>>>',delegateItem.Last_Name__c.trim());
        var isValid = (delegateItem.Email__c && communityService.isValidEmail(delegateItem.Email__c)) &&
            delegateItem.First_Name__c && delegateItem.First_Name__c.trim() &&
            delegateItem.Last_Name__c && delegateItem.Last_Name__c.trim();
        console.log('isVALID>>>>>',isValid);
        component.set('v.isValid', isValid);
    },

    checkContact: function (component, event) {
        var email = event.getSource().get('v.value');
        var delegateItem = component.get('v.delegateItem');
        var isValid = component.get('v.isValid');
        var parent = component.get('v.parent');
        var part = parent.get('v.participant');
        console.log('check contact>>>>');
        console.log('check contact isValid>>>>',isValid);
        if (isValid) {
            component.find('spinner').show();
            communityService.executeAction(component, 'checkDelegateDuplicate', {
                email: delegateItem.Email__c,
                firstName: delegateItem.First_Name__c,
                lastName: delegateItem.Last_Name__c,
                participantId: part.Id
            }, function (returnValue) {
                    var delegateItem = component.get('v.delegateItem');
                    if(returnValue.firstName) delegateItem.First_Name__c = returnValue.firstName;
                    if(returnValue.lastName) delegateItem.Last_Name__c = returnValue.lastName;
                    if(returnValue.contactId) delegateItem.Contact__c = returnValue.contactId;
                    if(returnValue.isDuplicate) delegateItem.isDuplicate = returnValue.isDuplicate;
                    component.set('v.duplicateDelegateInfo',returnValue);
                    component.set('v.delegateItem',delegateItem);
                    if (returnValue.firstName && returnValue.lastName) {
                        component.set('v.isValid', true);
                    }
                    component.find('spinner').hide();
            });
        }
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

});