/**
 * Created by Nargiz Mamedova on 12/9/2019.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', {
            ctpId : component.get('v.recordId')
         }, function (initData) {
            component.set('v.ctp', initData.ctp);
            component.set('v.user_has_permission', initData.user_has_permission);
            component.set('v.noVisitPlansMessage', initData.noVisitPlansMessage);
            component.find('spinner').hide();
        });

    },

    saveCTP: function (component, event, helper) {
        let source = event.getSource().get('v.name');

        let appEvent = $A.get("e.c:TaskToggleEvent");
        if(source === 'visitScheduleToggle') {
            let vsValue = component.find('vsToggle').get('v.checked');
            component.find('stToggle').set('v.checked', !vsValue);
        }
        if(source === 'statusTimelineToggle') {
            let stValue = component.find('stToggle').get('v.checked');
            component.find('vsToggle').set('v.checked', !stValue);
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