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
        var pathItems = helper.preparePathItems(component);
        var anchor = event.currentTarget.value;
        var actions = component.get('v.actions');
        rootComponent.find('updatePatientInfoAction').execute(pe, pathItems, anchor, actions, rootComponent, function (enrollment) {
            component.set('v.pe', enrollment);
        });
    },
})