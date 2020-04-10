/**
 * Created by Nikita Abrazhevitch on 13-Feb-20.
 */

({
    doInit: function(component, event, helper){
        let funnelContainer = component.find('funnelContainer').getElement();
        funnelContainer.innerHTML = '';
        var funnelData = component.get('v.funnelData');
        if($A.util.isEmpty(funnelData)) {
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
});