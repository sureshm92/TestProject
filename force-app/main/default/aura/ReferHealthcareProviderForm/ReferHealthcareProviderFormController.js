/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */

({
    doConnect: function (component, event, helper) {
        var pe = component.get('v.pe');
        var hcProvider = component.get('v.healthCareProvider');
        communityService.executeAction(component, 'connectHCProvider', {
            hcProvider: hcProvider,
            peId: pe.Id
        }, function (returnValue) {
            if (returnValue) {
                component.set('v.healthCareProvider.First_Name', 'Name');
            }
        })
    },

    checkFieldsds: function (component, event, helper) {
        var a = component.get('v.healthCareProvider');
    },

    checkContact: function (component, event, helper) {
        component.find('spinner').show();
        var email = event.getSource().get('v.value');
        /*communityService.executeAction(component, 'checkContact', {email: email}, function (returnValue) {
            if (returnValue) {
                component.set('v.healthCareProvider.First_Name', 'Name');
            }
        })*/
        component.set('v.providerFound', true);
        component.find('spinner').hide();
    },

    doDisconnect: function (component, event, helper) {
        var hcProvider = component.get('v.healthCareProvider');
        component.get('v.parent').disconnectHCP(component.get('v.index'));
        /*communityService.executeAction(component, 'checkContact', {hcProvider: hcProvider}, function (returnValue) {
           component.get('v.parent').disconnectHCP(component.get('v.index'));
        })*/
    },

});