/**
 * Created by Leonid Bartenev
 */
({
    callServerMethod: function (component, event, helper) {
        component.set('v.loaded', true);
        var action = component.get('c.prepareAwaitingContactList');
        action.setParams({
            piId: component.get('v.currentPi'),
            ctpId: component.get('v.currentStudy'),
            communityName: communityService.getCurrentCommunityTemplateName()
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.peList', response.getReturnValue());
                component.set('v.loaded', false);
            } else {
                helper.showError(component, event, helper, action.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    showError: function (component, event, helper, errorMsg) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            message: errorMsg,
            duration: '400',
            type: 'error'
        });
        toastEvent.fire();
    },

    /*totalAwaitingContactedList : function(component) 
    {
        var action = component.get("c.totalPrepareAwaitingContacts");
        action.setParams
        ({
            piId:component.get('v.currentPi'),
            ctpId:component.get('v.currentStudy'),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                component.set("v.recordLength", resultData);                
            }
        });
        $A.enqueueAction(action);
    },*/

    showEditParticipantInformation: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        communityService.executeAction(
            component,
            'getParticipantData',
            {
                userMode: communityService.getUserMode(),
                delegateId: communityService.getDelegateId(),
                participantId: event.currentTarget.id,
                piId: component.get('v.currentPi'),
                ctpId: component.get('v.currentStudy')
            },
            function (returnValue) {
                returnValue = JSON.parse(returnValue);
                rootComponent.find('mainSpinner').hide();
                rootComponent
                    .find('updatePatientInfoAction')
                    .execute(
                        returnValue.currentPageList[0].pItem.pe,
                        returnValue.currentPageList[0].actions,
                        rootComponent,
                        returnValue.isInvited,
                        function (enrollment) {
                            rootComponent.refresh();
                            component.set('v.recordChanged', 'Record changed');
                            helper.callServerMethod(component, event);
                        }
                    );
                component.set('v.recordChanged', '');
            }
        );
    }
});