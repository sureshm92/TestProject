({	
	connectServerMethod:function(component, event, helper)
    {
        var action = component.get('c.prepareHCPEList');
		action.setParams
		({ 
			piId : component.get('v.currentPi'), 
			ctpId : component.get('v.currentStudy') 
		});
        action.setCallback(this,function(response){
			var state = response.getState();
			if(state === 'SUCCESS')
			{
				var data = JSON.parse(response.getReturnValue());
				component.set('v.itemsList',data);
                component.set('v.recordCount',data.length);                
			}
			else if(state == 'ERROR')
			{
                console.log(response.getError('Details')); 
            }
        });
        $A.enqueueAction(action);
	},
})