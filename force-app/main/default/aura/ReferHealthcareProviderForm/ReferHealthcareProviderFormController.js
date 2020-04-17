/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */

({
    /*doConnect: function (component, event, helper) {
        component.find('spinner').show();
        var refProvider = JSON.parse(JSON.stringify(component.get('v.refProvider')));
        if (refProvider) {
            helper.showHideProvider(component);
        } else {
            var pe = component.get('v.pe');
            var hcProvider = component.get('v.healthCareProvider');
            communityService.executeAction(component, 'inviteHP', {
                peId: pe.Id,
                hp: JSON.stringify(hcProvider)
            }, function (returnValue) {
                var parent = component.get('v.parent');
                console.log('PARENT', component.get('v.parent'));
                parent.set('v.healthCareProviders', returnValue);
                component.find('spinner').hide();
            })
        }
    },

    checkFields: function (component, event, helper) {
        var hcp = component.get('v.healthCareProvider');
        if (event.getSource().getLocalId() == 'hcpEmail' && component.get('v.providerFound')) {
            component.set('v.providerFound', false);
            hcp.First_Name__c = null;
            hcp.Last_Name__c = null;
            component.set('v.healthCareProvider', hcp);
        }
        var isValid = (hcp.Email__c && communityService.isValidEmail(hcp.Email__c)) && hcp.First_Name__c && hcp.Last_Name__c;
        component.set('v.isValid', isValid);
    },

    checkContact: function (component, event, helper) {
        var email = event.getSource().get('v.value');
        var sharingObject = component.get('v.sharingObject');
        if (email && communityService.isValidEmail(email) && sharingObject.sObjectType == 'Healthcare_Provider__c') {
            component.find('spinner').show();
            var pe = component.get('v.pe');
            communityService.executeAction(component, 'checkDuplicate', {
                peId: pe.Id,
                email: email
            }, function (returnValue) {
                if (returnValue.firstName) {
                    component.set('v.healthCareProvider.First_Name__c', returnValue.firstName);
                    component.find('firstNameInput').focus();
                    component.set('v.healthCareProvider.Last_Name__c', returnValue.lastName);
                    component.find('lastNameInput').focus();
                    component.set('v.providerFound', true);
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

    doDisconnect: function (component, event, helper) {
        component.find('spinner').show();
        var hcProvider = component.get('v.healthCareProvider');
        component.get('v.parent').disconnectHCP(component.get('v.index'));
        communityService.executeAction(component, 'stopSharing', {hpId: hcProvider.Id}, function (returnValue) {
            component.get('v.parent').disconnectHCP(component.get('v.index'));
            component.find('spinner').hide();
        })
    },*/

});