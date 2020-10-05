/**
 * Created by Leonid Bartenev
 */
({
    // Method Name : callServerMethod
    // Parameters  : component, event, helper
    // Description : Calling the server apex method for 
    // 				initiating records while loading the components and load the data.
    callServerMethod : function(component, event){
         var rootComponent = component.get('v.parent');
        communityService.executeAction(component, 'prepareAwaitingContactList', {
            userMode:communityService.getUserMode(),
            delegateId:communityService.getDelegateId(),
            piId:component.get('v.currentPi'),
            ctpId:component.get('v.currentStudy')
        }, function (returnValue) {
            returnValue = JSON.parse(returnValue);
            component.set('v.peList', returnValue);
            component.set('v.recordLength', returnValue.length);
        });        
    },
    // Method Name : callServerMethod
    // Parameters  : component, event, helper
    // Description : This method is used to open the actionparticipantinformation component,
    // 				 It will open the model and user can save participant record.
    showEditParticipantInformation : function(component, event, helper){
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        communityService.executeAction(component, 'getParticipantData', {
            userMode:communityService.getUserMode(),
            delegateId:communityService.getDelegateId(),
            participantId:event.currentTarget.id
        }, function (returnValue) {
            returnValue = JSON.parse(returnValue);
            component.set('v.peStatusesPathList', returnValue.peStatusesPathList);
            component.set('v.pe', returnValue.currentPageList[0].pItem.pe);
            component.set('v.peStatusStateMap', returnValue.peStatusStateMap);
           // helper.preparePathItems(component);
            rootComponent.find('mainSpinner').hide();
            rootComponent.find('updatePatientInfoAction').execute(returnValue.currentPageList[0].pItem.pe,  returnValue.currentPageList[0].actions, rootComponent, returnValue.isInvited, function (enrollment) {
                rootComponent.refresh();
               	component.set('v.recordChanged','Record changed'); 
                helper.callServerMethod(component, event);
            });
            component.set('v.recordChanged',''); 
        });    
	},
    
    preparePathItems: function (component) {
        var statuses = component.get('v.peStatusesPathList');
        var pe = component.get('v.pe');
        var statusesMap = component.get('v.peStatusStateMap');
        var currentPEState = statusesMap[pe.Participant_Status__c];
        component.set('v.showPath', currentPEState !== undefined );
        component.set('v.userMode', communityService.getUserMode());
        var additionalName = [];
        if (pe.Participant_Name__c) additionalName.push(pe.Participant_Name__c);
        if (pe.Participant_Surname__c) additionalName.push(pe.Participant_Surname__c);
        if (additionalName.length > 0) component.set('v.peAdditionalName', additionalName.join(' '));
        var pathList = [];
        var iconMap = {
            success: 'icon-check',
            failure: 'icon-close',
            neutral: 'icon-minus',
            in_progress: 'icon-minus'
        };
        for (var i = 0; i < statuses.length; i++) {
            var num = i + 1;
            //default values for path item:
            var pathItem = {
                name: statuses[i],
                state: 'neutral',
                left: 'neutral'
            };
            if (currentPEState) {
                if (num < currentPEState.order) {
                    pathItem.left = 'success';
                    pathItem.state = 'success';
                } else if (num === currentPEState.order) {
                    pathItem.left = currentPEState.state;
                    pathItem.state = currentPEState.state;
                    pathItem.isCurrent = true;
                }
            }
            pathItem.iconName = iconMap[pathItem.state];
            pathList.push(pathItem);
            if (i > 0) {
                pathList[i - 1].right = pathItem.left;
                pathList[i - 1].nextState = pathItem.state;
            }
        }
        component.set('v.pathItems', pathList);
    }
})