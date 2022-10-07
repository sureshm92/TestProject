/**
 * Created by Leonid Bartenev
 */
({
    doSearchEnrollment: function (component, event, helper) {
        component.find('mainSpinner').show();
        var searchData = component.get('v.searchData');
        if (component.get('v.hcpeId')) {
            communityService.executeAction(
                component,
                'createParticipantEnrollmentHcpe',
                {
                    trialId: component.get('v.trialId'),
                    hcpeId: component.get('v.hcpeId'),
                    participantId: searchData.participantId,
                    firstName: searchData.firstName,
                    lastName: searchData.lastName,
                    delegateId: communityService.getDelegateId()
                },
                function (returnValue) {
                    var searchResult = JSON.parse(returnValue);
                    component.set('v.searchResult', searchResult);
                    var preSurvey = component.get('v.preSurvey');
                    if (
                        searchResult.result === 'New' &&
                        !preSurvey
                    ) {
                        searchResult.result = 'Start Pre-Screening';
                        component.set('v.mrrResult', 'Start Pre-Screening');
                    }
                    if (searchResult.result !== 'New' && searchResult.result !== 'MRR Pending')
                        component.set('v.showSpinner', false);component.find('mainSpinner').hide();
                    helper.addEventListener(component, helper);
                }
            );
        } else {
            communityService.executeAction(
                component,
                'createParticipantEnrollment',
                {
                    trialId: component.get('v.trialId'),
                    participantId: searchData.participantId,
                    firstName: searchData.firstName,
                    lastName: searchData.lastName,
                    delegateId: communityService.getDelegateId()
                },
                function (returnValue) {
                    var searchResult = JSON.parse(returnValue);
                    component.set('v.searchResult', searchResult);
                    var preSurvey = component.get('v.preSurvey');
                    if (
                        searchResult.result === 'New' &&
                        !preSurvey
                    ) {
                        searchResult.result = 'Start Pre-Screening';
                        component.set('v.mrrResult', 'Start Pre-Screening');
                    }
                    if (searchResult.result !== 'New' && searchResult.result !== 'MRR Pending')
                        component.set('v.showSpinner', false);component.find('mainSpinner').hide();
                    helper.addEventListener(component, helper);
                }
            );
        }
    },

    doFrameLoaded: function (component, event, helper) {
        component.find('mainSpinner').hide();
    },

    doClearForm: function (component) {
        component.set('v.searchResult', undefined);
        component.set('v.searchData', {
            participantId: ''
        });
        component.set('v.mrrResult', 'Pending');
    },

    doReferPatient: function (component) {
        communityService.navigateToPage(
            'referring?id=' +
                component.get('v.trialId') +
                '&peid=' +
                component.get('v.searchResult').pe.Id +
                '&patientVeiwRedirection=true' 
        );
    },

    doCheckPatientId: function (component) {
        var patientId = component.get('v.searchData').participantId;
        var isEmptyId = true;
        if (patientId && patientId.trim().length > 0) isEmptyId = false;
        component.set('v.isEmptiId', isEmptyId);
    }
});