/**
 * Created by Leonid Bartenev
 */
({
    initData: function (component,event,helper) {
        component.set('v.isInitData',true);
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: component.get('v.ss.Principal_Investigator__r.MailingAddress.countryCode'),
            Mailing_State_Code__c: component.get('v.ss.Principal_Investigator__r.MailingAddress.stateCode')
        });
        component.set('v.pe', {
            sobjectType: 'Participant_Enrollment__c',
            Study_Site__c: component.get('v.ss.Id'),
        });
        component.set('v.isInitData',false);
    },

    initDataEdit: function (component,event,helper) {
        var pId = communityService.getUrlParameter('id');
        communityService.executeAction(component, 'getParticipantRecord', {
            participantEnrollmentId: pId
        }, function (formData) {
            component.set('v.isInitData',true);
            component.set('v.pe', formData.peRecord);
            component.set('v.isInitData',false);
            component.set('v.participant', formData.participantRecord);
            component.set('v.participant.Mailing_State_Code__c',formData.participantState);
            component.set('v.participant.Phone_Type__c',formData.participantPhoneType);
            if(component.get('v.entrollmentSuccess')){
                component.set('v.pe.Participant_Status__c','Enrollment Success');
                communityService.showSuccessToast('',  $A.get('$Label.c.RP_Missing_Fields'));
            }
        }, null, function () {
            component.find('spinner').hide();
        });

    },

    createParticipant: function (component, callback) {
        component.find('spinner').show();
        var pe = component.get('v.pe');
        var helper = this;
        if(pe.Participant_Status__c === 'Enrollment Success') {
            component.find('actionApprove').execute(function () {
                pe.Informed_Consent__c = true;
                helper.saveParticipant(component, pe, callback);
            }, function () {
                component.find('spinner').hide();
                communityService.showWarningToast(null, $A.get('$Label.c.Toast_ICF'));
            });
        } else {
            helper.saveParticipant(component, pe, callback);
        }
    },

    saveParticipant : function (component, pe, callback) {
        var helper = this;
        var doAdditionalCallout = false;
        if(pe.Participant_Status__c === 'Enrollment Success'){
            pe.Participant_Status__c = 'Screening In Progress';
            doAdditionalCallout = true;
        }else if(pe.Participant_Status__c === 'Temporary Status'){
             pe.Participant_Status__c = 'Enrollment Success';
             doAdditionalCallout = false;
        }
        var participant = component.get('v.participant');
        communityService.executeAction(component, 'saveParticipant', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe)
        }, function (peId) {
            if(doAdditionalCallout){
                pe.Participant_Status__c = 'Temporary Status';
                pe.Id = peId;
                helper.saveParticipant(component, pe, callback);
            }
            else{
                communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
                callback();
            }
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    checkFields: function(component,event,helper){
        if(!component.get('v.isInitData')) {
            var source = component.get('v.source');
            var participant = component.get('v.participant');
            var isEditMode = component.get('v.isEditMode');
            var pe = component.get('v.pe');
            var isEnrollmentSuccess = false;
            if (pe && pe.Participant_Status__c) {
                isEnrollmentSuccess = pe.Participant_Status__c === 'Enrollment Success';
            }
            component.set('v.screeningRequired', isEnrollmentSuccess);
            var stateRequired = component.get('v.statesLVList')[0];
            var isAllRequiredCompletedAndValid = false;
            if (isEditMode && !component.get('v.entrollmentSuccess')) {
                isAllRequiredCompletedAndValid =
                    participant.First_Name__c != '' &&
                    participant.Last_Name__c != '' &&
                    participant.Date_of_Birth__c != '' &&
                    participant.Date_of_Birth__c != null &&
                    participant.Gender__c != '' &&
                    participant.Phone__c != '' &&
                    participant.Phone_Type__c != '' &&
                    participant.Email__c != '' &&
                    participant.Mailing_Zip_Postal_Code__c != '' &&
                    pe &&
                    pe.Participant_Status__c != '' &&
                    component.find('emailInput') &&
                    component.find('emailInput').get('v.validity').valid &&
                    (pe.Screening_ID__c != '') &&
                    pe.MRN_Id__c != '';
            } else {
                //var checkReferred = source == 'ePR' ? true : pe.Referred_By__c ? true : false;
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
                    /*(pe.Referred_By__c == 'Internal Database' || pe.Referred_By__c == 'External Physician' ||
                        pe.Referred_By__c == 'Recruitment Campaign'  || pe.Referred_By__c == 'Virtual Trial Campaign' || pe.Referred_By__c == 'Other');*/
            }
            component.set('v.isAllRequiredCompleted', isAllRequiredCompletedAndValid);
        }
    },
})