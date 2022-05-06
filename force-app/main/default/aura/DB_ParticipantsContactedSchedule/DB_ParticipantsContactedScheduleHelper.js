({
    callServerMethod: function (component, event, helper) {
        component.set('v.loaded', true);
        var action = component.get('c.getContactedParticipantsData');
        action.setParams({
            principalInvestigatorId: component.get('v.currentPi'),
            studyId: component.get('v.currentStudy')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var responseData = response.getReturnValue();
                component.set('v.ContactedParticipantData', responseData);
                component.set('v.mapParticipantIdtoPerName', responseData.mapPartcipantIdToPerName);
                helper.createContactedParticipantDataList(
                    component,
                    event,
                    helper,
                    responseData.daysPatientsStudies
                );
                component.set('v.loaded', false);
            } else {
                helper.showError(component, event, helper, action.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    showError: function (component, event, helper, errorMsg) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            message: errorMsg,
            duration: '400',
            type: 'error'
        });
        toastEvent.fire();
    },

    // added for REF-2646 issue fixing
    getInviteDetails: function (component, event, participantId) {
        communityService.executeAction(
            component,
            'getInvitedDetails',
            {
                participantId: participantId
            },
            function (returnValue) {
                component.set('v.isInvited', JSON.parse(returnValue));
            }
        );
    },

    createContactedParticipantDataList: function (
        component,
        event,
        helper,
        ContactedParticipantData
    ) {
        var result = ContactedParticipantData;
        var patientsOptions1 = [];
        var patientsOptions2 = [];
        var patientsOptions3 = [];
        var patientsOptions4 = [];
        var patientsOptions5 = [];
        var patientsOptions5 = [];

        for (var daysKey in result) {
            for (var patientkey in result[daysKey]) {
                if (daysKey == '1-3 Days') {
                    patientsOptions1.push({
                        value: patientkey,
                        label: result[daysKey][patientkey]
                    });
                } else if (daysKey == '4-7 Days') {
                    patientsOptions2.push({
                        value: patientkey,
                        label: result[daysKey][patientkey]
                    });
                } else if (daysKey == '8-10 Days') {
                    patientsOptions3.push({
                        value: patientkey,
                        label: result[daysKey][patientkey]
                    });
                } else if (daysKey == '11-21 Days') {
                    patientsOptions4.push({
                        value: patientkey,
                        label: result[daysKey][patientkey]
                    });
                } else if (daysKey == '>21 Days') {
                    patientsOptions5.push({
                        value: patientkey,
                        label: result[daysKey][patientkey]
                    });
                }
            }
        }
        component.set('v.days_1_To_3_participantOptions', patientsOptions1);
        component.set('v.days_4_To_7_participantOptions', patientsOptions2);
        component.set('v.days_8_To_10_participantOptions', patientsOptions3);
        component.set('v.days_11_To_21_participantOptions', patientsOptions4);
        component.set('v.greater_21_days_participantOptions', patientsOptions5);
    }
});