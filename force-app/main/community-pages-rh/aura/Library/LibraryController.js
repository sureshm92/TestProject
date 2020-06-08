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
	},
     SearchRecords: function(component, event) {
         var txtsearch=event.target.value;
        component.set("v.searchvalue",txtsearch);
        var LibraryPI = component.find("childcmp");
        var search = LibraryPI.LibraryPIMethod();
    }
})