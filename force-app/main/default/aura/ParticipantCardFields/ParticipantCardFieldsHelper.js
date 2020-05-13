/**
 * Created by user on 26-Dec-19.
 */

({
    checkInvite: function (component, myId) {
        var action = component.get("c.checkInvited");
        action.setParams({"id" : myId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "ERROR"){
                
            }
            if (state === "SUCCESS") {
                component.set("v.invited", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
    
    /*doInit : function(component, event){
        communityService.executeAction(component, 'getReferralProfileDetail', {
            peId: component.get('v.pe.Id'),
            userMode: communityService.getUserMode(),
            delegateId: communityService.getDelegateId(),
        }, function (returnValue) {
            returnValue = JSON.parse(returnValue);
            //If the participant is minor and the participant has got delegate associated
            var isAdult = component.get('v.pe.Participant__r.Adult__c');
            console.log('Adult?' + isAdult );
            console.log('returnValue.participantDelegate'+ returnValue.participantDelegate);
            if(!isAdult && !$A.util.isUndefinedOrNull(returnValue.participantDelegate)){
                component.set('v.minorDelegate', returnValue.participantDelegate);   
            }   
            	
        }, null, null);
    }*/
    
});