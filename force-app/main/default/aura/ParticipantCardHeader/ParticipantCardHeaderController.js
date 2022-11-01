/**
 * Created by user on 26-Dec-19.
 */

({
    doInit: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device == 'DESKTOP'){
        	var BriefSummary = component.get("v.pe.Clinical_Trial_Profile__r.Brief_Summary__c").substring(0,60);
        }else{
			var BriefSummary = component.get("v.pe.Clinical_Trial_Profile__r.Brief_Summary__c").substring(0,40);

        }
        console.log('BriefSummary------->'+BriefSummary);
        component.set("v.BriefSummary",BriefSummary.concat('...'));
    }

    /*openCard: function (component, event, helper) {
        var p = component.get("v.parent"),
            pse =component.get("v.parentSE");

        if(p)
            p.preparePathItems();
        else if(pse)
            pse.showCard(); 
        
        
        event.target.style.display = 'none';
    },*/
});
