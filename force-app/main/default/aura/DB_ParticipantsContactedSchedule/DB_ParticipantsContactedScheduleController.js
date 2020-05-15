({
 	loadParticipantOptions: function (component, event, helper) 
    {
        var piData = component.get('v.piData');
        var result = piData.ContactedParticipantDataList;
        var patientsOptions1 = [];
        var patientsOptions2 = [];
        var patientsOptions3 = [];
        var patientsOptions4 = [];
        var patientsOptions5 = [];
        var patientsOptions5 = [];
        
        for(var daysKey in result)
        {
            for(var patientkey in result[daysKey])
            {
                if(daysKey == "1-3 Days")
                {
                    patientsOptions1.push({ value: patientkey, label: result[daysKey][patientkey]});
                }
                else if(daysKey == "4-7 Days")
                {
                    patientsOptions2.push({ value: patientkey, label: result[daysKey][patientkey]});
                }    
               	else if(daysKey == "8-10 Days")
                {
                    patientsOptions3.push({ value: patientkey, label: result[daysKey][patientkey]});
                }  
                else if(daysKey == "11-21 Days")
                {
                    patientsOptions4.push({ value: patientkey, label: result[daysKey][patientkey]});
                }    
                else if(daysKey == ">21 Days")
                {
                    patientsOptions5.push({ value: patientkey, label: result[daysKey][patientkey]});
                }    
            }
        }
        component.set("v.days_1_To_3_participantOptions", patientsOptions1);
        component.set("v.days_4_To_7_participantOptions", patientsOptions2);
        component.set("v.days_8_To_10_participantOptions", patientsOptions3);
        component.set("v.days_11_To_21_participantOptions", patientsOptions4);
        component.set("v.greater_21_days_participantOptions", patientsOptions5);
        var totalParticipants = patientsOptions1.length+patientsOptions2.length+patientsOptions3.length+patientsOptions4.length+patientsOptions5.length;
        component.set("v.totalParticipants", totalParticipants);
    },
    
    showEditParticipantInformation: function (component, event, helper) 
    {
        var participantEnrolmentId = event.getParam("value");
        if(participantEnrolmentId !== "No participant record")
        {
            communityService.executeAction(component, 'getPEEnrollmentsByPI', {eId: participantEnrolmentId}, 
            function (returnValue) 
            {  
                var rootComponent = component.get('v.parent');
                var pe = JSON.parse(returnValue);        
                var actions = null;
                var isInvited = component.get('v.isInvited');
                rootComponent.find('updatePatientInfoAction').execute(pe, actions, rootComponent, isInvited, function (enrollment) 
                {
                    rootComponent.refresh();
                });
            });
        }
    },
    
})