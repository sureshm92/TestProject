/**
 * Created by Leonid Bartenev
 */
({
    updateMRRStatus: function (component, status, gizmoData) {
        component.find('mainSpinner').show();
        var pe = component.get('v.searchResult').pe;
        var preSurvey = component.get('v.preSurvey');
        var action = component.get('c.setMRRStatus');
        
        component.set('v.isUpdateCalled',true);
        action.setParams({
            peJSON: JSON.stringify(pe),
            status: status,
            surveyGizmoData: gizmoData,
            preSurvey : preSurvey.Id
        });
        action.setCallback(this, function (response) {
            var searchResult = component.get('v.searchResult');
            if (searchResult.pe.Id) return;
            if (response.getState() === 'SUCCESS') {
                searchResult.pe = JSON.parse(response.getReturnValue());
                component.set('v.searchResult', searchResult);
                component.set('v.mrrResult', status);
                console.log('sR', JSON.parse(JSON.stringify(component.get('v.searchResult'))));
            } else {
                communityService.logErrorFromResponse(response);
                communityService.showErrorToastFromResponse(response);
            }
            component.find('mainSpinner').hide();
        });
        $A.enqueueAction(action);
    },

    addEventListener: function (component, helper) {
        if (!component.serveyGizmoResultHandler) {
            component.serveyGizmoResultHandler = $A.getCallback(function (e) {
                //window.removeEventListener('message', component.serveyGizmoResultHandler);
                if (component.isValid()) {   
                    if (e.data.messageType === 'SurveyGizmoResult') {
                        var gizmoData = null;
                        var isUpdateMRRCalled = component.get('v.isUpdateCalled');
                        if (e.data.pdfContent) {
                            gizmoData = e.data.pdfContent;
                        }
                        if (e.data.success &&  !isUpdateMRRCalled) {
                            helper.updateMRRStatus(component, 'Pass', gizmoData);
                        } else if(!isUpdateMRRCalled){
                            helper.updateMRRStatus(component, 'Fail', gizmoData);
                        }
                        //console.log('Gizmo mrr result: ' + window.atob(e.data.pdfContent));
                        //component.set('v.resultData', e.data.pdfContent);
                    } else if (e.data.messageType === 'SurveyGizmoHeight') {
                        component.set('v.frameHeight', e.data.value + 30 + 'px');
                    }
                }
            });
            window.addEventListener('message', component.serveyGizmoResultHandler);
        }
    }
});