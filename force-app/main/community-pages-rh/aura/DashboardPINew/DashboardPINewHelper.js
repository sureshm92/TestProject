({
    callServerMethod:function(component, mthdName, usermode, communityname, delegateID, selectedPI, selectedCTP, piaction,helper){
        communityService.executeAction(component, mthdName, {
            userMode:usermode,
            communityName: communityname, 
            delegateId:delegateID,
            piId: selectedPI,
            ctpId: selectedCTP,
            action: piaction
        }, function (returnValue) {
            var responseData = JSON.parse(returnValue);
            component.set('v.piData', responseData);
            component.set('v.piCTPPicklist', responseData.piCTPPicklist);
            var currentData = component.get('v.piData');
            //alert(JSON.stringify(currentData.selectedPi)+'uu'+JSON.stringify(currentData.selectedCTP));
            //alert(JSON.stringify(component.get('v.currentPi'))+'uu'+JSON.stringify(component.get('v.currentStudy')));

       		//component.set('v.currentPi', currentData.selectedPi); 
       		//component.set('v.currentStudy', currentData.selectedCTP); 
       		//component.set('v.currentPi', component.get('v.currentPi'));
            component.set('v.currentStudy', currentData.selectedCTP);
            helper.showParticipantsContactedDashboard(component,helper,responseData); 
            var spinner = component.find('mainSpinner');
            spinner.hide();
        });
    },
    
 callServerMethod1:function(component, mthdName, usermode, communityname, delegateID, selectedPI, selectedCTP, piaction,helper){
        communityService.executeAction(component, mthdName, {
            userMode:usermode,
            communityName: communityname,
            delegateId:delegateID,
            piId: selectedPI,
            ctpId: selectedCTP,
            action: piaction
        }, function (returnValue) {
            var responseData = JSON.parse(returnValue);
            component.set('v.piData', responseData);
            component.set('v.piCTPPicklist', responseData.piCTPPicklist);
            var currentData = component.get('v.piData');
            //alert(JSON.stringify(currentData.selectedPi)+'uu'+JSON.stringify(currentData.selectedCTP));
            //alert(JSON.stringify(component.get('v.currentPi'))+'uu'+JSON.stringify(component.get('v.currentStudy')));

       		//component.set('v.currentPi', currentData.selectedPi); 
       		//component.set('v.currentStudy', currentData.selectedCTP); 
       		//component.set('v.currentPi', component.get('v.currentPi'));
            component.set('v.currentPi', currentData.selectedPi);
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