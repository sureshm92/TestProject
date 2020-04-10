/**
 * Created by Leonid Bartenev
 */
({
    updateMRRStatus: function (component, status) {
        let spinner = component.find('mainSpinner');
        spinner.show();
        let pe = component.get('v.searchResult').pe;
        communityService.executeAction(component, 'setMRRStatus', {
            peJSON: JSON.stringify(pe),
            status: status
        }, function (retrunValue) {
            searchResult.pe = JSON.parse(response.getReturnValue());
            component.set('v.searchResult', searchResult);
            component.set('v.mrrResult', status);
            spinner.hide();
        });
    },

    addEventListener: function (component, helper) {
        if (!component.serveyGizmoResultHandler) {
            component.serveyGizmoResultHandler = $A.getCallback(function (e) {
                if (component.isValid()) {
                    if (e.data.messageType === 'SurveyGizmoResult') {
                        if (e.data.success) {
                            helper.updateMRRStatus(component, 'Pass');
                        } else {
                            helper.updateMRRStatus(component, 'Fail');
                        }
                        component.set('v.resultData', e.data.pdfContent);
                    } else if (e.data.messageType === 'SurveyGizmoHeight') {
                        component.set('v.frameHeight', e.data.value + 'px');
                    }
                }
            });
            window.addEventListener('message', component.serveyGizmoResultHandler);
        }
    }
});