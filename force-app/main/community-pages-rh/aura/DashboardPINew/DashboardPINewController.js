/**
 * Created by Alexey Moseev.
 */
({
    doinit: function (component, event, helper) {
        var piData = component.get('v.piData');
        component.set('v.communityTemplate', communityService.getCurrentCommunityTemplateName());
        component.set('v.delegatePIPicklistvalues', piData.delegatePIsPicklist);
        component.set('v.piCTPPicklist', piData.piCTPPicklist);
        component.set('v.currentPi', piData.selectedPi);
        component.set('v.currentStudy', piData.selectedCTP);
        //RH-5163
        helper.showPPDashboard(component,helper,piData);
      
      
        setTimeout(function(){
            var childComponent = component.find("funnelRTL");
            var message = childComponent.RTLRendering();
        }, 3000);

    },

    refreshDataOnStudyChange: function (component, event, helper) {
        var piData = component.get('v.piData');
        piData.selectedPi = component.get('v.currentPi');
        piData.selectedCTP = component.get('v.currentStudy');
        //var spinner = component.find('mainSpinner');
        //spinner.show();
        helper.callServerMethodOnStudyChange(
            component,
            'getInitData',
            communityService.getUserMode(),
            communityService.getCurrentCommunityTemplateName(),
            communityService.getDelegateId(),
            piData.selectedPi,
            null,
            'PIChange',
            helper
        );
    },

    refreshDataOnPiChange: function (component, event, helper) {
        var piData = component.get('v.piData');
        piData.selectedPi = component.get('v.currentPi');
        piData.selectedCTP = component.get('v.currentStudy');
        //var spinner = component.find('mainSpinner');
        // spinner.show();
        helper.callServerMethodOnPiChange(
            component,
            'getInitData',
            communityService.getUserMode(),
            communityService.getCurrentCommunityTemplateName(),
            communityService.getDelegateId(),
            piData.selectedPi,
            null,
            'PIChange',
            helper
        );
    }
});