/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */

({
    doInit: function (component, event, helper) {
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'getInitData', {peId: pe.Id}, function (returnValue) {
            component.set('v.healthCareProviders', returnValue);
        })
    },

    doAddProvider: function (component, event, helper) {
        var pe = component.get('v.pe');
        var hcProvider = component.get('v.healthCareProviders');
        console.log('hcP', hcProvider);
        hcProvider.push({sObjectType: 'Healthcare_Provider__c'});
        component.set('v.healthCareProviders', hcProvider);
        console.log('hcP', component.get('v.healthCareProviders'));
    },

    doDisconnetc: function(component, event, helper){
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