({
	doExecute: function (component, event, helper) {
		console.log('DOEXECUTE');
		component.set('v.detailsExpandedStudy', true);
		component.set('v.detailsExpandedSystem', true);
		component.set('v.planName', '');
		communityService.executeAction(component, 'getInitData', {
				ctpId: component.get('v.recordId')
			}, function (initData) {
			component.set('v.tasks', initData.listWrapper)
			component.set("v.studyInfo", initData.infoStudy);
			component.find('createIncentiveTask').show();
		});

		let params = event.getParam('arguments');
		component.set('v.callback', params.callback);

	},
	toggleViewStudy: function (cmp, event, helper) {
		let detailsExpanded = cmp.get("v.detailsExpandedStudy");
		if (detailsExpanded) {
			cmp.set("v.detailsExpandedStudy", false);
		} else {
			cmp.set("v.detailsExpandedStudy", true);
		}
	},
	toggleViewSystem: function (cmp, event, helper) {
		let detailsExpanded = cmp.get("v.detailsExpandedSystem");
		if (detailsExpanded) {
			cmp.set("v.detailsExpandedSystem", false);
		} else {
			cmp.set("v.detailsExpandedSystem", true);
		}
	},
	doCancel: function (component, event, helper) {
		let modalName = event.getSource().get('v.name');
		component.find(modalName).hide();
	},
	doSave: function (component, event, helper) {
		component.find('spinner').show();
		var plName = component.get('v.planName');
		var tasksWrap = component.get('v.tasks');
		var tasksWrapString = JSON.stringify(tasksWrap);
		communityService.executeAction(component, 'createIncentivePlan',  {tasksString:tasksWrapString, planName:plName}, function(ipId) {
			component.find('createIncentiveTask').hide();
			component.find('spinner').hide();

			let callback = component.get('v.callback');
			if (callback) callback(ipId);

		});
	},
	checkPlanName: function (component, event, helper) {
		var planName = component.get('v.planName');
		console.log('TTT', JSON.parse(JSON.stringify(component.get('v.tasks'))));
		communityService.executeAction(component, 'checkNamePlan',  {namePlan:planName}, function(returnValue) {
			if(returnValue){
				component.set('v.disableSave', true);
				communityService.showToast("Error", "error", 'The incentive program already exists');
			} else{
				component.set('v.disableSave', false);
			}

		});

	},
	checking: function (component, event, helper) {
		var id = event.getSource().get('v.id')
		var aura = event.getSource().getLocalId();
		var tasks = component.get('v.tasks');
		tasks[id][aura] = !tasks[id][aura];
		component.set('v.tasks', tasks);

	}
});