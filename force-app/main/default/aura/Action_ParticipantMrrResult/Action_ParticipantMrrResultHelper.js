({
    updateMRRStatus: function (component, status, gizmoData) {
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'setMRRStatus', {
            peJSON: JSON.stringify(pe),
            status: status,
            surveyGizmoData: gizmoData
        }, function (returnValue) {
            component.set("v.mrrResult", status);
            //component.find('dialog').scrollTop();
            component.get('v.callback')(pe);
            ;
        }, null, function () {
            communityService.logErrorFromResponse(response);
            communityService.showErrorToastFromResponse(response);
        });
    },

    addEventListener: function (component, helper) {
        if (!component.serveyGizmoResultHandler) {
            component.serveyGizmoResultHandler = $A.getCallback(function (e) {
                if (component.isValid()) {
                    if (e.data.messageType === 'SurveyGizmoResult') {
                        var gizmoData = null;
                        if (e.data.pdfContent) {
                            gizmoData = e.data.pdfContent;
                        }
                        if (e.data.success) {
                            helper.updateMRRStatus(component, 'Pass', gizmoData);
                        } else {
                            helper.updateMRRStatus(component, 'Fail', gizmoData);
                        }
                    } else if (e.data.messageType === 'SurveyGizmoHeight') {
                        component.set('v.frameHeight', (e.data.value + 30) + 'px');
                    }
                }
            });
            window.addEventListener('message', component.serveyGizmoResultHandler);
        }
    }
});