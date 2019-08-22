/**
 * Created by user on 21-Aug-19.
 */

({
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
        var siteWrapper = component.get('v.siteWrapper');
        var currentSS = siteWrapper.studySite;
        communityService.executeAction(component, 'saveSSChanges', {studySiteInfo: JSON.stringify(currentSS)}, function (returnValue) {
            communityService.showToast('success', 'success', $A.get('$Label.c.SS_Success_Save_Message'));
            currentSS.isRecordUpdated = false;
            currentSS.isEmailValid = true;
            component.set('v.siteWrapper.studySite', currentSS);
        });
    },

    showManageLocationDetails: function(component, event, helper){
        var siteWrapper = component.get('v.siteWrapper');
    	var studyListView = component.get('v.studyListViewComponent');
        studyListView.find('actionManageLocationDetails').execute(siteWrapper, function(studySite){
            component.set('v.siteWrapper.studySite', studySite); 
            alert(studySite.Site__r.Driving_Directions__c);
        });
    },

    doAction: function (component, event) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        var parent = component.get('v.parent');
        var actionId = event.currentTarget.id;
        if (!actionId) actionId = event.getSource().getLocalId();
        switch (actionId) {
            case 'medicalRecordReview':
                communityService.navigateToPage('referring?id=' + trialId);
                //communityService.navigateToPage('referring?id=' + trialId);
                break;
            case 'referToThisStudy':
            case 'refer':
                communityService.navigateToPage('referring?id=' + trialId);
                break;
            case 'share':
                //pass trial to 'Share' dialog:
                parent.find('shareModal').show(trial.Id, currentStudy.hcpe.HCP_Contact__c);
                break;
            case 'viewTermsAndConditions':
                communityService.navigateToPage("trial-terms-and-conditions?id=" + trialId + "&ret=" + communityService.createRetString());
                break;
            case 'findStudySites':
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'myPatients':
                communityService.navigateToPage('my-patients?id=' + trialId);
                break;
            case 'noThanks':
                var studySiteId = component.get('v.siteWrapper').studySite.Id;
                parent.showOpenNoTanksModal(trialId,studySiteId);
                break;
            case 'manageReferrals':
                communityService.navigateToPage("my-referrals?id=" + trialId);
                break;
            case 'manageReferralsBySS':
                var studySiteId = component.get('v.siteWrapper').studySite.Id;
                communityService.navigateToPage("my-referrals?id=" +trialId+"&siteId="+studySiteId);
                break;
            case 'manageReferringClinics':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referred-clinics");
                break;
            case 'manageReferringClinicsBySS':
                var studySiteId = component.get('v.siteWrapper').studySite.Id;
                communityService.navigateToPage("my-referring-clinics?id=" + trialId + "&ssId="+studySiteId);
                break;
            case 'openToReceiveReferrals':
                //pass trial to 'Iam open to receive...' dialog:
                var studySiteId = component.get('v.siteWrapper').studySite.Id;
                parent.find('receiveReferralsModal').show(trial,studySiteId);
                break;
            case 'linkToStudySites':
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'addPatient':
                var studySiteId = component.get('v.siteWrapper').studySite.Id;
                communityService.navigateToPage('add-patient?id=' + trialId + "&ssId=" + studySiteId);
                break;
        }
    },
});