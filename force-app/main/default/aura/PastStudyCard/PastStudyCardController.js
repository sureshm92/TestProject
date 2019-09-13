({
	openSingleFile: function(component, event, helper) {
		var fileThatFireEvent = event.getSource();
		var fileValue = fileThatFireEvent.get('v.value') ;

		console.log('fileValue', fileValue);
		component.set('v.isPopupOpen', true);
		component.set('v.chosenFile', fileValue);
	},

	closePopUp: function(component, event, helper){
		component.set('v.isPopupOpen', false);
	}
})