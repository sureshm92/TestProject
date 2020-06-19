({
	callRemote: function (component, ipId, needClone) {
		component.find('spinner').show();
		communityService.executeAction(component, 'getIncentiveProgramWrapper', {
			idPlan: ipId
		}, function (response) {
			var result = JSON.parse(JSON.stringify(response));
			if(needClone) {
				result[0].planName += ' Clone';
				result[0].planId = null;
			}
			component.set('v.tasks', result)
			component.set('v.planName', result[0].planName);
			component.find('spinner').hide();
		});
	}
})