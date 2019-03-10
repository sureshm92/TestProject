(
	{
		doInit : function (component, event, helper) {
			component.set("v.videoResource", helper.getStubResource("Video"));
			component.set("v.articleResource", helper.getStubResource("Article"));
		},

		navigateToPage : function (component, event, helper) {
			var resourceType = event.currentTarget.classList.contains("resource-video") ? "Video" : "Article";
			//todo must be changed
			var recId = communityService.getUrlParameter('id');
			if(!recId) {
				recId = "a1R1h000000VpuBEAS";
			}
			communityService.navigateToPage("resources?resourceType=" + resourceType + "&id=" + recId);
		},
	}
)