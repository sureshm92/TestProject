/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var isEditMode = component.get('v.isEditMode');
        if(!communityService.isInitialized()) return;
        var ctpId = isEditMode ? null : communityService.getUrlParameter('id');
        var ssId = communityService.getUrlParameter('ssId');
        communityService.executeAction(component, 'getInitData', {
            ctpId: ctpId,
            ssId : ssId ? ssId : null
        }, function (formData) {
            component.set('v.ctp', formData.ctp);
            component.set('v.ss', formData.ss);
            var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
            component.set('v.todayDate', todayDate);
            component.set('v.formData', formData);
            if(isEditMode){
                helper.initDataEdit(component);
            }else{
                helper.initData(component);
            }
            component.set('v.initialized', true);
            var pe = component.get('v.pe');
            var states = formData.statesByCountryMap['US'];
            component.set('v.statesLVList', states);
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
        console.log('participant.Phone_Type__c', participant.Phone_Type__c);
        console.log('participant.First_Name__c', participant.First_Name__c);
        var stateRequired = component.get('v.statesLVList')[0];
        var isAllRequiredCompletedAndValid =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Date_of_Birth__c &&
            participant.Gender__c &&
            participant.Phone__c &&
            participant.Phone_Type__c &&
            participant.Email__c &&
            participant.Mailing_Zip_Postal_Code__c &&
            pe &&
            pe.Participant_Status__c &&
            component.find('emailInput').get('v.validity').valid &&
            (!isEnrollmentSuccess || (isEnrollmentSuccess && pe.Screening_ID__c)) &&
            (!stateRequired || (stateRequired && participant.Mailing_State_Code__c)) &&
            pe.Referred_By__c;
        component.set('v.isAllRequiredCompleted', isAllRequiredCompletedAndValid);
    },

     doCheckFields: function (component) {
        var participant = component.get('v.participant');
        var isEditMode = component.get('v.isEditMode');
        var pe = component.get('v.pe');
        var isEnrollmentSuccess = false;
        if(pe && pe.Participant_Status__c) {
            isEnrollmentSuccess = pe.Participant_Status__c === 'Enrollment Success';
        }
        component.set('v.screeningRequired', isEnrollmentSuccess);
        console.log('participant.Phone_Type__c', participant.Phone_Type__c);
        console.log('participant.First_Name__c', participant.First_Name__c);
        var stateRequired = component.get('v.statesLVList')[0];
        var isAllRequiredCompletedAndValid = false;
        if(isEditMode){
            isAllRequiredCompletedAndValid =
            participant.First_Name__c != '' &&
            participant.Last_Name__c != '' &&
            participant.Date_of_Birth__c != '' &&
            participant.Gender__c != '' &&
            participant.Phone__c != '' &&
            participant.Phone_Type__c != '' &&
            participant.Email__c != '' &&
            participant.Mailing_Zip_Postal_Code__c != '' &&
            pe &&
            pe.Participant_Status__c != '' &&
            component.find('emailInput').get('v.validity').valid &&
            (!isEnrollmentSuccess || (isEnrollmentSuccess && pe.Screening_ID__c != '')) &&
            (!stateRequired || (stateRequired && participant.Mailing_State_Code__c != '')) &&
            pe.Referred_By__c != '';
        }else{
            isAllRequiredCompletedAndValid =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Date_of_Birth__c &&
            participant.Gender__c &&
            participant.Phone__c &&
            participant.Phone_Type__c &&
            participant.Email__c &&
            participant.Mailing_Zip_Postal_Code__c &&
            pe &&
            pe.Participant_Status__c &&
            component.find('emailInput').get('v.validity').valid &&
            (!isEnrollmentSuccess || (isEnrollmentSuccess && pe.Screening_ID__c)) &&
            (!stateRequired || (stateRequired && participant.Mailing_State_Code__c)) &&
            pe.Referred_By__c;
        }
            
        component.set('v.isAllRequiredCompleted', isAllRequiredCompletedAndValid);
    },

    doCountryCodeChanged: function(component, event, helper){
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var participant = component.get('v.participant');
        var states = component.get('v.formData.statesByCountryMap')[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        component.set('v.participant.Mailing_State_Code__c', null);
        component.checkFields();
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