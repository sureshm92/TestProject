({
    doExecute : function(component, event, helper) {
        component.set('v.CmpOpen',true);
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
        console.log('>>>execute called succes>>>');
        component.find('childCmp').RefreshCD();
    },
    doCancel: function (component, event, helper) {
        component.find('childCmp').RefreshCD();
        
        component.find('dialog').cancel();
        component.set('v.CmpOpen',false);   
        var cmpEvent = component.getEvent("CloseSSInfoEvent"); 
        cmpEvent.fire(); 
        //var appEvent = $A.get("e.c:RefreshSiteSearchEvt"); 
        //appEvent.fire(); 
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
                component.find('childCmp').RefreshCDsection();
            },
            null,
            function () {
                component.find('childCmp').RefreshCDsection();
                component.find('Spinnerpopup').hide();
            }
        );
    },
    
    doSaveandExit: function (component, event, helper) {
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
                component.set('v.CmpOpen',false);
                var cmpEvts = component.getEvent("CloseSSInfoEvent"); 
                cmpEvts.fire(); 
            },
            null,
            function () {
                component.find('Spinnerpopup').hide();
                component.find('childCmp').RefreshCD();
                component.find('dialog').cancel();
                component.set('v.CmpOpen',false);
                //component.find('dialog').hide();
                //var cmpEvent = component.getEvent("RefreshCmpEvent"); 
                //cmpEvent.fire();
                var cmpEvents = component.getEvent("CloseSSInfoEvent"); 
                cmpEvents.fire(); 
                
            }
        );
    },
    
    doClosePopups: function (component, event, helper) {
        component.set('v.CmpOpen',false);
        console.log('doClosePopups');
        var cmpEvents = component.getEvent("CloseSSInfoEvent"); 
        cmpEvents.fire();
    }
    
})