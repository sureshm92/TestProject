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
            if(getReturnValue != 'false')
            {
                cmp.set('v.CommunityUrl',getReturnValue);
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
        cmp.find('spinner').show();
        cmp.set("v.isBtnDisabled", true);
        cmp.set("v.isError", false);
        
        var action = cmp.get("c.validateAndConvertLead");
        action.setParams({
            strFirstName: cmp.get("v.FirstName"),
            strLastName: cmp.get("v.LastName"),
            strPostalCode: cmp.get("v.postalCode"),
            strLeadId: cmp.get("v.leadId"),
        });
        action.setCallback(this, function (response) {
            var getResponse = response.getState();
            var getReturnValue = response.getReturnValue();
            if (getResponse === "SUCCESS") {
                console.log(">>>getReturnValue>>" + getReturnValue);
                if (!getReturnValue.startsWith("DataNotFound")) {
                    if(getReturnValue.startsWith("UserAlreadyThere")){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Warning",
                            "message": $A.get('$Label.c.RH_UserAlreadyRegister_Error') ,
                            "type" : 'warning',
                            "duration":' 4000',
                        });
                        
                        window.setTimeout(function(){
                            cmp.find('spinner').hide();
                            window.open(cmp.get('v.CommunityUrl'),'_self');
                            
                        },5000)
                        toastEvent.fire();
                    }
                    else{
                        var parseReturnValue = JSON.parse(getReturnValue);
                        var inviteEvt = cmp.getEvent("HCPInviteEvt"); 
                        inviteEvt.setParams({
                            "UserName" :  parseReturnValue.Username,
                             "UserId" :   parseReturnValue.Id,
                            "componentCalled" : "verifyInfo"
                        });
                        cmp.find('spinner').hide();
                        inviteEvt.fire();
                    } 
                } 
                else {
                    cmp.set("v.isError", true);
                    cmp.set("v.isBtnDisabled", false);
                    cmp.find('spinner').hide();
                }
            }
        });
        $A.enqueueAction(action);
    },
});