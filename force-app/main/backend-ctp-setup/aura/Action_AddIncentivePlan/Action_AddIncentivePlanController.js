({
	doExecute: function (component, event, helper) {
		console.log('DOEXECUTE');
		let params = event.getParam('arguments');
		let ipId = params.ipId;
		component.set('v.callback', params.callback);
		component.set('v.mode', params.mode);
		component.set('v.detailsExpandedStudy', true);
		component.set('v.detailsExpandedSystem', true);
		component.set('v.planName', '');
		if (!ipId) {
			communityService.executeAction(component, 'getInitData', {
				ctpId: component.get('v.recordId')
			}, function (initData) {
				component.set('v.tasks', initData.listWrapper)
				component.find('createIncentiveTask').show();
			});
		}

		if (ipId !== null) {
			if(params.mode === 'edit' || params.mode === 'view') {
				helper.callRemote(component, ipId);
				component.set('v.disableSave', false);
				component.find('createIncentiveTask').show();
			} else if(params.mode === 'clone') {
				helper.callRemote(component, ipId, true);
				component.set('v.disableSave', false);
				component.find('createIncentiveTask').show();
			}
		}

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
		var tasksWrap = component.get('v.tasks');
		var tasksWrapString = JSON.stringify(tasksWrap);
		var plName = component.get('v.planName');
		if(plName.trim()) {
			communityService.executeAction(component, 'createUpdateIncentivePlan', {
				tasksString: tasksWrapString,
				planName: plName
			}, function (ipId) {
				component.find('createIncentiveTask').hide();
				component.find('spinner').hide();

				let callback = component.get('v.callback');
				if (callback) callback(ipId);

			});
		} else {
			component.find('spinner').hide();
			communityService.showToast("Error", "error", '\n' +
				'Required field is empty');
		}
	},
	checkPlanName: function (component, event, helper) {
		var planName = component.get('v.planName');
		var planId = component.get('v.tasks');
		communityService.executeAction(component, 'checkNamePlan',  {namePlan:planName}, function(returnValue) {
			if(returnValue && planId[0].planId == null){
				component.set('v.disableSave', true);
				communityService.showToast("Error", "error", 'The incentive program already exists');
			} else {
					component.set('v.disableSave', false);
				}

		});

	},
	checking: function (component, event, helper) {
		var id = event.getSource().get('v.id')
		var aura = event.getSource().getLocalId();
		var tasks = component.get('v.tasks');
		component.set('v.tasks', tasks);
	}
});