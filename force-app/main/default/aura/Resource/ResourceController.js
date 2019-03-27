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
				if(!returnValue.errorMessage) {
					for(let i = 0; i < returnValue.wrappers.length; i++) {
						let title = returnValue.wrappers[i].title;
						returnValue.wrappers[i].title = title.length > 55 ? title.substring(0, 52) + '...' : title;
						let description = returnValue.wrappers[i].description;
						returnValue.wrappers[i].description = description.length > 120 ? description.substring(0, 117) + '...' : description;
					}
					component.set("v.resources", returnValue.wrappers);
					component.set("v.errorMessage", "");
				} else {
					component.set("v.errorMessage", returnValue.errorMessage);
				}
				var spinner = component.find('spinner');
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