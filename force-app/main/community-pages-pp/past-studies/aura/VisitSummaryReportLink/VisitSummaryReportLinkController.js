/**
 * Created by Leonid Bartenev
 */

({
	doInit: function (component) {
		component.set('v.initialized', true);
	},

	doGenerateReport: function (component, event, helper) {
		if (
			component.get('v.initialized') &&
			communityService.isCurrentSessionMobileApp()
		) {
			communityService.showInfoToast(
				'Info!',
				$A.get('$Label.c.Pdf_Not_Available'),
				5000
			);
			return;
		}
		helper.uploadReportData(component, function () {
			window.setTimeout(
				$A.getCallback(function () {
					helper.generateReport(component);
				}),
				100
			);
		});
	}
});
