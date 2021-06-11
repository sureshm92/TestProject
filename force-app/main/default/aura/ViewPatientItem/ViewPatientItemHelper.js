/**
 * Created by Leonid Bartenev
 */
({
    // Method Name : prepareCardFields()
    // Description :  component, event
    // Parameters  : Added for the performance issue, get/set the values in name,surname;
    // Modified on : 07-09-2020
    prepareCardFields: function (component, event) {
        if (component.get('v.pe')) {
            component.set('v.userMode', communityService.getUserMode());
            var pe = component.get('v.pe'),
                isAdult = component.get('v.pe.Participant__r.Adult__c');
            var additionalName = [];
            var sendToSH = component.get('v.sendToSH');
            var sendtoSHDate = component.get('v.sendtoSHDate');
            if (pe.Participant_Name__c) additionalName.push(pe.Participant_Name__c);
            if (pe.Participant_Surname__c) additionalName.push(pe.Participant_Surname__c);
            if (additionalName.length > 0)
                component.set('v.peAdditionalName', additionalName.join(' '));

            // Added for the performance issue
            component.set('v.isHidden', false);
            this.showDelegateItems(component, event, isAdult);
        }
    },

    // Method Name : showDelegateItems()
    // Description :  component, event, isAdult
    // Parameters  : Added for the performance issue, get/set the values in Delegates;
    // Modified on : 07-09-2020
    showDelegateItems: function (component, event, isAdult) {
        if (!isAdult) {
            component.set('v.showSpinner', true);
            communityService.executeAction(
                component,
                'getDelegateAndContactId',
                {
                    peId: component.get('v.pe.Id'),
                    userMode: communityService.getUserMode(),
                    delegateId: communityService.getDelegateId()
                },
                function (returnValue) {
                    component.set('v.userContactId', returnValue.userContactId);
                    component.set('v.showSpinner', false);
                    if (!$A.util.isUndefinedOrNull(returnValue.participantDelegate)) {
                        component.set('v.participantDelegate', returnValue.participantDelegate);
                    }
                },
                null,
                function () {
                    component.find('spinner').hide();
                }
            );
        }
    },

    // Method Name : toggleBubbleMap()
    // Description : component, event
    // Parameters  : Added for the performance issue, show and hide the bubbles map;
    // Modified on : 07-09-2020
    toggleBubbleMap: function (component, event) {
        component.set('v.showSpinner', true);
        window.setTimeout(
            $A.getCallback(function () {
                component.set('v.showSpinner', false);
                component.set('v.isHidden', true);
            }),
            1000
        );
    },

    preparePathItems: function (component, event) {
        // var pe = component.get('v.pe');
        // component.set('v.showSpinner',true);
        //var isAdult = component.get('v.pe.Participant__r.Adult__c');
        // var currentPEState = statusesMap[pe.Participant_Status__c];
        //component.set('v.userMode', communityService.getUserMode());
        // var additionalName = [];
        // if (pe.Participant_Name__c) additionalName.push(pe.Participant_Name__c);
        // if (pe.Participant_Surname__c) additionalName.push(pe.Participant_Surname__c);
        // if (additionalName.length > 0) component.set('v.peAdditionalName', additionalName.join(' '));
        // var pathList = [];
        // var iconMap = {
        //     success: 'icon-check',
        //     failure: 'icon-close',
        //     neutral: 'icon-minus',
        //     in_progress: 'icon-minus'
        // };
        // for (var i = 0; i < statuses.length; i++) {
        //     var num = i + 1;
        //     var pathItem = {
        //         name: statuses[i],
        //         state: 'neutral',
        //         left: 'neutral'
        //     };
        //     if (currentPEState) {
        //         if (num < currentPEState.order) {
        //             pathItem.left = 'success';
        //             pathItem.state = 'success';
        //         } else if (num === currentPEState.order) {
        //             pathItem.left = currentPEState.state;
        //             pathItem.state = currentPEState.state;
        //             pathItem.isCurrent = true;
        //         }
        //     }
        //     pathItem.iconName = iconMap[pathItem.state];
        //     pathList.push(pathItem);
        //     if (i > 0) {
        //         pathList[i - 1].right = pathItem.left;
        //         pathList[i - 1].nextState = pathItem.state;
        //     }
        // }
        // component.set('v.pathItems', pathList);
        //Make the server call here
        //We will pass the delegate information to the component child
        //So that relevant information can be displayed in the UI
        /*if(!isAdult){
            communityService.executeAction(component, 'getDelegateAndContactId', {
                peId: component.get('v.pe.Id'),
                userMode: communityService.getUserMode(),
                delegateId: communityService.getDelegateId(),
            },function (returnValue) {
                component.set('v.userContactId', returnValue.userContactId);
                component.set('v.isHidden', true);
                component.set('v.showSpinner',false);
                if(!$A.util.isUndefinedOrNull(returnValue.participantDelegate)){
                    component.set('v.participantDelegate', returnValue.participantDelegate);              
                }
            }, null, function(){
                component.find('spinner').hide();
            });
        }*/
    }
});
