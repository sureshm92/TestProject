({
    callServerMethod:function(component, mthdName, usermode, delegateID, selectedPI, selectedCTP, piaction,helper){
        communityService.executeAction(component, mthdName, {
            userMode:usermode,
            delegateId:delegateID,
            piId: selectedPI,
            ctpId: selectedCTP,
            action: piaction
        }, function (returnValue) {
            var responseData = JSON.parse(returnValue);
            component.set('v.piData', responseData);
            component.set('v.piCTPPicklist', responseData.piCTPPicklist);
            helper.showParticipantsContactedDashboard(component,helper,responseData); 
            var spinner = component.find('mainSpinner');
            spinner.hide();
        });
    },
    
    showParticipantsContactedDashboard :function(component,helper,piData)
    {
        if(piData.ContactedParticipantDataList == null)
        {
            component.set('v.isParticipantDisplay', false);
        }
        else
        {
            component.set('v.isParticipantDisplay', true);
        }
    }
})