/**
 * Created by Leonid Bartenev
 */
({

    updateMRRStatus: function (component, status) {
        component.set('v.showSpinner', true);
        var pe = component.get('v.searchResult').pe;
        var action = component.get('c.setMRRStatus');
        action.setParams({
            peJSON: JSON.stringify(pe),
            status: status
        });
        action.setCallback(this, function (response) {
            var searchResult = component.get('v.searchResult');
            if(searchResult.pe.Id) return;
            if (response.getState() === "SUCCESS") {
                searchResult.pe = JSON.parse(response.getReturnValue());
                component.set('v.searchResult', searchResult);
                component.set("v.mrrResult", status);
            } else {
                communityService.logErrorFromResponse(response);
                communityService.showErrorToastFromResponse(response);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    addEventListener: function (component, helper) {
        if(!component.serveyGizmoResultHandler){
            component.serveyGizmoResultHandler = $A.getCallback(function(e) {
                //window.removeEventListener('message', component.serveyGizmoResultHandler);
                if(component.isValid()){
                    if(e.data.messageType === 'SurveyGizmoResult'){
                        if(e.data.success){
                            helper.updateMRRStatus(component, 'Pass');
                        }else{
                            helper.updateMRRStatus(component, 'Fail');
                        }
                        //console.log('Gizmo mrr result: ' + window.atob(e.data.pdfContent));
                        //component.set('v.resultData', e.data.pdfContent);
                    } else if(e.data.messageType === 'SurveyGizmoHeight'){
                        component.set('v.frameHeight', (e.data.value + 30) + 'px');
                    }
                }
            });
            window.addEventListener('message', component.serveyGizmoResultHandler);
        }
    }

})