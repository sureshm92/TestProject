({
    getPESH : function(component,event,helper) {
        var params = event.getParam('arguments');
        var pe = JSON.parse(JSON.stringify(params.pe));
        communityService.executeAction(
            component,
            'getPESHrecord',
            {
                peId : pe.Id
            }, function (returnValue) {
                component.set('v.dateofSH',returnValue);
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
                component.set('v.dateofSH',returnValue);
                component.set('v.status','Eligibility Passed');
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
    setPopUpName: function (component, pe){
        let fNameInitial = (pe.Participant__r.First_Name__c===null||pe.Participant__r.First_Name__c===undefined)?'':pe.Participant__r.First_Name__c.substring(0,1).toUpperCase()+ ' ';
        let mNameInitial = (pe.Participant__r.Middle_Name__c===null||pe.Participant__r.Middle_Name__c===undefined)?'':pe.Participant__r.Middle_Name__c.substring(0,1).toUpperCase()+' ';
        let lNameInitial = (pe.Participant__r.Last_Name__c===null||pe.Participant__r.Last_Name__c===undefined)?'':pe.Participant__r.Last_Name__c.substring(0,1).toUpperCase();
        
        component.set('v.popUpTitle', fNameInitial + mNameInitial + lNameInitial);
    },	
})