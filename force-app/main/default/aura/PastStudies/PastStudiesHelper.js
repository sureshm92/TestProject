({
	getPatientEnrollmentData: function(component, event, helper){
		this.spinnerShow(component);
		let action = component.get('c.getPastStudyRecords');
		if (action) {
			action.setParams({
				//resId: component.get('v.recordId')
			});
			action.setCallback(this, function(response) {
				let state = response.getState();
				if (state === 'SUCCESS') {
					this.spinnerHide(component);
					console.log('SUCCESS RESPONSE', response.getReturnValue());
					component.set('v.pastStudiesList', response.getReturnValue());
				}
				else if (state === 'ERROR') {
					let errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.log('Error message: ' +
								errors[0].message);
						}
						this.spinnerHide(component);
					} else {
						console.log('Unknown error');
					}
				}
			});
			$A.enqueueAction(action);
		}
	},

	spinnerShow: function (component) {
		let spinner = component.find('spinner');
		if (spinner) {
			spinner.show();
		}
	},

	spinnerHide: function (component) {
		let spinner = component.find('spinner');
		if (spinner) {
			spinner.hide();
		}
	},
});