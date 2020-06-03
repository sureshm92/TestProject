/**
 * Created by Nikita Abrazhevitch on 10-Apr-20.
 */
({
    checkContact: function (component, event, helper) {
        var sharingObject = component.get('v.sharingObject');
        var email = event.getSource().get('v.value');
        var isValid = component.get('v.isValid');
        if (email && communityService.isValidEmail(email.trim()) && sharingObject.sObjectType != 'Object') {
            helper.doCheckContact(component, event, helper, null, null, email.trim());
        }
        if(isValid && sharingObject.sObjectType == 'Object'){
            helper.doCheckContact(component, event, helper, sharingObject.firstName, sharingObject.lastName, sharingObject.email.trim());
        }

    },

    checkFields: function (component, event, helper) {
        var email;
        var firstName;
        var lastName;
        var sharingObject = component.get('v.sharingObject');
        if (sharingObject.sObjectType == 'Object') {
            if (event.getSource().getLocalId() == 'hcpEmail') {
                if (component.get('v.providerFound')) {
                    component.set('v.providerFound', false);
                    component.set('v.sharingObject.firstName', null);
                    component.set('v.sharingObject.lastName', null);
                }
                component.set('v.sharingObject.email', event.getSource().get('v.value'));
            }
            if (event.getSource().getLocalId() == 'firstNameInput') {
                component.set('v.sharingObject.firstName', event.getSource().get('v.value'));
            }
            if (event.getSource().getLocalId() == 'lastNameInput') {
                component.set('v.sharingObject.lastName', event.getSource().get('v.value'));
            }
            sharingObject = component.get('v.sharingObject');
            email = sharingObject.email.trim();
            firstName = sharingObject.firstName.trim();
            lastName = sharingObject.lastName.trim();
        } else if (sharingObject.sObjectType == 'Contact') {
            if (event.getSource().getLocalId() == 'hcpEmail') {
                if (component.get('v.providerFound')) {
                    component.set('v.providerFound', false);
                    component.set('v.sharingObject.FirstName', null);
                    component.set('v.sharingObject.LastName', null);
                }
                component.set('v.sharingObject.Email', event.getSource().get('v.value'));
            }
            if (event.getSource().getLocalId() == 'firstNameInput') {
                component.set('v.sharingObject.FirstName', event.getSource().get('v.value'));
            }
            if (event.getSource().getLocalId() == 'lastNameInput') {
                component.set('v.sharingObject.LastName', event.getSource().get('v.value'));
            }
            sharingObject = component.get('v.sharingObject');
            email = sharingObject.Email.trim();
            firstName = sharingObject.FirstName.trim();
            lastName = sharingObject.LastName.trim();
        } else {
            if (event.getSource().getLocalId() == 'hcpEmail') {
                if (component.get('v.providerFound')) {
                    component.set('v.providerFound', false);
                    component.set('v.sharingObject.First_Name__c', null);
                    component.set('v.sharingObject.Last_Name__c', null);
                }
                component.set('v.sharingObject.Email__c', event.getSource().get('v.value'));
            }
            if (event.getSource().getLocalId() == 'firstNameInput') {
                component.set('v.sharingObject.First_Name__c', event.getSource().get('v.value'));
            }
            if (event.getSource().getLocalId() == 'lastNameInput') {
                component.set('v.sharingObject.Last_Name__c', event.getSource().get('v.value'));
            }
            sharingObject = component.get('v.sharingObject');
            email = sharingObject.Email__c ? sharingObject.Email__c.trim() : null;
            firstName = sharingObject.First_Name__c ? sharingObject.First_Name__c.trim() : null;
            lastName = sharingObject.Last_Name__c ? sharingObject.Last_Name__c.trim() : null;
        }
        var isValid = (email && communityService.isValidEmail(email)) && firstName && lastName;
        component.set('v.isValid', isValid);
    },

    doConnectDisconnect: function (component, event, helper) {
        component.get('v.parent').find('spinner').show();
        var sharingObject = component.get('v.sharingObject');
        if (sharingObject.sObjectType == 'Contact') {
            helper.showHideProvider(component);
        } else if (sharingObject.status == 'Active' || sharingObject.Status__c == 'Invited') {
            helper.doDisconnect(component, event, helper);
        } else {
            helper.doConnect(component, event, helper);
        }
    },

    checkDelegateDuplicate: function(component, event, helper){
        var isValid = component.get('v.isValid');
        var sharingObject = component.get('v.sharingObject');
        if(isValid && sharingObject.sObjectType == 'Object'){
            helper.doCheckContact(component, event, helper, sharingObject.firstName, sharingObject.lastName, sharingObject.email.trim());
        }
    },
});