/**
 * Created by Alexey Moseev.
 */
({
    doInit:function(component, event, helper){
        var rootComponent = component.get('v.parent');
        communityService.executeAction(component, 'prepareWaitingList', {
            userMode:communityService.getUserMode(),
            delegateId:communityService.getDelegateId(),
            piId:component.get('v.currentPi'),
            ctpId:component.get('v.currentStudy')
        }, function (returnValue) {
            returnValue = JSON.parse(returnValue);
            component.set('v.peList', returnValue);
            if(returnValue){
                var count =	parseInt (returnValue[0].count) + 
                            parseInt (returnValue[1].count) +
                            parseInt (returnValue[2].count) +
                            parseInt (returnValue[3].count) +
                            parseInt (returnValue[4].count)
                component.set('v.recordLength', count); 
            }
            
            
        });
    },
    
   
})