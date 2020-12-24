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
})