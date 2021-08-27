({
	doInit : function(component, event, helper) {
		let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        if(patientVeiwRedirection){ 
            component.set('v.backLabelname','Back to My Patients');
        }else{
            component.set('v.backLabelname',component.get('v.backLabel'));
        }
	}
})