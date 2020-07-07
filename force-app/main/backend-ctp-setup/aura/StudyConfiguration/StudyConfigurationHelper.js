({
	saveCTPHelper : function(component, event, helper) {
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
})