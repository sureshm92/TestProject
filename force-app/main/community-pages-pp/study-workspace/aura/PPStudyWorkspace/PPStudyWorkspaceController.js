/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.scrollToTop(true);
        var spinner = component.get('v.parent').find('mainSpinner');
        spinner.show();
        var recId = communityService.getUrlParameter('id');
        var tabId = communityService.getUrlParameter('tab');
        if(tabId === undefined) tabId = 'tab-about-the-study'; //tab by default;
        var resourceMode = communityService.getUrlParameter('resourcemode');
        if(!resourceMode) resourceMode = 'Default';
        var taskMode = communityService.getUrlParameter('taskmode');
        if(!taskMode) taskMode = 'Open';
        var visitMode = communityService.getUrlParameter('visitmode');
        if(!visitMode) visitMode = 'VisitDetails';

        if(communityService.isInitialized()){
            component.set('v.userMode', communityService.getUserMode());
            component.set('v.state', communityService.getCurrentCommunityMode().participantState);
            component.set('v.multiMode', communityService.getAllUserModes().length > 1);
            component.set('v.isDelegateMode', communityService.getCurrentCommunityMode().currentDelegateId);
            component.set('v.currentTab', tabId);
            component.set('v.taskMode', taskMode);
            component.set('v.resourceMode', resourceMode);
            component.set('v.visitMode', visitMode);

            communityService.executeAction(component, 'getTrialDetail', {
                trialId: recId,
                userMode: communityService.getUserMode()
            }, function (returnValue) {
                var trialDetail = JSON.parse(returnValue);
                if(!trialDetail.showVisits) visitMode = 'TravelSupportDetails';
                //find tab
                var selectedTabId = trialDetail.tabs[0].id;
                for(var i = 0; i < trialDetail.tabs.length; i++){
                    if(tabId === trialDetail.tabs[i].id){
                        selectedTabId = tabId;
                        break;
                    }
                }
                component.set('v.visitMode', visitMode);
                component.set('v.currentTab', selectedTabId);
                if(trialDetail.isTCAccepted !== null) {
                    if(!trialDetail.isTCAccepted) {
                        communityService.navigateToPage('trial-terms-and-conditions?id='
                            + trialDetail.trial.Id
                            + '&ret=' + communityService.createRetString());
                        return;
                    }
                }

                component.set('v.studyDetail', trialDetail);
                //get sticky bar position in browser window
                //if(!component.get('v.isInitialized')) communityService.setStickyBarPosition();
                component.set('v.isInitialized', true);
                if(trialDetail.trial !== null) component.set('v.shareButtons', trialDetail.shareActions);

                helper.setTabInitialized(component);
                helper.setTabActions(component);
                spinner.hide();
                helper.mailSendMessage(component);
            });
        }
    },

    doAction: function (component, event) {
        var studyDetail = component.get('v.studyDetail');
        var trial = studyDetail.trial;
        if(!trial) trial = {};
        var trialId = trial.Id;
        var actionId = event.currentTarget.id;
        let shareUrl = trial.Share_URL__c + 'none';
        let shareText = 'A clinical study of interest';
        switch (actionId){
            case 'backHome' :
                communityService.navigateToPage('');
                break;
            case 'medicalRecordReview':
                communityService.navigateToPage('medical-record-review?id=' + trialId);
                break;
            case 'referToThisStudy':
            case 'refer':
                communityService.navigateToPage('referring?id=' + trialId);
                break;
            case 'shareEmail': {
                var modal = component.find('shareModal');
                if (communityService.getUserMode() === 'HCP') {
                    modal.show(studyDetail.hcpe.Id, studyDetail.hcpe.HCP_Contact__c);
                } else if (communityService.getUserMode() === 'Participant') {
                    modal.show(studyDetail.pe.Id, null);
                }
            }
                break;
            case 'shareFacebook':
                window.open('https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(shareUrl) + '&quote=' + shareText);
                break;
            case 'shareTwitter':
                window.open('https://twitter.com/intent/tweet?text=' + shareText + '&url=' + encodeURIComponent(shareUrl));
                break;
            case 'shareLinkedin':
                window.open('https://www.linkedin.com/shareArticle?mini=true&url=' + encodeURIComponent(shareUrl));
                break;
            case 'viewTermsAndConditions':
                communityService.navigateToPage("trial-terms-and-conditions?id=" + trialId + "&ret="
                    + communityService.createRetString());
                break;
            case 'findStudySites':
                communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                break;
            case 'noThanks':
                break;
            case 'manageReferrals':
                break;
            case 'manageReferringClinics':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referred-clinics");
                break;
            case 'openToReceiveReferrals':
                break;
            case 'changeResourceMode':
                var resourceMode= event.currentTarget.dataset.resourceMode;
                component.set('v.resourceMode', resourceMode);
                break;
            case 'changeVisitMode':
                component.set('v.visitMode', event.currentTarget.dataset.visitMode);
                break;
            case 'changeLabResultsMode':
                component.set('v.labResultsMode', event.currentTarget.dataset.labResultsMode);
                break;
            case 'changeTaskMode':
                var taskMode = event.currentTarget.dataset.taskMode;
                component.set('v.taskMode', taskMode);
                break;
            case 'shares':
                component.set('v.isShare', !component.get('v.isShare'));
                break;
            case 'addPatient':
                communityService.navigateToPage('add-patient?id=' + trialId);
                break;
        }
    },

    doScrollInto: function (component, event) {
        communityService.logError(function () {
            var tag = event.currentTarget.dataset.anchor;
            communityService.scrollInto(tag);
        });
    },

    doTabChanged: function(component, event, helper){
        helper.setBrowserHistory(component);
        helper.setTabInitialized(component);
        helper.setTabActions(component);
    }

})