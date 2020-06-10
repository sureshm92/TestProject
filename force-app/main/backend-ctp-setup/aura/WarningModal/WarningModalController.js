({
	doShow: function (component, event) {
		var params = event.getParam('arguments');
		component.set('v.textBody', params.textBody);
		component.find('shareModal').show();
	},

	doHide: function (component) {
		component.find('shareModal').hide();
	},

	doDelete: function (component, event, helper) {
		component.get('v.parent').doDeletePlan();
	},

	doCheckBoxChanges: function (component, event, helper) {
		component.get('v.parent').doCheckBoxChange();
	},

	doCancel: function (component, event, helper) {
		component.find('shareModal').hide();
	}
})