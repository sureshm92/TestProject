/**
 * Created by Alexey Moseev.
 */

({

    showParticipantEmansipationWizard: function(component, event, helper) {
        let rootComponent = component.get('v.parent');
        rootComponent.find('emansipationWizard').execute(pe, rootComponent, null);
    }

});