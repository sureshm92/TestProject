/**
 * Created by Alexey Moseev.
 */

({

    showParticipantEmansipationWizard: function(component, event, helper) {
        let pe = component.get('v.pe');
        let rootComponent = component.get('v.parent');
        rootComponent.find('emancipationWizard').execute(pe, rootComponent, null);
    }

});