(
	{
		doInit : function (component, event, helper) {

			var spinner = component.find('spinner');
			if(spinner){ spinner.show(); }

			var resourceMode = component.get("v.resourceMode");
			var resourceType = component.get("v.resourceType");

			communityService.executeAction(component, 'getResources', {
				resourceType: component.get('v.resourceType'),
				resourceMode: component.get('v.resourceMode')
			}, function (returnValue) {
				component.set("v.resources", returnValue);
				var spinner = component.find('spinner');
				if(spinner){ spinner.hide(); }
			}, function (errorResponse) {
				//todo add logic for handling errors like "no articles available" etc.
			});

			if (resourceMode === "Favorite") {
				component.set("v.resourceTitle", resourceType + "s - Favorites");
			} else {
				component.set("v.resourceTitle", resourceType + 's');
			}
		},
	}
)