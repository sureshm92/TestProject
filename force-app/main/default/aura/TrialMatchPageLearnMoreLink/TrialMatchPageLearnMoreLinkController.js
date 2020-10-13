/**
 * Created by Enugothula Srinath
 * Date-21/05/2020
 */

({
	doInit: function (component, event, helper) {
		if (!communityService.isInitialized()) return;
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
					helper.generateLearnMorePDF(component);
				}),
				100
			);
		});
	}
});
