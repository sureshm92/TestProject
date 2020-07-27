/**
 * Created by Alexey Moseev.
 */
({
    doinit:function(component, event, helper){
        var piData = component.get('v.piData');
        component.set('v.delegatePIPicklistvalues',piData.delegatePIsPicklist);
        component.set('v.piCTPPicklist', piData.piCTPPicklist);
        component.set('v.currentPi', piData.selectedPi);
        component.set('v.currentStudy', piData.selectedCTP);
        helper.showParticipantsContactedDashboard(component,helper,piData);

    },
    
    refreshDataOnStudyChange:function(component, event, helper){
        var piData = component.get('v.piData');
        piData.selectedPi = component.get('v.currentPi');
        piData.selectedCTP = component.get('v.currentStudy');
        var spinner = component.find('mainSpinner');
        spinner.show();
        helper.callServerMethod(component, 'getInitData', communityService.getUserMode(), communityService.getCurrentSponsorName(), communityService.getDelegateId(), piData.selectedPi, piData.selectedCTP, 'PIChange',helper);
        var currentData = component.get('v.piData');
        component.set('v.currentStudy', currentData.selectedCTP);
    },

    refreshDataOnPiChange:function(component, event, helper){
        var piData = component.get('v.piData');
        piData.selectedPi = component.get('v.currentPi');
        var spinner = component.find('mainSpinner');
        spinner.show();
        helper.callServerMethod(component, 'getInitData', communityService.getUserMode(), communityService.getCurrentSponsorName(), communityService.getDelegateId(), piData.selectedPi, null, 'PIChange',helper);
    }

})