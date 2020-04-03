({
    doExecute: function (component, event, helper) {
        component.set('v.mrrResult', 'Update');
        component.set('v.mrrResult', undefined);
        try {
            component.find('spinner').show();
            component.set('v.initialized', false);
            var params = event.getParam('arguments');
            var pe = JSON.parse(JSON.stringify(params.pe));
            component.set('v.pe', params.pe);
            component.set('v.rootComponent', params.rootComponent);
            component.set('v.isInvited', params.isInvited);
            component.set('v.callback', params.callback);
            component.set('v.frameHeight', params.frameHeight);
            component.find('spinner').hide();
            console.log('pepeMrr', component.get('v.pe.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c'));
            component.find('dialog').show();
            component.find('dialog').scrollTop();
            helper.addEventListener(component, helper);
        } catch (e) {
            console.error(e);
        }
    },
    inviteToPortal: function (component) {
        var pe = component.get('v.pe');
        communityService.executeAction(component, 'createUser', {
            peId: pe.Id,
            pcId: pe.Participant_Contact__r.Id
        }, function (returnValue) {
            communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
        });
        component.get('v.callback')(pe);
        var comp = component.find('dialog');
        comp.hide();
    },

    backToParticipant: function (component) {
        var comp = component.find('dialog');
        comp.hide();
    }
});