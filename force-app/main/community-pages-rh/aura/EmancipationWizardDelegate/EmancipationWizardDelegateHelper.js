({
    doCheckContact: function(component, event, helper, connect) {
        var delegateItem = component.get('v.delegateItem');
        var currentDelegateUsage = JSON.parse(JSON.stringify(component.get('v.useThisDelegate')));
        //var delegateNewInstance = delegateItem.Email__c+delegateItem.Last_Name__c+delegateItem.First_Name__c;
        if(component.get('v.delegateEmailWasChanged') || (component.get('v.useThisDelegate') && connect)) {
            var isValid = component.get('v.isValid');
            var parent = component.get('v.parent');
            var part = parent.get('v.participant');
            if (isValid) {
                component.find('spinner').show();
                communityService.executeAction(component, 'checkDelegateDuplicate', {
                    email: delegateItem.Email__c,
                    firstName: delegateItem.First_Name__c,
                    lastName: delegateItem.Last_Name__c,
                    participantId: part.Id
                }, function (returnValue) {
                    //var delegateInstance = '';
                    var delegateItem = component.get('v.delegateItem');
                    if (returnValue.email) {
                        delegateItem.Email__c = returnValue.email;
                       // delegateInstance += returnValue.email;
                    }
                    if (returnValue.lastName) {
                        delegateItem.Last_Name__c = returnValue.lastName;
                        //delegateInstance += returnValue.lastName;
                    }
                    if (returnValue.firstName) {
                        delegateItem.First_Name__c = returnValue.firstName;
                        //delegateInstance += returnValue.firstName;
                    }
                    //component.set('v.delegateInstance', delegateInstance);
                    if (returnValue.contactId) delegateItem.Contact__c = returnValue.contactId;
                    if (returnValue.isDuplicate) delegateItem.isDuplicate = returnValue.isDuplicate;
                    component.set('v.duplicateDelegateInfo', returnValue);
                    if (returnValue.isDuplicateDelegate || returnValue.contactId || returnValue.participantId) {
                        component.set('v.useThisDelegate', true);
                        component.set('v.useThisDelegate', false);
                    } else component.set('v.useThisDelegate', true);
                    component.set('v.delegateItem', delegateItem);
                    if (returnValue.firstName && returnValue.lastName) {
                        component.set('v.isValid', true);
                    }
                    component.set('v.delegateEmailWasChanged',false);
                    if(connect && !returnValue.isDuplicateDelegate ) helper.doConnectDelegate(component, event, helper);
                    component.find('spinner').hide();
                });
            }
        }
    },

    doConnectDelegate: function(component, event, helper){
       // component.find('spinner').show();
        component.set('v.useThisDelegate', true);
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
                isConnected: isConnected,
                duplicateDelegateInfo: JSON.stringify(component.get('v.duplicateDelegateInfo'))
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
    }
})