/**
 * Created by Alexey Moseev.
 */

({

    showParticipantEmansipationWizard: function(component, event, helper) {
        let pe = component.get('v.pe');
        let actions = component.get('v.actions');
        let rootComponent = component.get('v.parent');
        rootComponent.find('emancipationWizard').execute(pe, rootComponent, actions, null);
    }

});