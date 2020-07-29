({
    
    createUserForPatient: function(component, event, helper){
        var sendEmails = component.get('v.sendEmails');
        var pe = component.get('v.pe');
        component.find('spinner').show();
        communityService.executeAction(component, 'createUserForPatientProtal', {
            peJSON: JSON.stringify(pe),
            sendEmails: sendEmails
        }, function (returnvalue) {
            returnvalue = JSON.parse(JSON.stringify(returnvalue[0]));
            component.set('v.isInvited', true);
            component.set('v.userInfo', returnvalue);
            communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
            var callback = component.get('v.callback');
            if(callback){
                callback(pe);
            }
        }, null, function () {
            component.find('spinner').hide();
        });
    },
})