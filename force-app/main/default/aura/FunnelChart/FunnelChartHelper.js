/**
 * Created by Nikita Abrazhevitch on 13-Feb-20.
 * Modified by Sabir on 20-oct-20. 
 */

({
	getPEFunnelRecord : function(component, event, helper)
	{
        component.set('v.loaded', true);
        var action = component.get('c.prepareDataForFunnelChart');
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
                component.set('v.funnelData',response.getReturnValue());
                helper.funnelChart(component, event, helper);
                component.set('v.loaded', false);
            }
            else
            {
                helper.showError(component, event, helper, action.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
  	
    funnelChart: function(component, event, helper)
	{
		var funnelData = component.get('v.funnelData');
		let funnelContainer = component.find('funnelContainer').getElement();
        funnelContainer.innerHTML = '';
        var lbl = [];
        var clr = [];
        var vle = [];
        for(let i = 0 ; i < funnelData.length; i++){
            lbl.push(funnelData[i].statusLabel);
            vle.push(funnelData[i].peInStatus);
            clr.push(funnelData[i].funnelColor);
        }
        var fnlData = {
            labels: lbl,
            colors: clr,
            values: vle
        };
        var graph = new FunnelGraph({
            container: '.funnel',
            gradientDirection: 'horizontal',
            data: fnlData,
            displayPercent: true,
            direction: 'horizontal',
            height: 200,
            subLabelValue: 'percent'
        });
        graph.draw();
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

});