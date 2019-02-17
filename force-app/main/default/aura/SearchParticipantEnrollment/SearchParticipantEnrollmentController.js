/**
 * Created by Leonid Bartenev
 */
({
    doSearchEnrollment: function(component, event, helper){
        component.set('v.showSpinner', true);
        var searchData = component.get('v.searchData');
        communityService.executeAction(component, 'createParticipantEnrollment', {
            trialId: component.get('v.trialId'),
            //hcpeId: component.get('v.hcpEnrollment').Id,
            participantId: searchData.participantId,
            firstName: searchData.firstName,
            lastName: searchData.lastName
        }, function (returnValue) {
            var searchResult = JSON.parse(returnValue);
            component.set("v.searchResult", searchResult);
            if(searchResult.result === 'New' && searchResult.pe.Medical_Record_Review_Status__c === 'Not Required'){
                searchResult.result = 'Start Pre-Screening';
                component.set('v.mrrResult', 'Start Pre-Screening');
            }
            if(searchResult.result !== 'New' && searchResult.result !== 'MRR Pending') component.set('v.showSpinner', false);
            helper.addEventListener(component, helper);

        });
    },

    doFrameLoaded: function (component, event, helper) {
        component.set('v.showSpinner', false);
    },

    doClearForm: function (component) {
        component.set('v.searchResult', undefined);
        component.set('v.searchData', {
            participantId : ''
        });
        component.set('v.mrrResult', 'Pending');
    },

    doReferPatient: function (component) {
        communityService.navigateToPage('referring?id=' + component.get('v.trialId') + '&peid=' + component.get('v.searchResult').pe.Id);
    },

    doCheckPatientId: function (component) {
        var patientId = component.get('v.searchData').participantId;
        var isEmptyId = true;
        if(patientId && patientId.trim().length > 0 ) isEmptyId = false;
        component.set('v.isEmptiId', isEmptyId);
    }

})