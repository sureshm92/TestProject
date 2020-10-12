/**
 * Created by Enugothula Srinath
 * Date-21/05/2020
 */

({
	doInit: function (component, event, helper) {
		if (!communityService.isInitialized()) return;
		else {
			component.set('v.initialized', true);
			component.set(
				'v.isMobileApp',
				communityService.isCurrentSessionMobileApp()
			);
		}
	},
	doGenerateReport: function (component, event, helper) {
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
