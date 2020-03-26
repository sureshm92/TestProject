/**
 * Created by Alexey Moseev.
 */
({
    showEditParticipantInformation: function (component, event, helper) {
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
            console.log(returnValue.currentPageList[0].pItem.pe);
            component.set('v.peStatusStateMap', returnValue.peStatusStateMap);
           // helper.preparePathItems(component);
            rootComponent.find('mainSpinner').hide();
            rootComponent.find('updatePatientInfoAction').execute(returnValue.currentPageList[0].pItem.pe,  returnValue.currentPageList[0].actions, rootComponent, returnValue.isInvited, function (enrollment) {
                rootComponent.refresh();
            });
        });
    },

    sortRecords: function(component){
        var peList = component.get('v.peList');
        if(component.get('v.defaultSorting')){
            peList.sort(function (a, b) {
                var daysAddedA = a.daysAdded;
                var daysAddedB = b.daysAdded;
                if (daysAddedA < daysAddedB) {
                    return -1;
                }
                if (daysAddedA > daysAddedB) {
                    return 1;
                }
                return 0;
            });
            component.set('v.peList', peList);
            component.set('v.defaultSorting',false);
        } else {
            peList.sort(function (a, b) {
                var daysAddedA = a.daysAdded;
                var daysAddedB = b.daysAdded;
                if (daysAddedA > daysAddedB) {
                    return -1;
                }
                if (daysAddedA < daysAddedB) {
                    return 1;
                }
                return 0;
            });
            component.set('v.peList',peList);
            component.set('v.defaultSorting',true);
        }
    },

})