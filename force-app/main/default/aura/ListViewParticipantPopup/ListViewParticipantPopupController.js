({
    doExecute : function(component, event, helper) {
        component.find('dialog').show();
        component.set('v.enable',false);
        component.set('v.finalConsentrequired',false);
        component.set('v.finalConsentvalue',false);
        var newStatus = component.get('v.statusSelected').trim();
        var studyId = component.get('v.oStudy');
        component.set('v.notesRequired',false);
        component.set('v.finalConsent',false);
        communityService.executeAction(
            component,
            'statusDetail',
            {
                newStatus : newStatus,
                studyId : studyId
            },
            function (returnValue) {
                component.set('v.stWrapper',returnValue);
                component.set('v.reasonList',returnValue.reasonMap[newStatus]);
                let reasonList = returnValue.reasonMap[newStatus];
                let reasonValue =
                    reasonList === undefined || reasonList.length == 0 ? '' : reasonList[0].value;
                component.set('v.reasonvalue', reasonValue);
                console.log(JSON.stringify(reasonValue));
                if(component.get('v.stWrapper').finalConsent && 
                   (component.get('v.stWrapper').Step == 'Enrolled' ||
                    component.get('v.stWrapper').Step == 'Randomization')){
                    component.set('v.finalConsent',true); 
                    if(newStatus === "Enrollment Success"){
                        component.set('v.finalConsentrequired',true);
                        component.set('v.enable',true);
                    }else if(newStatus === "Randomization Success"){
                        component.set('v.finalConsentrequired',true);
                        component.set('v.enable',true);
                    }
                    else{
                         component.set('v.enable',false);
                      }
                }else{
                    component.set('v.enable',false);
                }
            }
            
        );
    },
    
    doCancel: function (component, event, helper) {
        component.set('v.enable',false);
        component.set('v.finalConsentrequired',false);
        component.find('dialog').hide();
        var p = component.get('v.parentComp');
        p.changeStatusTo();
    },
    
    updateNotesRequired: function(component, event, helper) { 
        let stWrapper = component.get('v.stWrapper');
        let selectedReason = component.find('reasonList').get('v.value');
        var newStatus = component.get('v.statusSelected').trim();
        component.set('v.reasonvalue',selectedReason);
        component.set(
            'v.notesRequired',
            stWrapper.notesRequiredMap[newStatus + ';' + selectedReason]
        );
        var note = component.find("notes").get("v.value");
        if(!note || 0 === note.length)
        {
            console.log('empty');
            if(component.get('v.notesRequired')){
                component.set('v.enable',true);
            }else{  component.set('v.enable',false);
            }
        }else{ console.log('notempty**');
               component.set('v.enable',false);
        }
        
    },
    
    doSave: function(component, event, helper) { 
        var peId = component.get('v.SelectedIds');
        var newStatus = component.get('v.statusSelected').trim();
        var notes = component.get('v.stWrapper').notes;
        //let selectedReason = component.find('reasonList').get('v.value');
        let selectedReason = component.get('v.reasonvalue');
        var studyId = component.get('v.oStudy');
        var oParticipantStatus = component.get('v.oParticipantStatus');
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'updateParticipantStatus',
            {
                peIdList : peId,
                StatusToUpdate : newStatus,
                Notes : notes,
                reason : selectedReason,
                studyId : studyId,
                finalconsent : component.get('v.finalConsentvalue'),
                oParticipantStatus : oParticipantStatus
            },
            function (returnValue) {
                component.find('spinner').hide();
                component.find('dialog').hide();
                var p = component.get('v.parentComp');
                p.changeStatusTo();
            }
        );
    },
    
    onBooleanValueChange:function(component, event, helper) {
        //component.set('v.finalConsentvalue',!component.get('v.finalConsentvalue'));
         var newStatus = component.get('v.statusSelected').trim();
         var note = component.find("notes").get("v.value");
        
        if(newStatus == 'Enrollment Success'){
            if(component.get('v.finalConsentvalue')){
                component.set('v.enable',false);
            }else{
                 component.set('v.enable',true);
            }
        }
        if(newStatus == 'Randomization Success'){
            if(component.get('v.finalConsentvalue')){
                component.set('v.enable',false);
            }else{
                 component.set('v.enable',true);
            }
        }
         if(!note || 0 === note.length)
         {
             if(component.get('v.notesRequired')){
                component.set('v.enable',true);
            }
         }
    },
    checkNotesRequiredValidity:function(component, event, helper) {
        var note = component.find("notes").get("v.value");
        var newStatus = component.get('v.statusSelected').trim();
        if(!note || 0 === note.length)
        {
            console.log('empty');
            if(component.get('v.notesRequired')){
                component.set('v.enable',true);
            }else{ 
                if(newStatus == 'Enrollment Success'){
                    if(component.get('v.finalConsentvalue')){
                        component.set('v.enable',false);
                    }else{
                        component.set('v.enable',true);
                    }
                }else if(newStatus == 'Randomization Success'){
                    if(component.get('v.finalConsentvalue')){
                        component.set('v.enable',false);
                    }else{
                        component.set('v.enable',true);
                    }
                }else{
                    component.set('v.enable',false);
                }
             }
        }else{ console.log('notempty');
             if(newStatus == 'Enrollment Success'){
                    if(component.get('v.finalConsentvalue')){
                        component.set('v.enable',false);
                    }else{
                        component.set('v.enable',true);
                    }
                }else if(newStatus == 'Randomization Success'){
                    if(component.get('v.finalConsentvalue')){
                        component.set('v.enable',false);
                    }else{
                        component.set('v.enable',true);
                    }
                }else{
                    component.set('v.enable',false);
                }
        }
    }
})