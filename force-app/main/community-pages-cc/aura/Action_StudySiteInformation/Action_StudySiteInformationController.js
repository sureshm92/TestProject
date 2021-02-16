({
    doExecute : function(component, event, helper) {
        component.set('v.CmpOpen',true);
        component.find('dialog').show();
       /**  component.set('v.siteInfoComplete',component.get('v.studyInformation.siteInfoComplete'));
        component.set('v.trainingComplete',component.get('v.studyInformation.trainingComplete'));
        component.set('v.supressEmail',component.get('v.studyInformation.receivePIEmail'));
        component.set('v.optIn',component.get('v.studyInformation.optInForWarmTransfer')); **/
        var ssId = component.get('v.studyInformation').siteId;
        component.find('Spinnerpopup').show();
        communityService.executeAction(
            component, 'getDelegateMap',
            {
                StudySiteId : ssId
            },
            function (returnValue) 
            {
                component.set('v.delegateList',returnValue.StudySitesDelegatesPicklist);
                component.set('v.studyInformation.sitePhone',returnValue.sitePhone);
                component.set('v.studyInformation.siteEmail',returnValue.siteEmail);
                component.set('v.studyInformation.optInForWarmTransfer',returnValue.optInForWarmTransfer);
                component.set('v.studyInformation.trainingComplete',returnValue.trainingComplete);
                component.set('v.studyInformation.siteInfoComplete',returnValue.siteInfoComplete);
                component.set('v.studyInformation.receivePIEmail',returnValue.receivePIEmail);
                component.set('v.studyInformation.siteStaff',returnValue.sitestaff);
                component.set('v.siteInfoComplete',returnValue.siteInfoComplete);
                component.set('v.trainingComplete',returnValue.trainingComplete);
                component.set('v.supressEmail',returnValue.receivePIEmail);
                component.set('v.optIn',returnValue.optInForWarmTransfer);
                component.find('Spinnerpopup').hide();
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
        if(component.get('v.studyInformation').supressPIEmail &&
           component.get('v.studyInformation').receivePIEmail){
            communityService.showToast(
                'error',
                'error',
                $A.get('$Label.c.CC_Suppress_PI_Email')
            );
        }
        else{
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
                        $A.get('$Label.c.CC_Success_Save_Message')
                    );
                    component.set('v.isStudyInfoModified',false);
                    component.find('childCmp').RefreshCDsection();
                },
                null,
                function () {
                    component.set('v.isStudyInfoModified',false);
                    component.find('childCmp').RefreshCDsection();
                    component.find('Spinnerpopup').hide();
                }
            );
        }
    },
    
    doSaveandExit: function (component, event, helper) {
        if(component.get('v.studyInformation').supressPIEmail &&
           component.get('v.studyInformation').receivePIEmail){
            communityService.showToast(
                'error',
                'error',
                $A.get('$Label.c.CC_Suppress_PI_Email')
            );
        }
        else{
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
                        $A.get('$Label.c.CC_Success_Save_Message')
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
        }
    },
    
    doClosePopups: function (component, event, helper) {
        component.set('v.CmpOpen',false);
        console.log('doClosePopups');
        var cmpEvents = component.getEvent("CloseSSInfoEvent"); 
        cmpEvents.fire();
    }
    
})