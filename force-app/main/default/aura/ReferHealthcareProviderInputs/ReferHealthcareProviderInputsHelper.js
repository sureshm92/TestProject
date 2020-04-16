/**
 * Created by Nikita Abrazhevitch on 10-Apr-20.
 */

({
    showHideProvider: function (component) {
        console.log('1');
        var parent = component.get('v.parent');
        var showProvider = parent.get('v.showReferringProvider');
        console.log('2');
        var pe = component.get('v.pe');
        console.log('3');
        console.log('4');
        communityService.executeAction(component, 'showOrHideProvider', {peId: pe.Id}, function (returnValue) {
           console.log('after server');
            if(showProvider){
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
        } else if (sharingObject.sObjectType == 'Healthcare_Provider__c'){
            communityService.executeAction(component, 'inviteHP', {
                peId: pe.Id,
                hp: JSON.stringify(sharingObject)
            }, function (returnValue) {
                var mainComponent = component.get('v.mainComponent');
                mainComponent.set('v.healthCareProviders', returnValue);
                parent.find('spinner').hide();
            })
        } else{
            communityService.executeAction(component, 'invitePatientDelegate', {
                peId: pe.Id,
                participant: JSON.stringify(pe.Participant__r),
                delegate: JSON.stringify(sharingObject)
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
            params = {hpId: null, delegateId: sharingObject.Id};
        }
            communityService.executeAction(component, 'stopSharing', params, function (returnValue) {
                mainComponent.refresh();
            });
    },
});