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
});