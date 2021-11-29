({
    callServerMethodOnPiChange: function (
        component,
        mthdName,
        usermode,
        communityname,
        delegateID,
        selectedPI,
        selectedCTP,
        piaction,
        helper
    ) {
        communityService.executeAction(
            component,
            mthdName,
            {
                userMode: usermode,
                communityName: communityname,
                delegateId: delegateID,
                piId: selectedPI,
                ctpId: selectedCTP,
                action: piaction
            },
            function (returnValue) {
                var responseData = JSON.parse(returnValue);
                component.set('v.piData', responseData);
                component.set('v.piCTPPicklist', responseData.piCTPPicklist);
                var currentData = component.get('v.piData');
                component.set('v.currentStudy', currentData.selectedCTP);
                helper.showParticipantsContactedDashboard(component, helper, responseData);
                //var spinner = component.find('mainSpinner');
                // spinner.hide();
            }
        );
    },

    callServerMethodOnStudyChange: function (
        component,
        mthdName,
        usermode,
        communityname,
        delegateID,
        selectedPI,
        selectedCTP,
        piaction,
        helper
    ) {
        communityService.executeAction(
            component,
            mthdName,
            {
                userMode: usermode,
                communityName: communityname,
                delegateId: delegateID,
                piId: selectedPI,
                ctpId: selectedCTP,
                action: piaction
            },
            function (returnValue) {
                var responseData = JSON.parse(returnValue);
                component.set('v.piData', responseData);
                component.set('v.piCTPPicklist', responseData.piCTPPicklist);
                var currentData = component.get('v.piData');
                component.set('v.currentPi', currentData.selectedPi);
                helper.showParticipantsContactedDashboard(component, helper, responseData);
                component.find('invitationId').fetchDashboardValues();//RH-5163
                //var spinner = component.find('mainSpinner');
                // spinner.hide();
            }
        );
    },

    showParticipantsContactedDashboard: function (component, helper, piData) {
        if (piData.ContactedParticipantDataList == null) {
            component.set('v.isParticipantDisplay', false);
        } else {
            component.set('v.isParticipantDisplay', true);
        }
    }
});
