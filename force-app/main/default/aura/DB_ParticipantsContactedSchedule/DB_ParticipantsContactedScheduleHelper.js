({
	// Method Name: callServerMethod
    // Parameters : component, methodName, usermode, communityname, delegateID, selectedPI, selectedCTP, piaction,helper
    // Description: This method is recreated for "DB_ParticipantsContactedSchedule" components in the 
    //              Dashboard, it is used to increase the performance of the Dashboard. 
    // Added below method recently to tune dashboard performances.
	callServerMethod:function(component, event, helper)
    {
        var spinner = component.find('mainSpinner');
        spinner.show();
		communityService.executeAction(component, 'getContactedParticipantsData', {
			principalInvestigatorId: component.get('v.currentPi'),
            studyId: component.get('v.currentStudy')
        }, function (returnValue) {
            var responseData = returnValue;
			component.set('v.ContactedParticipantData', responseData);
			helper.createContactedParticipantDataList(component, event, responseData);
            var spinner = component.find('mainSpinner');
            spinner.hide();
        });
	},
	
	// Method Name: createContactedParticipantDataList
    // Parameters : component, event, ContactedParticipantData
    // Description: This method is recreated for "DB_ParticipantsContactedSchedule" components in the 
    //              Dashboard, it is used to increase the performance of the Dashboard. 
    // Modified below method recently to tune dashboard performances.
	createContactedParticipantDataList : function(component, event, ContactedParticipantData){
		//var piData = component.get('v.piData');
		//var piData = component.get('v.ContactedParticipantData');
		//console.log(piData);
		var result = ContactedParticipantData;//piData.ContactedParticipantDataList;
        var patientsOptions1 = [];
        var patientsOptions2 = [];
        var patientsOptions3 = [];
        var patientsOptions4 = [];
        var patientsOptions5 = [];
        var patientsOptions5 = [];
        
        for(var daysKey in result) {
            for(var patientkey in result[daysKey]){
                if(daysKey == "1-3 Days"){
                    patientsOptions1.push({ value: patientkey, label: result[daysKey][patientkey]});
                }
                else if(daysKey == "4-7 Days"){
                    patientsOptions2.push({ value: patientkey, label: result[daysKey][patientkey]});
                }    
               	else if(daysKey == "8-10 Days"){
                    patientsOptions3.push({ value: patientkey, label: result[daysKey][patientkey]});
                }  
                else if(daysKey == "11-21 Days"){
                    patientsOptions4.push({ value: patientkey, label: result[daysKey][patientkey]});
                }    
                else if(daysKey == ">21 Days"){
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

    /*
    showParticipantsContactedDashboard :function(component,helper,piData){
        if(piData.ContactedParticipantDataList == null){
            component.set('v.isParticipantDisplay', false);
        }
        else{
            component.set('v.isParticipantDisplay', true);
        }
	},*/

})