/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        helper.preparePathItems(component);
    },

    doGoToProfile: function (component) {
        var pe = component.get('v.pe');
        if(communityService.getUserMode() === 'HCP'){
            communityService.navigateToPage('patient-profile?id=' + pe.Participant__c);
        }else if(communityService.getUserMode() === 'PI'){
            communityService.navigateToPage('referral-profile?id=' + pe.Id);
        }else{
            //
        }
    },

    doGoToStudyWorkspace: function (component) {
        var pe = component.get('v.pe');
        communityService.navigateToPage('study-workspace?id=' + pe.Study_Site__r.Clinical_Trial_Profile__c);
    },

    doLoadHistoryOnOpen: function (component) {
        var isOpened = !component.get('v.detailCollapsed');
        if(isOpened){
            component.find('statusDetail').loadHistory();
        }
    },

    doChangeStatus: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        var pe = component.get('v.pe');
        var status = event.currentTarget.dataset.statusName;
        var changePEStatusByPIAction = rootComponent.find('changePEStatusByPIAction');
        changePEStatusByPIAction.execute(pe, status, null, null, rootComponent);
    }

})