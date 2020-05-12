({
	doInit : function(component, event, helper) {
		var spinner = component.find('mainSpinner');
		spinner.hide();
	},
	toggleResourceView: function (cmp, event, helper) {
		let detailsExpanded = cmp.get("v.detailsExpanded");
		if (detailsExpanded) {
			cmp.set("v.detailsExpanded", false);
		} else {
			cmp.set("v.detailsExpanded", true);
		}
	}
})