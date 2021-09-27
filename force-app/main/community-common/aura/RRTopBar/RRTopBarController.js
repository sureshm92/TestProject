({
	doInit : function(component, event, helper) {
		let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        if(patientVeiwRedirection){ 
            component.set('v.backLabelname', $A.get('$Label.c.RH_RP_Back_to_My_Patients'));
        }else{
            component.set('v.backLabelname',component.get('v.backLabel'));
        }
	}
})