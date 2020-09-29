({
    // Method Name: loadParticipantOptions
    // Parameters : component, event, helper
    // Description: This method is recreated for "DB_ParticipantsContactedSchedule" components in the 
    //              Dashboard, it is used to increase the performance of the Dashboard. 
    // modified recently to tune dashboard performances.
 	loadParticipantOptions: function (component, event, helper){        
		helper.callServerMethod(component, event, helper);     
    },
    
    showEditParticipantInformation: function (component, event, helper){
        var participantEnrolmentId =  event.getParam("value"); //component.get('v.selectedId');
        if( participantEnrolmentId !== "" && participantEnrolmentId !== "No participant record"){
            communityService.executeAction(component, 'getPEEnrollmentsByPI', {eId: participantEnrolmentId}, 
            function (returnValue){
                var rootComponent = component.get('v.parent');
                var pe = JSON.parse(returnValue);        
                var actions = null;
                var isInvited = component.get('v.isInvited');
                rootComponent.find('updatePatientInfoAction').execute(pe, actions, rootComponent, isInvited, function (enrollment){
                    rootComponent.refresh();
                    component.set('v.recordChanged', 'record changed');// Do not remove this variable
                    helper.callServerMethod(component, event, helper);
                });
            });
            component.set('v.recordChanged', '');// Do not remove this variable
        }
    },
})