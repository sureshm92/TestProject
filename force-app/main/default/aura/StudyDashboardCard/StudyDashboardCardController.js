(
	{
		doInit : function (component, event, helper) {
			helper.preparePathItems(component);
		},

		doLoadHistoryOnOpen : function (component) {
			var isOpened = !component.get('v.detailCollapsed');
			if (isOpened) {
				component.find('statusDetail').loadHistory();
			}
		},

		navigateToStudy : function (component, event, helper) {
			communityService.navigateToPage("study-workspace?id=a1R1h000000VpuBEAS");
		},
	}
)