/**
 * Created by Leonid Bartenev
 */
 ({
    doInit: function (component, event, helper) {
        helper.updatePathSteps(component);
        component.set('v.isHidden', true);
    },

    doProcessCollapse: function (component, event, helper) {
        var isCollapsed = component.get('v.isCollapsed');
        if (!isCollapsed) {
            component.find('statusHistory').loadHistory();
        }
    },

    showEditParticipantInformation: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var actions = component.get('v.actions');
        let isInvited = component.get('v.isInvited');
        rootComponent
            .find('updatePatientInfoAction')
            .execute(pe, actions, rootComponent, isInvited, function (enrollment) {
                component.set('v.pe', enrollment);
            });
    },
    
    closeCard: function(component,event,helper){
      component.set("v.isHidden",false);
        component.set('v.viewMore', true);
     /*  var appEvent = $A.get("e.c:ViewMore");
       appEvent.fire();   */
   }
});
