/**
 * Created by Nikita Abrazhevitch on 10-Apr-20.
 */

({
    showHideProvider: function (component) {
        var parent = component.get('v.parent');
        var showProvider = parent.get('v.showReferringProvider');
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'showOrHideProvider', {peId: pe.Id}, function (returnValue) {
            if (showProvider) {
                parent.set('v.showReferringProvider', false);
            } else {
                parent.set('v.showReferringProvider', true);
            }
            parent.find('spinner').hide();
        })
    },

    doConnect: function (component, event, helper) {
        var sharingObject = component.get('v.sharingObject');
        var pe = component.get('v.pe');
        var parent = component.get('v.parent');
        if (sharingObject.sObjectType == 'Contact') {
            helper.showHideProvider(component);
        } else if (sharingObject.sObjectType == 'Healthcare_Provider__c') {
            console.log('HCPERROR', JSON.stringify(sharingObject));
            communityService.executeAction(component, 'inviteHP', {
                peId: pe.Id,
                hp: JSON.stringify(sharingObject)
            }, function (returnValue) {
                var mainComponent = component.get('v.mainComponent');
                mainComponent.refresh();
                //mainComponent.set('v.healthCareProviders', returnValue);
                parent.find('spinner').hide();
            })
        } else {
            communityService.executeAction(component, 'invitePatientDelegate', {
                participant: JSON.stringify(pe.Participant__r),
                delegateContact: JSON.stringify(sharingObject),
                delegateId: sharingObject.delegateId ? sharingObject.delegateId : null
            }, function (returnValue) {
                var mainComponent = component.get('v.mainComponent');
                mainComponent.refresh();
                parent.find('spinner').hide();
            })
        }
    },

    doDisconnect: function (component, event, helper) {
        var mainComponent = component.get('v.mainComponent');
        var parentComponent = component.get('v.parent');
        var sharingObject = component.get('v.sharingObject');
        var params;
        if (sharingObject.sObjectType == 'Healthcare_Provider__c') {
            params = {hpId: sharingObject.Id, delegateId: null};
        } else {
            params = {hpId: null, delegateId: sharingObject.delegateId};
        }
        communityService.executeAction(component, 'stopSharing', params, function (returnValue) {
            mainComponent.refresh();
        });
    },

    doCheckContact: function(component, event, helper, firstName, lastName, email){
        console.log('1');
        var sharingObject = component.get('v.sharingObject');
        console.log('2');
        var parent = component.get('v.parent');
        console.log('3');
        parent.find('spinner').show();
        console.log('4');
        var pe = component.get('v.pe');
        console.log('5');
        console.log('email>>>>>>',email);
        communityService.executeAction(component, 'checkDuplicate', {
            peId: pe.Id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            participantId: null
        }, function (returnValue) {
            console.log('6');
            if (returnValue.firstName) {
                console.log('7');
                if (sharingObject.sObjectType == 'Object') {
                    component.set('v.sharingObject.email', email);
                    component.set('v.sharingObject.firstName', returnValue.firstName);
                    component.find('firstNameInput').focus();
                    component.set('v.sharingObject.lastName', returnValue.lastName);
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
    },
});