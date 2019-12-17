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
        var source = event.getSource().get('v.name');
        console.log('Source: ' + source);
        var appEvent = $A.get("e.c:TaskToggleEvent");
        if(source === 'visitScheduleToggle') {
            let vsValue = component.find('vsToggle').get('v.checked');
            component.find('stToggle').set('v.checked', !vsValue);
        }
        if(source === 'statusTimelineToggle') {
            let stValue = component.find('stToggle').get('v.checked');
            component.find('vsToggle').set('v.checked', !stValue);
        }
        if(source === 'travelVendorToggle') {
            if (!component.get('v.ctp.Travel_Vendor_Is_Available__c').val)  {
                component.set('v.ctp.Travel_Support_On_Relevant_Links__c', false);
            }
        }

        component.find('spinner').show();
        communityService.executeAction(component, 'saveChanges', {
            ctp: component.get('v.ctp')
        }, function () {
            component.find('spinner').hide();
            communityService.showSuccessToast('Success', 'Study Configuration setting saved!');
        });
        if(source === 'tasksToggle') {
            $A.get('e.force:refreshView').fire();
            appEvent.fire();
        }
    }
});