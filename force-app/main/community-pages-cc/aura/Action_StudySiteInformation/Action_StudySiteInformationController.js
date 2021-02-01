({
    doExecute : function(component, event, helper) {
        component.find('dialog').show();
        component.set('v.siteInfoComplete',component.get('v.studyInformation.siteInfoComplete'));
        component.set('v.trainingComplete',component.get('v.studyInformation.trainingComplete'));
        component.set('v.supressEmail',component.get('v.studyInformation.receivePIEmail'));
        var ssId = component.get('v.studyInformation').siteId;
        communityService.executeAction(
            component, 'getDelegateMap',
            {
                StudySiteId : ssId
            },
            function (returnValue) 
            {
                component.set('v.delegateList',returnValue);
            });
    },
    doCancel: function (component, event, helper) {
        component.find('dialog').cancel();
        
    },
    
    doSave: function (component, event, helper) {
        component.find('Spinnerpopup').show();
        var siteWrapper = component.get('v.studyInformation');
        var callDisp = JSON.stringify(component.get('v.CD'));
        var result = callDisp.slice(1,-1);
        communityService.executeAction(
            component,
            'saveSSChanges',
            { 
                studySiteInfo: JSON.stringify(siteWrapper),
                accId : component.get('v.editedAccount'),
                callDisp: result,
                newCall: component.get('v.newCall')
            },
            function () {
                communityService.showToast(
                    'success',
                    'success',
                    $A.get('$Label.c.SS_Success_Save_Message')
                );
            },
            null,
            function () {
                component.find('Spinnerpopup').hide();
                component.find('dialog').hide();
            }
        );
    },
    
})