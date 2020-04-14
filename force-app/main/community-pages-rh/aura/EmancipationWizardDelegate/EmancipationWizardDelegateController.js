/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */
({

    checkFields: function (component, event) {
        var delegateItem = component.get('v.delegateItem');

        var isValid = (delegateItem.Email__c && communityService.isValidEmail(delegateItem.Email__c)) &&
            delegateItem.First_Name__c && delegateItem.First_Name__c.trim() &&
            delegateItem.Last_Name__c && delegateItem.Last_Name__c.trim();
        component.set('v.isValid', isValid);
    },

    checkContact: function (component, event) {
        var email = event.getSource().get('v.value');

        if (email && communityService.isValidEmail(email)) {
            component.find('spinner').show();

            communityService.executeAction(component, 'checkDelegateDuplicate', {
                email: email
            }, function (returnValue) {
                if (returnValue.firstName) {
                    component.set('v.delegateItem.First_Name__c', returnValue.firstName);
                    component.find('delFirstName').focus();
                    component.set('v.delegateItem.Last_Name__c', returnValue.lastName);
                    component.find('delLastName').focus();
                    component.set('v.delegateItem.Contact__c', returnValue.contactId);
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    if (returnValue.firstName && returnValue.lastName) {
                        component.set('v.isValid', true);
                    }
                    component.find('spinner').hide();
                } else {
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.find('spinner').hide();
                }
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
            component.find('spinner').hide();
        }, function (returnValue) {
            console.log(' ERROR!: ' + returnValue);
            component.find('spinner').hide();
            communityService.showErrorToast('', "Emancipation process - connect/disconnect delegate action failed! Description: " + returnValue);
        })
    },

});