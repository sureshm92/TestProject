/**
 * Created by Kryvolap on 04.12.2019.
 */
({
    doInit: function (component, event, helper) {
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'getInitData', { peId: pe.Id, participantId: pe.Participant__c}, function (
            returnValue
        ) {
            component.set('v.healthCareProviders', returnValue.healthcareProviders);
        });
    }
});
