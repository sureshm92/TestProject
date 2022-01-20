({
    doInit : function(cmp, event, helper) {
        cmp.find('mainSpinner').show();
        var action = cmp.get('c.getPortalTermsDetail');
        action.setCallback(this,function(response){ 
            var getReturnValue = response.getReturnValue(); 
            cmp.set('v.tcData',getReturnValue.objTerms);  
            cmp.set('v.CommunityUrl',getReturnValue.strCommunityDetails);  
            window.scrollTo(0, 0);
            cmp.find('mainSpinner').hide(); 
        });
        
        $A.enqueueAction(action);
        
    },
    doAccepttermsCondition : function(cmp,evt){
        cmp.find('mainSpinner').show(); 
        var action=cmp.get('c.acceptTerms');
        action.setParams({
            userId : cmp.get('v.userId'), 
            objtermId : cmp.get('v.tcData').Id
        });
        action.setCallback(this,function(response){ 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": $A.get('$Label.c.RH_RegistratinSuccess'),
                "type" : 'success',
                "duration":' 4000',
            }); 
            window.setTimeout(function(){
                cmp.find('mainSpinner').hide(); 
                window.open(cmp.get('v.CommunityUrl'),'_self');
            },4000)
            
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    },
    navigateToProfileCmp : function(cmp,evt){
        cmp.find('mainSpinner').show();
        var inviteEvt = cmp.getEvent("HCPInviteEvt"); 
        inviteEvt.setParams({
            "UserName" :  cmp.get('v.UserName'),
            "UserId" : cmp.get('v.userId'),
            "componentCalled" : "verifyInfo",
            "contactUserWrapper" : cmp.get('v.ContactUserWrapperData')
        });
        cmp.find('mainSpinner').hide();
        inviteEvt.fire();
        
    }
})