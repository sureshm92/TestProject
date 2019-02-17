/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, hepler){
        component.set('v.funnelData', undefined);
        var study = component.get('v.study');
        if(!study) return;
        var action = component.get('c.getInitData');
        action.setParams({
            trialId: study.studySite.Clinical_Trial_Profile__c,
            clinicId: component.get('v.clinicId')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var funnelDataList = JSON.parse(response.getReturnValue());
                component.set('v.funnelData', funnelDataList);
            } else {
                communityService.logErrorFromResponse(response);
                communityService.showErrorToastFromResponse(response);
            }
            spinner.hide();
        });
        $A.enqueueAction(action);

    }
})