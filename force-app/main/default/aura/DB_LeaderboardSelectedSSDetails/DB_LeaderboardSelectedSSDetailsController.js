({
	doinit : function(component, event,helper)
	{
        helper.getSitesCount(component);
        var currentStudy = component.get('v.currentStudy');
		var currentPI = component.get('v.currentPi');
        var action = component.get('c.getStudySiteDetails');
        action.setParams({ pIid : currentPI, studyid : currentStudy });
        action.setCallback(this,function(response){
			var state = response.getState();
			if(state === 'SUCCESS')
			{
                var data = JSON.parse(response.getReturnValue());
                var piStudySites = [];
                for(var i in data){
                    if(data[i].pi_Id == currentPI){
                        piStudySites.push(data[i]);
                    }	
                }
                component.set('v.siteRankWrapper', piStudySites); 
			}
			else if(state == 'ERROR')
			{
                console.log(response.getError('Details')); 
            }

        });
        $A.enqueueAction(action);
	},

})