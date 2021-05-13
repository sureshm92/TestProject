({
    getPESH : function(component,event,statusList,helper) {
        var params = event.getParam('arguments');
        var pe = params.pe;
        var status = pe.Participant_Status__c;
        var statusLists = [];
        statusLists.push('Contact Attempted');
        statusLists.push('Eligibility Failed');
        statusLists.push('Pre-review Failed');
        statusLists.push('Pre-review Passed');
        statusLists.push('Received');
        statusLists.push('Successfully Contacted');
        communityService.executeAction(
            component,
            'getPESHrecord',
            {
                peId : pe.Id
            }, function (returnValue) {
            var returnVal = JSON.parse(returnValue);    
            var status = returnVal.currentStatus;
            component.set('v.dateofSH',returnVal.dateOfSH);
            if(status == 'Eligibility Passed'){
                component.set('v.promoteToSHStatus',false);
            }else if(statusLists.includes(status) 
                     && (returnValue==null || returnValue == undefined 
                     || (returnValue!=null && returnValue != undefined 
                         && returnVal.shLogStatus != 201))
                    ){
                component.set('v.promoteToSHStatus',true);
            }
            else{
                    component.set('v.promoteToSHStatus',false);
            }
                
            });
    },
     getpeshdate : function(component,event,helper) {
        var pe = component.get('v.pe');
        communityService.executeAction(
            component,
            'getPESHrecord',
            {
                peId : pe.Id
            }, function (returnValue) {
                var returnVal = JSON.parse(returnValue);
                component.set('v.dateofSH',returnVal.dateOfSH);
                component.set('v.status','Eligibility Passed');
                component.set('v.promoteToSHStatus',false);
            });
    },
    getInvitedDate : function(component,event,helper){
        var params = event.getParam('arguments');
        var pe = JSON.parse(JSON.stringify(params.pe));
        communityService.executeAction(
            component,
            'getUser',
            {
                contactId : pe.Participant_Contact__c
            },
            function (returnValue) {
                component.set('v.invitedon',returnValue);
            });
    },
    showToast: function (component, event, helper) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            duration: 400,
            type: 'success',
            message: $A.get('$Label.c.Records_sent_to_SH')
        });
        toastEvent.fire();
    },
    
    checkParticipantNeedsGuardian: function (component, helper, event) {
        var spinner = component.find('spinner');
      //  spinner.show();
        var participant = component.get('v.participant');
        var params = event.getParam('arguments');
        console.log('>>>coming in method>>'+JSON.stringify(params));
        component.set('v.callbackDOB', params.callback);
        var callback = component.get('v.callbackDOB');
        communityService.executeAction(
            component,
            'checkNeedsGuardian',
            {
                participantJSON: JSON.stringify(participant)
            },
            function (returnValue) {
                console.log('isNeedGuardian:>>>> ' + returnValue);
                var isNeedGuardian = returnValue == 'true';
                if (!isNeedGuardian && callback) {
                    callback();
                }

                if (isNeedGuardian != component.get('v.needsDelegate')) {
                    component.set('v.needsDelegate', isNeedGuardian);
                }
            },
            null,
            function () {
              //  spinner.hide();
            }
        );
    },
    
    setPopUpName: function (component, pe){
        let fNameInitial = (pe.Participant__r.First_Name__c===null||pe.Participant__r.First_Name__c===undefined)?'':pe.Participant__r.First_Name__c.substring(0,1).toUpperCase()+ ' ';
        let mNameInitial = (pe.Participant__r.Middle_Name__c===null||pe.Participant__r.Middle_Name__c===undefined)?'':pe.Participant__r.Middle_Name__c.substring(0,1).toUpperCase()+' ';
        let lNameInitial = (pe.Participant__r.Last_Name__c===null||pe.Participant__r.Last_Name__c===undefined)?'':pe.Participant__r.Last_Name__c.substring(0,1).toUpperCase();
        
        component.set('v.popUpTitle', fNameInitial + mNameInitial + lNameInitial);
    },	
})