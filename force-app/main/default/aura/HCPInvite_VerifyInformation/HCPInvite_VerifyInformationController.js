({
    doInit: function (cmp, event, helper) {
        cmp.find('spinner').show();
        var urlHREF = window.location.href;
        var leadId = urlHREF.split("id=")[1];
        console.log('>>leadId>>'+leadId);
        cmp.set("v.leadId", leadId);
        var action=cmp.get('c.checkDuplicateLead');
        action.setParams({ 
            strLeadId: leadId
        }); 
        action.setCallback(this,function(response){ 
            var getReturnValue = response.getReturnValue();  
			var networkCommUrl = getReturnValue.networkUrl;
			var isDuplicateLead =  getReturnValue.isDuplicateLead;  
            cmp.set('v.CommunityUrl',networkCommUrl);
            if(isDuplicateLead != 'false')
            {   
                cmp.set('v.isNotDuplicate',false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning",
                    "message": $A.get('$Label.c.RH_UserAlreadyRegister_Error') ,
                    "type" : 'warning',
                    "duration":' 4000',
                });
                cmp.find('spinner').hide();
                window.setTimeout(function(){
                    window.open(getReturnValue,'_self');
                },5000)
                toastEvent.fire();
            }
            else{ 
                cmp.find('spinner').hide();
                cmp.set('v.isNotDuplicate',true);
            }
        }); 
        $A.enqueueAction(action);
    },
    
    validateInput: function (cmp, evt, helper) {
        cmp.set('v.isError',false);
        
        var lastName = cmp.get("v.LastName");
        var postalCode = cmp.get("v.postalCode");
        var frstName = cmp.get("v.FirstName");
        var cmpTarget = cmp.find('cntueBtn');
        
        if (lastName && postalCode && frstName) {
            cmp.set("v.isBtnDisabled", false);
            $A.util.removeClass(cmpTarget,'disableBtnClass');
            $A.util.addClass(cmpTarget,'enableBtnClass');
        } else {
            $A.util.addClass(cmpTarget,'disableBtnClass');
            $A.util.removeClass(cmpTarget,'enableBtnClass');
            cmp.set("v.isBtnDisabled", true);
        }
    },
    
    checkLeadDetails : function (cmp, evt, helper) {
		helper.checkLeadinfo(cmp,evt,helper);
    },
});