({
    doInit: function (component, event, helper) {
        var ssList = component.get('v.currentStudy.ssList');
        for (let i = 0; i < ssList.length; i++) {
            ssList[i].accounts.sort(function (a, b) {
                var nameA = a.Name.toUpperCase();
                var nameB = b.Name.toUpperCase();
                if (nameA < nameB) {
                    return -1;
                }
                if (nameA > nameB) {
                    return 1;
                }
                return 0;
            })
        }
        if (component.get('v.userMode') == 'PI') {
            component.set("v.detailsExpanded", true);
        }
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
                //communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'myPatients':
                //communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                communityService.navigateToPage('my-patients?id=' + trialId);
                break;
            case 'noThanks':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                parent.showOpenNoTanksModal(trialId,studySiteId);
                break;
            case 'manageReferrals':
                communityService.navigateToPage("my-referrals?id=" + trialId);
                break;
            case 'manageReferralsBySS':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
               // communityService.navigateToPage("study-workspace?id=" + trialId + "&ssId=" + studySiteId + "&tab=tab-referrals");
                communityService.navigateToPage("my-referrals?id=" +trialId+"&siteId="+studySiteId);
                break;
            case 'manageReferringClinics':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referred-clinics");
                break;
            case 'manageReferringClinicsBySS':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                communityService.navigateToPage("my-referring-clinics?id=" + trialId + "&ssId="+studySiteId);
                break;
            case 'openToReceiveReferrals':
                //pass trial to 'Iam open to receive...' dialog:
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                console.log('studySiteId',studySiteId);
                parent.find('receiveReferralsModal').show(trial,studySiteId);
                break;
            case 'linkToStudySites':
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'addPatient':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                communityService.navigateToPage('add-patient?id=' + trialId + "&ssId=" + studySiteId);
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
    saveChanges: function (component, event, helper) {
        var ctarget = event.currentTarget.value;
        var element = component.get('v.currentStudy.ssList');
        var currentSS = element[ctarget].studySite;
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
            el[index].studySite.isRecordUpdated = true;
            component.set('v.currentStudy.ssList', el);
        } else {
            var targetIndex = event.target.parentElement.dataset.index;
            var el = component.get('v.currentStudy.ssList');
            el[targetIndex].studySite.isRecordUpdated = true;
            component.set('v.currentStudy.ssList', el);
        }
    },

    checkValidEmail: function (component, event, helper) {
        var email = event.getSource().get('v.value');
        if(email) {
            email = email.trim();
            var isValid = communityService.isValidEmail(email);
            var elIndex = event.target.parentElement.dataset.index;
            var cmp = component.get('v.currentStudy.ssList');
            cmp[elIndex].studySite.isEmailValid = isValid;
        } else {
            var elIndex = event.target.parentElement.dataset.index;
            var cmp = component.get('v.currentStudy.ssList');
            cmp[elIndex].studySite.isEmailValid = true;
        }
        component.set('v.currentStudy.ssList', cmp);
    },

    changeItemIndex: function (component, event) {
        var itemIndex = event.currentTarget.dataset.index;
        component.set('v.itemIndex', itemIndex);
    },

    showManageLocationDetails: function (component, event, helper) {
        var parent = component.get('v.parent');
        var popupIndex = event.currentTarget.dataset.index;
        var currentStudy = component.get('v.currentStudy');
        var studySiteWrapper = currentStudy.ssList[popupIndex];
        parent.find('actionManageLocationDetails').execute(studySiteWrapper, function(ss){
            currentStudy.ssList[popupIndex].studySite = ss;
            component.set('v.currentStudy',currentStudy);
        });


/*
        component.set('v.editAddress', false);
        component.set('v.checkedAccount', null);
        component.set('v.locationWasChanged', false);
        component.set('v.currentCountry', null);
        component.set('v.editedAccount', null);
        var popupIndex = event.currentTarget.dataset.index;
        var accounts = component.get('v.currentStudy.ssList')[popupIndex].accounts;
        component.set('v.popupIndex', popupIndex);
        var popUps = component.find('manage-location');
        if (popUps.length) {
            popUps[popupIndex].show();
            component.set('v.currentStudy.ssList[' + popupIndex + '].accounts', null);
            component.set('v.currentStudy.ssList[' + popupIndex + '].accounts', accounts);
            setTimeout($A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
            }), 5);
        } else {
            popUps.show();
            component.set('v.currentStudy.ssList[' + popupIndex + '].accounts', null);
            component.set('v.currentStudy.ssList[' + popupIndex + '].accounts', accounts);
            setTimeout($A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
            }), 5);
        }*/

    },

    /*changeRadioMarker: function (component, event, helper) {
        var radioBtns = component.find('radioBtn');
        for (let i = 0; i < radioBtns.length; i++) {
            radioBtns[i].set('v.checked', false);
        }
        event.getSource().set('v.checked',true);
        component.set('v.checkedAccount', event.getSource().get('v.value'));
        component.set('v.locationWasChanged', true);
    },*/

    /*changeStudySiteAddress: function (component, event, helper) {
        var ctarget = event.currentTarget.value;
        var element = component.get('v.currentStudy.ssList');
        var currentSS = element[ctarget].studySite;
        var checkedAccount = component.get('v.checkedAccount');
        currentSS.Site__c = checkedAccount.Id;
        var parent = component.get('v.parent');
        component.set('v.locationWasChanged', false);
        parent.saveSSDetails(currentSS);
    },*/


    editAccountAddress: function (component, event, helper) {
        component.set('v.addressChecked', false);
        var editIndx = event.target.dataset.indx;
        var ssIndex = event.target.dataset.index;
        component.set('v.states', []);
        var cmp;
        if (editIndx) {
            cmp = JSON.parse(JSON.stringify(component.get('v.currentStudy.ssList')[ssIndex].accounts[editIndx]));
        } else if (!editIndx && !ssIndex) {
            var ssWrapIndex = JSON.parse(JSON.stringify(component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Principal_Investigator__r));
            cmp = new Object({'Id': null, 'BillingCountry': ssWrapIndex.MailingAddress.country, 'BillingStateCode': ssWrapIndex.MailingAddress.stateCode});
        } else {
            cmp = JSON.parse(JSON.stringify(component.get('v.currentStudy.ssList')[ssIndex].studySite.Site__r));
        }
        if (cmp.BillingCountry) {
            var countryCodeByName = component.get('v.countryCodesMap');
            var statesMapByCountry = component.get('v.statesByCountryMap');
            component.set('v.currentCountry', countryCodeByName[cmp.BillingCountry]);
            var states = statesMapByCountry[countryCodeByName[cmp.BillingCountry]];
            component.set('v.states', states);
        }
        //if(cmp.BillingLongitude && cmp.BillingLatitude){
            helper.setCoordinates(component,cmp);
        //}
        component.set('v.editedAccount', cmp);
        component.set('v.editAddress', true);
    },

    closeModal: function (component, event, helper) {
        var index = component.get('v.popupIndex');
        var popUps = component.find('manage-location');
        if (popUps.length) {
            popUps[index].hide();
        } else {
            popUps.hide();
        }
    },
    backToTheChoice: function (component, event, helper) {
        component.set('v.editAddress', false);
        component.set('v.editedAccount', null);
        component.set('v.showPopUpSpinner', false);
        setTimeout($A.getCallback(function () {
            helper.doUpdateStudyTitle(component);
        }), 10);
        component.set('v.currentCountry', null);
        component.set('v.states', []);
        component.set('v.addressChecked', false);
    },
    saveNewAccount: function (component, event, helper) {
        var ssIndex = event.currentTarget.value;
        component.set('v.addressChecked', false);
        var newAccount = component.get('v.editedAccount');
        var element = component.get('v.currentStudy.ssList');
        var currentSS = element[ssIndex].studySite;
        currentSS.Site__r = newAccount;
        var states = component.get('v.states');
        if (states) {
            for (let i = 0; i < states.length; i++) {
                if (states[i].value === currentSS.Site__r.BillingStateCode) {
                    currentSS.Site__r.BillingState = states[i].label;
                    break;
                }
            }
        }
        var parent = component.get('v.parent');
        component.set('v.addressWasChanged', false);
        var popUps = component.find('manage-location');
        var popupIndex = component.get('v.popupIndex');
        if (popUps.length) {
            popUps[popupIndex].hide();
        } else {
            popUps.hide();
        }
        parent.saveSSnewAddress(currentSS);
    },
    showChecked: function (component, event, helper) {
        component.set('v.makeDefault', event.getSource().get('v.checked'));
    },
    recordWasUpdated: function (component, event, helper) {
        component.set('v.addressWasChanged', true);
    },

    trimChanges: function (component, event, helper) {
        var val = event.getSource().get('v.value');
        event.getSource().set('v.value', val.trim());
        if(!event.getSource().checkValidity()){
            event.getSource().showHelpMessageIfInvalid();
        }
    },

    doCountryChange: function (component, event, helper) {
        component.set('v.addressWasChanged', true);
        component.set('v.addressChecked', false);
        var statesMapByCountry = component.get('v.statesByCountryMap');
        var acc = component.get('v.editedAccount');
        if (acc) {
            var countryNameByCode = component.get('v.countriesMap');
            var countryCode = component.get('v.currentCountry');
            component.set('v.editedAccount.BillingCountry', countryNameByCode[countryCode]);
            var states = statesMapByCountry[countryCode];
            console.log('States >>>', states);
            if (states.length && states.length > 0) {
                component.set('v.states', states);
            } else {
                component.set('v.editedAccount.BillingState', null);
                component.set('v.states', []);
            }
        }
    },

    checkAddress: function (component, event, helper) {
        component.set('v.showPopUpSpinner', true);
        var currentAccount = component.get('v.editedAccount');
        communityService.executeAction(component, 'createTmpAccountForLocationCheck', {
            account: JSON.stringify(currentAccount)
        }, function (createdAccountId) {
            helper.waitAccountCheckResult(component, createdAccountId, 0);
        });
    }


})