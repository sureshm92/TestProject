({
    recordChange: function (component, event, helper) {
        component.set('v.ContactedParticipantData', null);
        window.setTimeout(
            $A.getCallback(function () {
                helper.callServerMethod(component, event, helper);
            }),
            100
        );
    },

    showEditParticipantInformation: function (component, event, helper) {
        var participantEnrolmentId = event.getParam('value'); 
        var participantMap = component.get('v.mapParticipantIdtoPerName'); 
        communityService.navigateToPage(
            'my-referrals?perName=' + participantMap[participantEnrolmentId] + '&Pname='  + event.detail.menuItem.get("v.label")
        );
         
        // if (participantEnrolmentId !== '' && participantEnrolmentId !== 'No participant record') {
        //     helper.getInviteDetails(component, event, participantEnrolmentId); // added for REF-2646 issue fixing
        //     communityService.executeAction(
        //         component,
        //         'getPEEnrollmentsByPI',
        //         { eId: participantEnrolmentId },
        //         function (returnValue) {
        //             var rootComponent = component.get('v.parent');
        //             var pe = JSON.parse(returnValue);
        //             var actions = null;
        //             var isInvited = component.get('v.isInvited');
        //             rootComponent
        //                 .find('updatePatientInfoAction')
        //                 .execute(pe, actions, rootComponent, isInvited, function (enrollment) {
        //                     rootComponent.refresh();
        //                     component.set('v.recordChanged', 'record changed'); // Do not remove this variable
        //                     helper.callServerMethod(component, event, helper);
        //                 });
        //         }
        //     );
        //     component.set('v.recordChanged', ''); // Do not remove this variable
        // }
    }
});