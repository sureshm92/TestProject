/**
 * Created by RAMukhamadeev on 2019-04-17.
 */

({
    valueChange: function (component, event, helper) {
        component.set('v.bypass', false);
        let value = event.getSource().get('v.value');
        if (!value) {
            value = null;
        }
        communityService.executeAction(component, 'searchForReferralNetworks', {
            term: value
        }, function (returnValue) {
            let currChosenNetworks = component.get('v.currChosenRefNetworks');
            let foundNetworks = returnValue;
            foundNetworks.forEach(currNetwork => {
                if (currChosenNetworks.some(coiEl => coiEl.Id === currNetwork.Id)) {
                    currNetwork.isSelected = true;
                }
            });
            component.set('v.displayedRefNetworks', foundNetworks);
        });
    },

    saveReferralNetworks: function (component) {

    },

    changeCheckBox: function (component, event) {

    }
});