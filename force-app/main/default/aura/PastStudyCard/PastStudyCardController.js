({
	openSingleFile: function(component, event, helper) {
		var fileThatFireEvent = event.getSource();
		var fileValue = fileThatFireEvent.get('v.value') ;

		console.log('fileValue', fileValue);
		component.set('v.isPopupOpen', true);
		component.set('v.chosenFile', fileValue);
	},

	navigateToPage : function (component, event, helper) {
		var resourceType = 'Study_Document';
		var resourceId = event.currentTarget.dataset.id;
		var recId = communityService.getUrlParameter('id');
		communityService.navigateToPage("resources?resourceType=" + resourceType + '&resId=' + resourceId + '&ret=' + communityService.createRetString());
	}


})