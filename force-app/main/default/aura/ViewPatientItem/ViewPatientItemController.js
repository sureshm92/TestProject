/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (component.get('v.pe')) {
            helper.preparePathItems(component);
            component.find('spinner').hide();
        }
    },

    doGoToProfile: function (component) {
        var pe = component.get('v.pe');
        if (communityService.getUserMode() === 'HCP') {
            communityService.navigateToPage('patient-profile?id=' + pe.Participant__c);
        } else if (communityService.getUserMode() === 'PI') {
            communityService.navigateToPage('referral-profile?id=' + pe.Id);
        } else {
            //
        }
    },

    doGoToStudyWorkspace: function (component) {
        var pe = component.get('v.pe');
        communityService.navigateToPage('study-workspace?id=' + pe.Study_Site__r.Clinical_Trial_Profile__c);
    },

    doLoadHistoryOnOpen: function (component) {
        var isOpened = !component.get('v.detailCollapsed');
        if (isOpened) {
            component.find('statusDetail').loadHistory();
        }
    },

    doChangeStatus: function (component, event, helper) {
        console.log('do change status');
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        var pe = component.get('v.pe');
        var status = event.currentTarget.dataset.statusName;
        var changePEStatusByPIAction = rootComponent.find('changePEStatusByPIAction');
        changePEStatusByPIAction.execute(pe, status, null, null, function (pe) {
            component.set('v.pe', pe);
            rootComponent.find('mainSpinner').hide();
        }, function () {
            rootComponent.find('mainSpinner').hide();
        });
    },

    showEditParticipantInformation: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var pathItems = component.get('v.pathItems');
        var peStatusesPathList = component.get('v.peStatusesPathList');
        var peStatusStateMap = component.get('v.peStatusStateMap');
        var anchor = event.currentTarget.value;
        rootComponent.find('updatePatientInfoAction').execute(pe, pathItems, anchor, rootComponent, peStatusesPathList, peStatusStateMap, function (enrollment) {
            component.set('v.pe', enrollment);
            rootComponent.find('updatePatientInfoAction').set('v.pathItems', component.get('v.pathItems'));
        });
    },

})