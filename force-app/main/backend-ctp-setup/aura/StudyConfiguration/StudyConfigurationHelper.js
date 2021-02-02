({
    saveCTPHelper: function (component, event, helper) {
        var source = event.getSource().get('v.name');
        console.log('Source: ' + source);
        var appEvent = $A.get('e.c:TaskToggleEvent');
        if (source === 'visitScheduleToggle') {
            let vsValue = component.find('vsToggle').get('v.checked');
            component.find('stToggle').set('v.checked', !vsValue);
        }
        if (source === 'statusTimelineToggle') {
            let stValue = component.find('stToggle').get('v.checked');
            component.find('vsToggle').set('v.checked', !stValue);
        }

        if(source === 'saveDelayDays'){
            component.set('v.delay_days', component.get("v.ctp.Delayed_No_Of_Days__c"));
        }
        else{
            component.set('v.ctp.Delayed_No_Of_Days__c', component.get("v.delay_days"));
        }
        component.find('spinner').show();
        if((source === 'saveDelayDays' && component.find('delayedDays').reportValidity()) || source !== 'saveDelayDays'){
            communityService.executeAction(
                component,
                'saveChanges',
                {
                    ctp: component.get('v.ctp')
                },
                function () {
                    component.find('spinner').hide();
                    communityService.showSuccessToast('Success', 'Study Configuration setting saved!');
                }
        	);
        }
        else{
            component.find('spinner').hide();
          //  communityService.showToast('Error', 'error', 'The incentive program already exists');
        }
        if (source === 'tasksToggle') {
            $A.get('e.force:refreshView').fire();
            appEvent.fire();
        }
    }
});
