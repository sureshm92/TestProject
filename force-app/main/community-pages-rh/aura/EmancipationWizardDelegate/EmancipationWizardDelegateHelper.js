({
    doCheckContact: function(component, event) {
        var email = event.getSource().get('v.value');
        var delegateItem = component.get('v.delegateItem');
        var isValid = component.get('v.isValid');
        var parent = component.get('v.parent');
        var part = parent.get('v.participant');
        console.log('check contact>>>>');
        console.log('check contact isValid>>>>', isValid);
        if (isValid) {
            component.find('spinner').show();
            communityService.executeAction(component, 'checkDelegateDuplicate', {
                email: delegateItem.Email__c,
                firstName: delegateItem.First_Name__c,
                lastName: delegateItem.Last_Name__c,
                participantId: part.Id
            }, function (returnValue) {
                var delegateItem = component.get('v.delegateItem');
                if (returnValue.firstName) delegateItem.First_Name__c = returnValue.firstName;
                if (returnValue.lastName) delegateItem.Last_Name__c = returnValue.lastName;
                if (returnValue.contactId) delegateItem.Contact__c = returnValue.contactId;
                if (returnValue.isDuplicate) delegateItem.isDuplicate = returnValue.isDuplicate;
                component.set('v.duplicateDelegateInfo', returnValue);
                if (returnValue.isDuplicateDelegate || returnValue.contactId || returnValue.participantId) component.set('v.useThisDelegate', false);
                else component.set('v.useThisDelegate', true);
                component.set('v.delegateItem', delegateItem);
                if (returnValue.firstName && returnValue.lastName) {
                    component.set('v.isValid', true);
                }
                component.find('spinner').hide();
            });
        }
    },
})