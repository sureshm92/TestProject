({
    doInit: function (component, event, helper) {
        if (component.get('v.userMode') == 'PI') {
            setTimeout($A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
                component.set("v.detailsExpanded", true);
            }), 10);
        }
    },

    doAction: function (component, event) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        var parent = component.get('v.parent');
        var actionId = event.currentTarget.id;
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
                //communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'myPatients':
                //communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                communityService.navigateToPage('my-patients?id=' + trialId);
                break;
            case 'noThanks':
                parent.showOpenNoTanksModal(trialId);
                break;
            case 'manageReferrals':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referrals");
                break;
            case 'manageReferralsBySS':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].Id;
                communityService.navigateToPage("study-workspace?id=" + trialId + "&ssId=" + studySiteId + "&tab=tab-referrals");
                break;
            case 'manageReferringClinics':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referred-clinics");
                break;
            case 'manageReferringClinicsBySS':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].Id;
                communityService.navigateToPage("study-workspace?id=" + trialId + "&ssId=" + studySiteId + "&tab=tab-referred-clinics");
                break;
            case 'openToReceiveReferrals':
                //pass trial to 'Iam open to receive...' dialog:
                parent.find('receiveReferralsModal').show(trial);
                break;
            case 'linkToStudySites':
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'addPatient':
                communityService.navigateToPage('add-patient?id=' + trialId);
                break;
        }
    },

    toggleStudySiteListView: function (cmp, event, helper) {
        let detailsExpanded = cmp.get("v.detailsExpanded");
        if (detailsExpanded) {
            cmp.set("v.detailsExpanded", false);
        } else {
            cmp.set("v.detailsExpanded", true);
        }
    },

    doReferPatient: function (cmp, event, helper) {
        var currentStudy = cmp.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        var hcpeId = event.target.dataset.hcpeId;
        communityService.navigateToPage('referring?id=' + trialId + (hcpeId ? '&hcpeid=' + hcpeId : ''));
    },

    doMyPatients: function (cmp, event, helper) {
        var currentStudy = cmp.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        debugger;
        var siteId = event.target.dataset.siteId;

        communityService.navigateToPage('my-patients?id=' + trialId + (siteId ? '&siteId=' + siteId : ''));
    },

    navigateToSitesSearch: function (component, event, helper) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        communityService.navigateToPage("sites-search?id=" + trialId);
    },

    onShareClick: function (component, event, helper) {
        let url = component.get('v.currentStudy').trial.Share_URL__c + 'none';
        let text = 'A clinical study of interest';
        let id = event.currentTarget.dataset.id;
        switch (id) {
            case 'email':
                helper.onEmailClick(component);
                break;
            case 'facebook':
                helper.onFacebookClick(component, url, text);
                break;
            case 'twitter':
                helper.onTwitterClick(component, url, text);
                break;
            case 'linkedin':
                helper.onLinkedInClick(component, url);
                break;
        }
    },
    clampDrivingInstuctions: function (component, event, helper) {
        setTimeout($A.getCallback(function () {
            helper.doUpdateStudyTitle(component);
            // helper.doUpdateStudyDescription(component);
        }), 10);
    },

    saveChanges: function (component, event, helper) {
        var ctarget = event.currentTarget.value;
        var element = component.get('v.currentStudy.ssList');
        var currentSS = element[ctarget];
        var parent = component.get('v.parent');
        parent.saveSSDetails(currentSS);
        currentSS.isRecordUpdated = false;
        currentSS.isEmailValid = true;
        component.set('v.currentStudy.ssList', element);
    },

    changeUpdatedStatus: function (component, event, helper) {
        if (event === undefined) {
            var index = component.get('v.itemIndex');
            var el = component.get('v.currentStudy.ssList');
            el[index].isRecordUpdated = true;
            component.set('v.currentStudy.ssList', el);
        } else {
            var targetIndex = event.target.parentElement.dataset.index;
            var el = component.get('v.currentStudy.ssList');
            el[targetIndex].isRecordUpdated = true;
            component.set('v.currentStudy.ssList', el);
        }
    },

    checkValidEmail: function (component, event, helper) {
        var isValid = communityService.isValidEmail(event.getSource().get('v.value'));
        var elIndex = event.target.parentElement.dataset.index;
        var cmp = component.get('v.currentStudy.ssList');
        cmp[elIndex].isEmailValid = isValid;
        component.set('v.currentStudy.ssList', cmp);
    },

    changeItemIndex: function (component, event) {
        var itemIndex = event.currentTarget.dataset.index;
        component.set('v.itemIndex', itemIndex);
    },

    showManageLocationDetails: function (component, event, helper) {
        component.set('v.editAddress',false);
        var popupIndex = event.currentTarget.dataset.index;
        component.set('v.popupIndex', popupIndex);
        setTimeout($A.getCallback(function () {
            helper.doUpdateStudyTitle(component);
        }), 1);
        var popUps = component.find('manage-location');
        if(popUps.length) {
            popUps[popupIndex].show();
        } else {
            popUps.show();
        }
    },

    changeRadioMarker: function (component,event,helper) {
        var radioBtns = component.find('radioBtn');
        for (let i = 0; i < radioBtns.length; i++) {
            radioBtns[i].set('v.checked',false);
        }
        component.set('v.checkedAccount',event.getSource().get('v.value'));
        component.set('v.locationWasChanged',true);
    },

    changeStudySiteAddress: function (component,event,helper) {
        var ctarget = event.currentTarget.value;
        var element = component.get('v.currentStudy.ssList');
        var currentSS = element[ctarget];
        var checkedAccount = component.get('v.checkedAccount');
        currentSS.Site__c = checkedAccount.Id;
        var parent = component.get('v.parent');
        component.set('v.locationWasChanged',false);
        parent.saveSSDetails(currentSS);
    },


    editAccountAddress: function(component,event,helper){
        var editIndx = event.target.dataset.indx;
        var ssIndex = event.target.dataset.index;
        var cmp;
        if(editIndx) {
            cmp = component.get('v.contactAccounts')[editIndx];
        } else if(!editIndx && !ssIndex){
            cmp = new Object({'Id': null});
        }
        else{
            cmp = component.get('v.currentStudy.ssList')[ssIndex].Site__r;
        }
        component.set('v.editedAccount', cmp);
        component.set('v.editAddress',true);
    },

    closeModal: function(component, event, helper){
        var index = component.get('v.popupIndex');
        component.find('manage-location')[index].hide();
    },
    backToTheChoice: function(component,event,helper){
        component.set('v.editAddress',false);
        component.set('v.editedAccount',null);
        setTimeout($A.getCallback(function () {
            helper.doUpdateStudyTitle(component);
        }), 1);
    },
    saveNewAccount:function(component,event,helper){
        var ssIndex = event.currentTarget.value;
        var newAccount = component.get('v.editedAccount');
        var element = component.get('v.currentStudy.ssList');
        var currentSS = element[ssIndex];
        currentSS.Site__r = newAccount;
        var isDefault = component.get('v.makeDefault');
        currentSS.makeDefault = isDefault;
        var parent = component.get('v.parent');
        component.set('v.addressWasChanged',false);
        parent.saveSSnewAddress(currentSS);
    },
    showChecked: function (component,event,helper) {
        component.set('v.makeDefault',event.getSource().get('v.checked'));
    },
    recordWasUpdated:function (component,event,helper) {
        component.set('v.addressWasChanged',true);
    }
})