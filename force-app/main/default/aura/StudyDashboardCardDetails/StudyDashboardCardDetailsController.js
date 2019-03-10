(
	{
		doInit : function (component, event, helper) {

			var pathList = component.get('v.pathItems');
			var currentIndex;
			for (var i = 0; i < pathList.length; i++) {
				if (pathList[i].isCurrent) {
					currentIndex = i;
					break;
				}
			}
			var reversedList = [];
			for (i = currentIndex; i >= 0; i--) {

				if (i <= currentIndex) {
					reversedList.push(pathList[i]);
				}
			}
			component.set('v.pathItemsReversed', reversedList);
		},
	}
)