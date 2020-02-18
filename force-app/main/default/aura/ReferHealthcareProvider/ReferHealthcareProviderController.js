/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */

({
    doInit: function (component, event, helper) {
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'getInitData', {peId: pe.Id}, function (returnValue) {
            component.set('v.healthCareProviders', returnValue);
        });
        communityService.executeAction(component, 'getContactsDelegates', {participantId: pe.Participant__c}, function (returnValue) {
            component.set('v.delegates', returnValue);
            console.log('DELEGATES', component.get('v.delegates'));
            console.log('HEALTHCARE', JSON.parse(JSON.stringify(component.get('v.healthCareProviders'))));
            console.log('REFPROVIDER', component.get('v.refProvider'));
        });
    },

    doAddProvider: function (component, event, helper) {
        var pe = component.get('v.pe');
        var hcProvider = component.get('v.healthCareProviders');
        console.log('hcP', hcProvider);
        hcProvider.push({sObjectType: 'Healthcare_Provider__c'});
        component.set('v.healthCareProviders', hcProvider);
        console.log('hcP', component.get('v.healthCareProviders'));
    },
    doAddDelegate: function (component, event, helper) {
        var pe = component.get('v.pe');
        var delegates = component.get('v.delegates');
        delegates.push({sObjectType: 'Participant__c'});
        component.set('v.delegates', delegates);
    },

    doDisconnect: function(component, event, helper){
    	/*var hcProviders = component.get('v.healthCareProviders');
    	var params = event.getParam('arguments');
    	hcProviders.splice(params.index,1);
    	if(hcProviders.length == 0){
            hcProviders.push({sObjectType: 'Healthcare_Provider__c'});
        }
    	component.set('v.healthCareProviders', hcProviders);*/
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'getInitData', {peId: pe.Id}, function (returnValue) {
            component.set('v.healthCareProviders', returnValue);
        })
    },
})