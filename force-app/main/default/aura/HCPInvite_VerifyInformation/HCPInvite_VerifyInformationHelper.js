({
    checkLeadinfo : function(cmp,evt,helper) {
        
        cmp.find('spinner').show();
        cmp.set("v.isBtnDisabled", true);
        cmp.set("v.isError", false);
 
        var action = cmp.get("c.validateAndConvertLead");  
        action.setParams({
            strFirstName: cmp.get("v.FirstName").trim(),
            strLastName: cmp.get("v.LastName").trim(),
            strPostalCode: cmp.get("v.postalCode").trim(),
            strLeadId: cmp.get("v.leadId"),
        });
        action.setCallback(this, function (response) {
            var getResponse = response.getState();
            var getReturnValue = response.getReturnValue();
            let leadReturnMessage = getReturnValue.LeadDataMessage;
            let batchId = getReturnValue.BatchId;
            if (getResponse === "SUCCESS") {
                console.log(">>>getReturnValue>>" + getReturnValue);
                if (!leadReturnMessage.startsWith("DataNotFound")) {
                    if(leadReturnMessage.startsWith("UserAlreadyThere")){
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
                        var  batchStartIntervalId =   window.setInterval(
                            $A.getCallback(function() { 
                                let actionBatch = cmp.get("c.getBatchStatus");
                                actionBatch.setParams({ strBatchId : batchId,
                                                       batchCount : cmp.get('v.BatchTryCounter')}); 
                                actionBatch.setCallback(this, function(response) { 
                                    var BatchReturnValue = response.getReturnValue();
                                    console.log('>>callback fro  batch>>'+JSON.stringify(BatchReturnValue));
                                    var currentBatchStatus = BatchReturnValue.batchcurrentStatus;
                                    cmp.set('v.BatchTryCounter',BatchReturnValue.batchCount);
                                    if(currentBatchStatus == 'Completed' || cmp.get('v.BatchTryCounter') == 3)
                                    {    
                                        window.clearInterval(batchStartIntervalId);
                                        var parseReturnValue = JSON.parse(leadReturnMessage);
                                        var inviteEvt = cmp.getEvent("HCPInviteEvt"); 
                                        inviteEvt.setParams({
                                            "UserName" :  parseReturnValue.Username,
                                            "UserId" :   parseReturnValue.Id,
                                            "componentCalled" : "verifyInfo"
                                        });
                                        cmp.find('spinner').hide();
                                        inviteEvt.fire();
                                    }
                                });
                                $A.enqueueAction(actionBatch); 
                            }), 10000
                        );  
                        
                        
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
        
    }
})