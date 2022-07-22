/**
 * Created by Kryvolap
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        var res;
        if (!communityService.isDummy()) {
            let peId = communityService.getUrlParameter('id');
            communityService.executeAction(
                component,
                'getPrintInformation',
                {
                    peId: peId,
                    userMode: communityService.getUserMode(),
                    delegateId: communityService.getDelegateId()
                },
                function (returnValue) {
                    returnValue = JSON.parse(returnValue);
                    if(returnValue.currentPageList) {
                        if(returnValue.currentPageList[0].actions)
                            component.set("v.actions", returnValue.currentPageList[0].actions);
                        
                        component.set('v.sendToSH',returnValue.currentPageList[0].sendToSH);
                        component.set('v.sendToSHDate',returnValue.currentPageList[0].sendToSHDate);
                        component.set('v.sendToSHReason',returnValue.currentPageList[0].sendToSHReason);
                    }
                    component.set('v.isFinalUpdate', true);
                    component.set('v.initialized', true);
                    component.set('v.pe', returnValue.pe);
                    component.set('v.participant', returnValue.pe.Participant__r);
                    component.set('v.pathItems', returnValue.pathItems);
                    component.set('v.containsFile', returnValue.containsFile);//REF-2826
                    component.set('v.peshData',returnValue);
                    if(returnValue.pe.Participant_Status__c == "Participant No Show" ||
                       returnValue.isContact)
                    {
                        if(returnValue.isPNS){
                            if(component.get('v.pe.Participant_Status__c') == "Participant No Show"){
                                var pathItems = component.get('v.pathItems');
                                for (let ind = 0; ind < pathItems.length; ind++) {
                                    if(ind == 0){
                                        pathItems[ind].state = "success";
                                        pathItems[ind].right = "neutral";
                                        pathItems[ind].left = "success";
                                        pathItems[ind].isCurrent = true;
                                    }
                                    if(ind == 1){
                                        pathItems[ind].title = $A.get("$Label.c.Participant_No_Show");
                                        pathItems[ind].stepHistory[0].title =returnValue.historyTitle; 
                                        pathItems[ind].stepHistory[0].source =null;
                                        pathItems[ind].stepHistory[0].isAdditionalNote =null;
                                        pathItems[ind].stepHistory[0].detailDate =returnValue.detailDate;
                                        pathItems[ind].stepHistory[0].detail =returnValue.detail;
                                        pathItems[ind].stepHistory[0].createdBy =returnValue.createdBy;
                                        
                                        pathItems[ind].state = "in_progress";
                                        pathItems[ind].right = "neutral";
                                        pathItems[ind].reason = null;
                                        pathItems[ind].occuredDate =returnValue.occuredDate;
                                        pathItems[ind].left = "neutral";
                                        pathItems[ind].isCurrent = false;
                                        pathItems[ind].dateOccured =returnValue.dateOccured; 
                                    }
                                    if(ind == 2){
                                        pathItems[ind].title = $A.get("$Label.c.PWS_Initial_Visit_Name");
                                        pathItems[ind].stepHistory = null;
                                        pathItems[ind].state = "neutral";
                                        pathItems[ind].right = "neutral";
                                        pathItems[ind].reason = null;
                                        pathItems[ind].occuredDate = null;
                                        pathItems[ind].left = "neutral";
                                        pathItems[ind].isCurrent = false;
                                        pathItems[ind].dateOccured = null; 
                                    }
                                    if(ind == 3){
                                        pathItems[ind].title = $A.get("$Label.c.PWS_Screening_Name");
                                        pathItems[ind].stepHistory = null;
                                        pathItems[ind].state = "neutral";
                                        pathItems[ind].right = "neutral";
                                        pathItems[ind].reason = null;
                                        pathItems[ind].occuredDate = null;
                                        pathItems[ind].left = "neutral";
                                        pathItems[ind].isCurrent = false;
                                        pathItems[ind].dateOccured = null; 
                                    } 
                                    if(ind == 4){
                                        pathItems[ind].title = component.get('v.pe.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c');
                                        pathItems[ind].stepHistory = null;
                                        pathItems[ind].state = "neutral";
                                        pathItems[ind].right = "neutral";
                                        pathItems[ind].reason = null;
                                        pathItems[ind].occuredDate = null;
                                        pathItems[ind].left = "neutral";
                                        pathItems[ind].isCurrent = false;
                                        pathItems[ind].dateOccured = null; 
                                    }
                                }
                                component.set('v.pathItems', pathItems);
                            }
                        }
                        if(returnValue.isContact){
                            
                            var pathItems = component.get('v.pathItems');
                            for (let ind = 0; ind < pathItems.length; ind++) {
                                if(ind == 1){
                                    
                                    pathItems[ind].occuredDate =returnValue.occuredDate;
                                    pathItems[ind].dateOccured =returnValue.dateOccured;
                                    pathItems[ind].reason =returnValue.reason; 
                                    pathItems[ind].stepHistory[0].title =returnValue.historyTitle; 
                                }
                            }
                            
                            component.set('v.pathItems', pathItems);
                            
                            
                        }
                    }
                    
                    //window.addEventListener("afterprint", function(event) { window.close(); });
                    communityService.executeAction(
                        component,
                        'getDelegates',
                        {
                            participantId: component.get('v.participant').Id
                        },
                        function (returnValue) {
                            component.set('v.delegate', returnValue);
                        }
                    );
                    setTimeout(
                        $A.getCallback(function () {
                            window.print();
                            window.close();
                        }),
                        1000
                    );
                }
            );
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});