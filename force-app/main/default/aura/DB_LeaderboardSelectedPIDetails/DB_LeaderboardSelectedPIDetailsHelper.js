({
	getSitesCount : function(component) {
		var action = component.get('c.getCurrentStudySitesCount');
        action.setParams({ctpId : component.get('v.currentStudy') });
        action.setCallback(this,function(response){
			var state = response.getState();
			if(state === 'SUCCESS')
			{
                var data = JSON.parse(response.getReturnValue());
                component.set('v.totalSSCount', data); 
			}
			else if(state == 'ERROR')
			{
                console.log(response.getError('Details')); 
            }

        });
        $A.enqueueAction(action);
	}
})