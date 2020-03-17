/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, helper){
        helper.updatePathSteps(component);
    },

    doProcessCollapse: function (component, event, helper) {
        var isCollapsed = component.get('v.isCollapsed');
        if(!isCollapsed){
            component.find('statusHistory').loadHistory();
        }
    },

    showEditParticipantInformation: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var actions = component.get('v.actions');
        let isInvited = component.get('v.isInvited');
        rootComponent.find('updatePatientInfoAction').execute(pe, actions, rootComponent, isInvited , function (enrollment) {
            component.set('v.pe', enrollment);
        });
    },
})