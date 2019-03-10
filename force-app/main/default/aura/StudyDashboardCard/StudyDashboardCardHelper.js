(
	{
		preparePathItems : function (component) {

			var statuses = this.getStatuses();
			var statusesMap = this.getStatusesMap();
			var currentPEState = statusesMap[statuses[1]];

			component.set('v.showPath', true);
			// component.set('v.userMode', communityService.getUserMode());

			var pathList = [];
			var iconMap = {
				success : 'icon-check',
				failure : 'icon-close',
				neutral : '',
				in_progress : ''
			};
			for (var i = 0; i < statuses.length; i++) {

				//default values for path item:
				var pathItem = statusesMap[statuses[i]];
				pathItem.name = statuses[i];

				if (currentPEState) {
					if (pathItem.order === currentPEState.order) {
						pathItem.left = 'success';
						pathItem.state = currentPEState.state;
						pathItem.isCurrent = true;
					} else if (pathItem.order < currentPEState.order) {
						pathItem.left = 'success';
						pathItem.state = 'success';
					} else {
						pathItem.state = 'neutral';
						pathItem.left = 'neutral';
					}
				}

				pathItem.iconName = iconMap[pathItem.state];
				pathList.push(pathItem);
				if (i > 0) {
					pathList[i - 1].right = pathItem.left;
					pathList[i - 1].nextState = pathItem.state;
				}
			}
			component.set('v.pathItems', pathList);
		},

		getStatuses : function () {
			return ["Enrolled", "Treatment Started", "Treatment Ended", "Follow-Up", "Participation Complete", "Trial Conclusion"];
		},

		getStatusesMap : function () {
			return {
				"Enrolled" : {
					order : 1,
					state : "success",
					history : [{
						message : "on",
						changeDate : "03-Feb-2019"
					}]
				},
				"Treatment Started" : {
					order : 2,
					state : "in_progress",
					history : [{
						message : "Scheduled for:",
						changeDate : "20-Feb-2019"
					}]
				},
				"Treatment Ended" : {
					order : 3
				},
				"Follow-Up" : {
					order : 4
				},
				"Participation Complete" : {
					order : 5
				},
				"Trial Conclusion" : {
					order : 6
				}
			};
		},
	}
)