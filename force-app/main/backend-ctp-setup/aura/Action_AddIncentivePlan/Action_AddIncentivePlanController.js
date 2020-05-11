({
	doExecute: function (component, event, helper) {
		component.set('v.detailsExpandedStudy', true);
		component.set('v.detailsExpandedSystem', true);
		communityService.executeAction(component, 'getIncentiveTasks',  {}, function (returnValue) {
			component.set("v.tasks", returnValue);
			console.log('tasks', component.get('v.tasks'));
		});
		communityService.executeAction(component, 'getStudyInfo',  {id:component.get('v.recordId')}, function (returnValue) {
			component.set("v.studyInfo", returnValue);
			console.log('STUDYRET', returnValue);
			console.log('STUDY', component.get('v.studyInfo'));
		});
		let params = event.getParam('arguments');
		component.set('v.callback', params.callback);
		/*let params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        component.set('v.mode', params.mode);
        component.set('v.visits', []);
        component.set('v.plan', {});

        let vpId = params.vpId;
        if (vpId) {
            let plan = component.get('v.plan');
            plan.Id = vpId;
            component.set('v.plan', plan);
        }

        if (params.mode === 'create') {
            helper.createVPMode(component);
        } else if (vpId !== null) {
            if(params.mode === 'edit' || params.mode === 'view') {
                helper.callRemote(component, vpId);
            } else if(params.mode === 'clone') {
                helper.callRemote(component, vpId, true);
            }
        }*/

		component.find('createIncentiveTask').show();
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
		console.log('CANCEL');
		let modalName = event.getSource().get('v.name');
		component.find(modalName).hide();
	},
	doSave: function (component, event, helper) {
		component.find('spinner').show();
		console.log('Save');
		var plName = component.get('v.planName');
		console.log('123');
		var task = component.get('v.tasks');
		console.log('1234');
		var checkON = document.getElementById("checkboxOn").checked;
		var checkIQVIA = document.getElementById("checkboxIQVIA").checked;
		communityService.executeAction(component, 'createIncentivePlan',  {task:task[0], checkON:checkON, checkIQVIA:checkIQVIA, planName:plName}, function(ipId) {
			component.find('createIncentiveTask').hide();
			component.find('spinner').hide();
			component.set('v.planName', '');

			let callback = component.get('v.callback');
			if (callback) callback(ipId);

		});
	}
});