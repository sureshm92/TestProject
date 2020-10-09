({
    
    doInit : function(component, event, helper) {
        if(component.get('v.userMode') && component.get('v.userMode') =='Participant') component.set('v.isHidden', true);
	},
    
	showPSE : function(component, event, helper) {        
		component.set('v.isHidden', true);
	}
})