({	
	connectServerMethod:function(component, event, helper)
    {
		component.set('v.loaded', true);
        var action = component.get('c.prepareHCPEList');
		action.setParams
		({ 
			piId : component.get('v.currentPi'), 
			ctpId : component.get('v.currentStudy') 
		});
		action.setCallback(this,function(response)
		{
			var state = response.getState();
			if(state === 'SUCCESS')
			{
				var data = JSON.parse(response.getReturnValue());
				component.set('v.itemsList',data);
				component.set('v.recordCount',data.length);    
				component.set('v.loaded', false);            
			}
			else if(state == 'ERROR')
			{
                helper.showError(component, event, helper, action.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	},

	showError : function(component, event, helper, errorMsg) 
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: errorMsg,
            duration:'400',
            type: 'error'
        });
        toastEvent.fire();
    },
    

})