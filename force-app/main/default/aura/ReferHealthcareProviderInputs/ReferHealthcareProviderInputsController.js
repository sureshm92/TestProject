/**
 * Created by Nikita Abrazhevitch on 10-Apr-20.
 */
({
    checkContact: function (component, event, helper) {
        var sharingObject = component.get('v.sharingObject');
        var email = event.getSource().get('v.value');
        if (email && communityService.isValidEmail(email)) {
            var parent = component.get('v.parent');
            parent.find('spinner').show();
            var pe = component.get('v.pe');
            communityService.executeAction(component, 'checkDuplicate', {
                peId: pe.Id,
                email: email
            }, function (returnValue) {
                if (returnValue.firstName) {
                    if (sharingObject.sObjectType == 'Patient_Delegate__c') {
                        component.set('v.sharingObject.Contact__r.Email', email);
                        component.set('v.sharingObject.Contact__r.FirstName', returnValue.firstName);
                        component.find('firstNameInput').focus();
                        component.set('v.sharingObject.Contact__r.LastName', returnValue.lastName);
                        component.find('lastNameInput').focus();
                    } else if (sharingObject.sObjectType == 'Contact') {
                        component.set('v.sharingObject.Email', email);
                        component.set('v.sharingObject.FirstName', returnValue.firstName);
                        component.find('firstNameInput').focus();
                        component.set('v.sharingObject.LastName', returnValue.lastName);
                        component.find('lastNameInput').focus();
                    } else {
                        component.set('v.sharingObject.Email__c', email);
                        component.set('v.sharingObject.First_Name__c', returnValue.firstName);
                        component.find('firstNameInput').focus();
                        component.set('v.sharingObject.Last_Name__c', returnValue.lastName);
                        component.find('lastNameInput').focus();
                    }
                    component.set('v.providerFound', true);
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.set('v.isDuplicateDelegate', returnValue.isDuplicateDelegate);
                    if (returnValue.firstName && returnValue.lastName) {
                        component.set('v.isValid', true);
                    }
                    parent.find('spinner').hide();
                } else {
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.set('v.isDuplicateDelegate', returnValue.isDuplicateDelegate);
                    parent.find('spinner').hide();
                }
            });
        }
    },

    checkFields: function (component, event, helper) {
        var email;
        var firstName;
        var lastName;
        var sharingObject = component.get('v.sharingObject');
        if (sharingObject.sObjectType == 'Patient_Delegate__c') {
            if (event.getSource().getLocalId() == 'hcpEmail') {
                if (component.get('v.providerFound')) {
                    component.set('v.providerFound', false);
                    component.set('v.sharingObject.Contact__r.FirstName', null);
                    component.set('v.sharingObject.Contact__r.LastName', null);
                }
                component.set('v.sharingObject.Contact__r.Email', event.getSource().get('v.value'));
            }
            if (event.getSource().getLocalId() == 'firstNameInput') {
                component.set('v.sharingObject.Contact__r.FirstName', event.getSource().get('v.value'));
            }
            if (event.getSource().getLocalId() == 'lastNameInput') {
                component.set('v.sharingObject.Contact__r.LastName', event.getSource().get('v.value'));
            }
            sharingObject = component.get('v.sharingObject');
            email = sharingObject.Contact__r.Email.trim();
            firstName = sharingObject.Contact__r.FirstName.trim();
            lastName = sharingObject.Contact__r.LastName.trim();
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
        } else if (sharingObject.Status__c == 'Active' || sharingObject.Status__c == 'Invited') {
            helper.doDisconnect(component, event, helper);
        } else {
            helper.doConnect(component, event, helper);
        }
    },
});