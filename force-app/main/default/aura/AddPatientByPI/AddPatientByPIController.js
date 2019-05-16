/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        var ctpId = communityService.getUrlParameter('id');
        communityService.executeAction(component, 'getInitData', {
            ctpId: ctpId
        }, function (formData) {
            component.set('v.ctp', formData.ctp);
            component.set('v.ss', formData.ss);
            var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
            component.set('v.todayDate', todayDate);
            component.set('v.formData', formData);
            helper.initData(component);
            component.set('v.initialized', true);
        }, null, function () {
            component.find('spinner').hide();
        });
    },
    
    doCheckFields: function (component) {
        var participant = component.get('v.participant');
        var pe = component.get('v.pe');
        var isEnrollmentSuccess = false;
        if(pe && pe.Participant_Status__c) {
            isEnrollmentSuccess = pe.Participant_Status__c === 'Enrollment Success';
        }
        component.set('v.screeningRequired', isEnrollmentSuccess);

        var isAllRequiredCompletedAndValid =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Date_of_Birth__c &&
            participant.Gender__c &&
            participant.Phone__c &&
            participant.Phone_Type__c &&
            participant.Email__c &&
            participant.Mailing_State_Code__c &&
            participant.Mailing_Zip_Postal_Code__c &&
            pe.Participant_Status__c &&
            communityService.isValidEmail(participant.Email__c) &&
            (!isEnrollmentSuccess || (isEnrollmentSuccess && pe.Screening_ID__c)) &&
            pe.Referred_By__c;
        component.set('v.isAllRequiredCompleted', isAllRequiredCompletedAndValid);
    },

    doCancel: function (component) {
        communityService.navigateToPage('study-workspace?tab=tab-referrals&id=' + component.get('v.ctp.Id'))
    },

    doSaveAndExit: function (component, event, helper) {
        helper.createParticipant(component, function () {
           communityService.navigateToPage('study-workspace?tab=tab-referrals&id=' + component.get('v.ctp.Id'))
        })
    },

    doSaveAndNew: function (component, event, helper) {
        helper.createParticipant(component, function () {
            helper.initData(component);
        })
    }
})