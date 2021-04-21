/**
 * Created by Kryvolap
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

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
