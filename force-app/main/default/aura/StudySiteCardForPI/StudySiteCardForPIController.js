/**
 * Created by Nikita Abrazhevitch on 21-Aug-19.
 */

({
    doInit: function (component, event, helper) {
        var actions = component.get("v.siteWrapper").actions;
        actions.forEach(function(action, index) {
            if (action != null && 'addPatient' == action.id) {
                console.log(action);
                component.set("v.addParticipantInfo", action);
            }
        });
    },

    trimChanges: function (component, event, helper) {
        var val = event.getSource().get('v.value');
        event.getSource().set('v.value', val.trim());
        if (!event.getSource().checkValidity()) {
            event.getSource().showHelpMessageIfInvalid();
        }
    },

    changeUpdatedStatus: function (component, event) {
        var el = component.get('v.siteWrapper');
        el.studySite.isRecordUpdated = true;
        component.set('v.siteWrapper', el);
    },

    checkValidEmail: function (component, event, helper) {
        var email = event.getSource().get('v.value');
        var el = component.get('v.siteWrapper');
        if (email) {
            email = email.trim();
            var el = component.get('v.siteWrapper');
            var isValid = communityService.isValidEmail(email);
            el.studySite.isEmailValid = isValid;
        } else {
            el.studySite.isEmailValid = true;
        }
        component.set('v.siteWrapper', el);
    },

    saveChanges: function (component, event, helper) {
        var studyListViewComponent = component.get('v.studyListViewComponent');
        studyListViewComponent.find('mainSpinner').show();
        var siteWrapper = component.get('v.siteWrapper');
        var currentSS = siteWrapper.studySite;
        communityService.executeAction(component, 'saveSSChanges', {studySiteInfo: JSON.stringify(currentSS)}, function () {
            communityService.showToast('success', 'success', $A.get('$Label.c.SS_Success_Save_Message'));
            currentSS.isRecordUpdated = false;
            currentSS.isEmailValid = true;
            component.set('v.siteWrapper.studySite', currentSS);
            studyListViewComponent.find('mainSpinner').hide();
        });
    },

    showManageLocationDetails: function (component, event, helper) {
        var siteWrapper = component.get('v.siteWrapper');
        var studyListView = component.get('v.studyListViewComponent');
        studyListView.find('actionManageLocationDetails').execute(siteWrapper, function (studySite, accounts) {
            // component.set('v.siteWrapper.studySite', studySite);
            component.set('v.refresh',true);
            component.set('v.siteWrapper.studySite', studySite);
            component.set('v.refresh',false);
            if (accounts) {
                component.set('v.siteWrapper.accounts', accounts);
            }
        });
    },

    doAction: function (component, event) {
        var siteWrapper = component.get('v.siteWrapper');
        var studySiteId = siteWrapper.studySite.Id;
        var trialId = siteWrapper.studySite.Clinical_Trial_Profile__c;
        var trial = siteWrapper.studySite.Clinical_Trial_Profile__r;
        var studyListViewComponent = component.get('v.studyListViewComponent');
        var actionId = (event.currentTarget && event.currentTarget.id ? event.currentTarget.id : undefined);
        if (!actionId && event.getSource()) {
            if (event.getSource().get('v.itemValue')) {
                actionId = event.getSource().get('v.itemValue');
            } else {
                actionId = event.getSource().getLocalId();
            }
        }
        switch (actionId) {
            case 'noThanks':
                studyListViewComponent.showOpenNoTanksModal(trialId, studySiteId);
                break;
            case 'manageReferralsBySS':
                communityService.navigateToPage('my-referrals?id=' + trialId + '&siteId=' + studySiteId);
                break;
            case 'manageReferringClinicsBySS':
                communityService.navigateToPage('my-referring-clinics?id=' + trialId + '&ssId=' + studySiteId);
                break;
            case 'openToReceiveReferrals':
                //pass trial to 'Iam open to receive...' dialog:
                studyListViewComponent.find('receiveReferralsModal').show(trial, studySiteId);
                break;
            case 'addPatient':
                communityService.navigateToPage('add-patient?id=' + trialId + '&ssId=' + studySiteId);
                break;
            case 'uploadPatient':
                studyListViewComponent.find('actionUploadParticipants').execute(studySiteId, function(studySiteId) {});
                break;
        }
    },
});