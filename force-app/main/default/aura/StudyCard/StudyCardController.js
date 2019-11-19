/**
 * Created by Nikita Abrazhevitch on 21-Aug-19.
 */

({
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

    doAction: function (component, event) {
        var currentStudy = component.get('v.currentStudy');
        var trialId = currentStudy.trial.Id;
        var parent = component.get('v.parent');
        var actionId = event.currentTarget.id;
        if (!actionId) actionId = event.getSource().getLocalId();
        switch (actionId) {
            case 'medicalRecordReview':
                communityService.navigateToPage('referring?id=' + trialId);
                break;
            case 'referToThisStudy':
            case 'refer':
                communityService.navigateToPage('referring?id=' + trialId);
                break;
            case 'share':
                parent.find('shareModal').show(trialId, currentStudy.hcpe.HCP_Contact__c);
                break;
            case 'acceptTermsAndConditions':
                communityService.navigateToPage("trial-terms-and-conditions?id=" + trialId + "&ret=" + communityService.createRetString());
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
            case 'linkToStudySites':
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
        }
    },

    toggleStudySiteListView: function (cmp, event, helper) {
        let detailsExpanded = cmp.get('v.detailsExpanded');
        if (detailsExpanded) {
            cmp.set('v.detailsExpanded', false);
        } else {
            cmp.set('v.detailsExpanded', true);
        }
    },

    navigateToSitesSearch: function (component, event, helper) {
        var currentStudy = component.get('v.currentStudy');
        var trialId = currentStudy.trial.Id;
        communityService.navigateToPage("sites-search?id=" + trialId);
    },

});