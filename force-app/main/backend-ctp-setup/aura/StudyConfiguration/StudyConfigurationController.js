/**
 * Created by Nargiz Mamedova on 12/9/2019.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', {
            ctpId : component.get('v.recordId')
         }, function (ctp) {
            component.set('v.ctp', ctp);
            component.find('spinner').hide();
        });
    },

    saveCTP: function (component, event, helper) {
        let stValue = component.find('stToggle').get('v.checked');
        component.find('vsToggle').set('v.checked', !stValue);

        component.find('spinner').show();
        communityService.executeAction(component, 'saveChanges', {
            ctp: component.get('v.ctp')
        }, function () {
            component.find('spinner').hide();
            communityService.showSuccessToast('Success', 'Study Configuration setting saved!');
        })
    }
});