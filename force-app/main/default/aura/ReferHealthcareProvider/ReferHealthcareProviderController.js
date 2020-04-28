/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */

({
    doInit: function (component, event, helper) {
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'getInitData', {peId: pe.Id, participantId: pe.Participant__c}, function (returnValue) {
            console.log('PES', JSON.stringify(returnValue));
            var hcp = returnValue.healthcareProviders;
            for (let i = 0; i < hcp.length; i++) {
                hcp[i].sObjectType = 'Healthcare_Provider__c';
            }
            var del = returnValue.listWrapp;
            console.log(JSON.stringify(returnValue.listWrapp));
            for (let i = 0; i <del.length; i++) {
                del[i].sObjectType = 'Object'
            }
            var rp = component.get('v.refProvider');
            if(rp) rp.sObjectType = 'Contact';
            component.set('v.refProvider',rp);
            component.set('v.healthCareProviders', hcp);
            component.set('v.delegates', del);
        });
    },

    doAddProvider: function (component, event, helper) {
        var hcProvider = component.get('v.healthCareProviders');
        hcProvider.push({sObjectType: 'Healthcare_Provider__c'});
        component.set('v.healthCareProviders', hcProvider);
    },
    doAddDelegate: function (component, event, helper) {
        var delegates = component.get('v.delegates');
        delegates.push({sObjectType: 'Object'});
        component.set('v.delegates', delegates);
    },

   doDisconnect: function(component, event, helper){
    	var hcProviders = component.get('v.healthCareProviders');
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'getInitData', {peId: pe.Id, participantId: pe.Participant__c}, function (returnValue) {
            component.set('v.healthCareProviders', returnValue);
        })
    },
})