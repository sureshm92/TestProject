(
	{
		doInit : function (component, event, helper) {

			let spinner = component.find('spinner');
			if(spinner){ spinner.show(); }

			let resourceMode = component.get("v.resourceMode");
			let resourceType = component.get("v.resourceType");

			communityService.executeAction(component, 'getResources', {
				resourceType: component.get('v.resourceType'),
				resourceMode: component.get('v.resourceMode')
			}, function (returnValue) {
				if(!returnValue.errorMessage) {
					returnValue = helper.trimLongText(returnValue);
					component.set("v.resources", returnValue.wrappers);
					component.set("v.errorMessage", "");
				} else {
					component.set("v.errorMessage", returnValue.errorMessage);
				}
				let spinner = component.find('spinner');
				if(spinner){ spinner.hide(); }
			});

			if (resourceMode === "Favorite") {
				component.set("v.resourceTitle", resourceType + "s - Favorites");
			} else {
				component.set("v.resourceTitle", resourceType + 's');
			}
		},
	}
)