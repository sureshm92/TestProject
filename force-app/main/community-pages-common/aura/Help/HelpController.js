({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
        component.set('v.helpText', $A.get('$Label.c.PG_HLP_HI_Participant').replace('##CommunityName', communityService.getTemplateProperty('CommunityName')));
        component.set('v.isInitialized', true);
    },

})