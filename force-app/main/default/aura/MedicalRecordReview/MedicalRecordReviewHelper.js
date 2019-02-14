/**
 * Created by Leonid Bartenev
 */
({
    updateMRRStatus: function (component, status) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        var pe = component.get('v.searchResult').pe;
        communityService.executeAction(component, 'setMRRStatus', {
            peJSON: JSON.stringify(pe),
            status: status
        }, function (retrunValue) {
            searchResult.pe = JSON.parse(response.getReturnValue());
            component.set('v.searchResult', searchResult);
            component.set("v.mrrResult", status);
            spinner.hide();
        })
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
                        console.log('Gizmo mrr result: ' + window.atob(e.data.pdfContent));
                        component.set('v.resultData', e.data.pdfContent);
                    } else if(e.data.messageType === 'SurveyGizmoHeight'){
                        component.set('v.frameHeight', e.data.value + 'px');
                    }
                }
            });
            window.addEventListener('message', component.serveyGizmoResultHandler);
        }
    }
})