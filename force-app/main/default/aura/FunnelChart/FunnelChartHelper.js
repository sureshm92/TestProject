({
	getPEFunnelRecord : function(component, event,helper)
	{
		var currentStudy = component.get('v.currentStudy');
		var currentPI = component.get('v.currentPi');
        var action = component.get('c.prepareDataForFunnelChart');
        action.setParams({ piId : currentPI, ctpId : currentStudy });
        action.setCallback(this,function(response){
			var state = response.getState();
			if(state === 'SUCCESS')
			{
                var data = JSON.parse(response.getReturnValue());
				component.set('v.funnelData',data);
				helper.funnelChart(component, event, helper);
			}
			else if(state == 'ERROR')
			{
                console.log(response.getError('Details')); 
            }

        });
        $A.enqueueAction(action);
	},
	
    funnelChart: function(component, event, helper)
	{
		var funnelData = component.get('v.funnelData');
		let funnelContainer = component.find('funnelContainer').getElement();
         funnelContainer.innerHTML = '';
		if($A.util.isEmpty(funnelData)) 
		{
            component.set('v.invitedParticipants', 0);
            return;
        }
        var lbl = [];
        var clr = [];
        var vle = [];
        var invitedParticipants = 0;
        for(let i = 0 ; i < funnelData.length; i++){
            lbl.push(funnelData[i].statusLabel);
            vle.push(funnelData[i].peInStatus);
            clr.push(funnelData[i].funnelColor);
            if(funnelData[i].statusLabel == 'Received') {
                invitedParticipants += funnelData[i].peInStatus;
            }
        }
        component.set('v.invitedParticipants', invitedParticipants);
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

    callServerMethod:function(component, mthdName, usermode, communityname, delegateID, selectedPI, selectedCTP, piaction,helper){
        communityService.executeAction(component, mthdName, {           
            piId: selectedPI,
            ctpId: selectedCTP
        }, function (returnValue) {
            var responseData = JSON.parse(returnValue);
            console.log(responseData);
            component.set('v.funnelData', responseData);
        });
    },
    
    showParticipantsContactedDashboard :function(component,helper,piData){
        if(piData.ContactedParticipantDataList == null){
            component.set('v.isParticipantDisplay', false);
        }
        else{
            component.set('v.isParticipantDisplay', true);
        }
    }

});