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
                helper.showPPDashboard(component,helper,responseData);//RH-5163
                if(component.get('v.isPPDashboard')) { //RH-5163
                	component.find('invitationId').fetchDashboardValues();
                    component.find('loggedId').fetchDashboardValues();
                }
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
                helper.showPPDashboard(component,helper,responseData);//RH-5163
                if(component.get('v.isPPDashboard')) { //RH-5163
                	component.find('invitationId').fetchDashboardValues();
                    component.find('loggedId').fetchDashboardValues();
                }
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
    },
    
    showPPDashboard: function(component, helper,piData) {
        let ctppEnableList = piData.piCTPPPEnablelist;
        component.set('v.isPPDashboard',false);
        for(let i in piData.piCTPPPEnablelist) {
            if(piData.piCTPPPEnablelist[i].value === component.get('v.currentStudy') && piData.piCTPPPEnablelist[i].ppEnabled) {
                component.set('v.isPPDashboard',true);
                break;
            } 
        }
    }
    
});