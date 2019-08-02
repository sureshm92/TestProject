/**
 * Created by Leonid Bartenev
 */
({
    initData: function (component,event,helper) {
        console.log('STATE>>>',component.get('v.ss.Principal_Investigator__r.MailingAddress.stateCode'));
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: component.get('v.ss.Principal_Investigator__r.MailingAddress.countryCode'),
            Mailing_State_Code__c: component.get('v.ss.Principal_Investigator__r.MailingAddress.stateCode')
        });
        component.set('v.pe', {
            sobjectType: 'Participant_Enrollment__c',
            Study_Site__c: component.get('v.ss.Id'),
        });
    },

    initDataEdit: function (component,event,helper) {
        /*component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: 'US'
        });*/
        
        var pId = communityService.getUrlParameter('id');
        console.log('pId', pId);
        communityService.executeAction(component, 'getParticipantRecord', {
            participantEnrollmentId: pId
        }, function (formData) {
            component.set('v.participant', formData.participantRecord);
            component.set('v.participant.Mailing_State_Code__c',formData.participantState);
            component.set('v.participant.Phone_Type__c',formData.participantPhoneType);
            component.set('v.pe', formData.peRecord);
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
        console.log('participant', participant);
        console.log('pe', pe);
        communityService.executeAction(component, 'saveParticipant', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe)
        }, function (peId) {
            console.log('peId', peId);
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
        var participant = component.get('v.participant');
        var isEditMode = component.get('v.isEditMode');
        var pe = component.get('v.pe');
        var isEnrollmentSuccess = false;
        if(pe && pe.Participant_Status__c) {
            isEnrollmentSuccess = pe.Participant_Status__c === 'Enrollment Success';
        }
        component.set('v.screeningRequired', isEnrollmentSuccess);
        var stateRequired = component.get('v.statesLVList')[0];
        var isAllRequiredCompletedAndValid = false;
        /*if(isEditMode){
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
                (pe.Screening_ID__c != '' && pe.Screening_ID__c != null && pe.Screening_ID__c != undefined) &&
                pe.MRN_Id__c != '';
        }else{*/
        console.log('participant>>>>>>>',JSON.parse(JSON.stringify(participant)));
        console.log('pe>>>>>>>',JSON.parse(JSON.stringify(pe)));
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
        //}

        component.set('v.isAllRequiredCompleted', isAllRequiredCompletedAndValid);
    },
})