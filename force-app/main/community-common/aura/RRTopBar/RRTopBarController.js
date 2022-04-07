({
	doInit : function(component, event, helper) {
		let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        let participantVeiwRedirection = communityService.getUrlParameter('participantVeiwRedirection');
        if(patientVeiwRedirection){ 
            component.set('v.backLabelname', $A.get('$Label.c.RH_RP_Back_to_My_Patients'));
        }else if(participantVeiwRedirection){
            component.set('v.backLabelname', $A.get('$Label.c.PG_MRR_BTN_Back_to_My_Participant'));
        }else{
            component.set('v.backLabelname',component.get('v.backLabel'));
        }
	}
})