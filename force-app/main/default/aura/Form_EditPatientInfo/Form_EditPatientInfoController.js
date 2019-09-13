/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        var formData = component.get('v.formData');
        var states = formData.statesByCountryMap['US'];
        component.set('v.statesLVList', states);
    },

    doCheckFields: function (component, event, hepler) {
        if(!component.get('v.handleChangesEnabled')) return;
        var participant = component.get('v.participant');
        var pe = component.get('v.pe');
        console.log('pe>>>', JSON.parse(JSON.stringify(pe)));
        console.log('participant>>>', JSON.parse(JSON.stringify(participant)));
        var updateMode = component.get('v.updateMode');
        var isFinalUpdate = component.get('v.isFinalUpdate');
        var isEnrollmentSuccess = false;
        if (pe && pe.Participant_Status__c) {
            isEnrollmentSuccess = pe.Participant_Status__c === 'Enrollment Success';
        }
        component.set('v.screeningRequired', isEnrollmentSuccess || isFinalUpdate);
        var stateRequired = component.get('v.statesLVList')[0];
        var dataStamp = component.get('v.dataStamp');
        var isValid = false;
        if (updateMode && !isFinalUpdate && dataStamp) {
            var oldPE = JSON.parse(dataStamp);
            var isRemovedValue =
                (oldPE.Participant__r.First_Name__c && !participant.First_Name__c) ||
                (oldPE.Participant__r.Middle_Name__c && !participant.Middle_Name__c) ||
                (oldPE.Participant__r.Last_Name__c && !participant.Last_Name__c) ||
                (oldPE.Participant__r.Date_of_Birth__c && !participant.Date_of_Birth__c) ||
                (oldPE.Participant__r.Gender__c && !participant.Gender__c) ||
                (oldPE.Participant__r.Phone__c && !participant.Phone__c) ||
                (oldPE.Participant__r.Phone_Type__c && !participant.Phone_Type__c) ||
                (oldPE.Participant__r.Email__c && !participant.Email__c) ||
                (oldPE.Participant__r.Mailing_Country_Code__c && !participant.Mailing_Country_Code__c) ||
                (oldPE.Participant__r.Mailing_State_Code__c && !participant.Mailing_State_Code__c) ||
                (oldPE.Participant__r.Mailing_Zip_Postal_Code__c && !participant.Mailing_Zip_Postal_Code__c) ||
                (oldPE.Screening_ID__c && !pe.Screening_ID__c) ||
                (oldPE.Screening_ID__c && !pe.Referred_By__c) ||
                (oldPE.MRN_Id__c && !pe.MRN_Id__c);
            isValid = !isRemovedValue;
        } else if (updateMode && isFinalUpdate) {
            isValid =
                participant.First_Name__c &&
                participant.Last_Name__c &&
                participant.Date_of_Birth__c &&
                participant.Gender__c &&
                participant.Phone__c &&
                participant.Phone_Type__c &&
                participant.Email__c &&
                participant.Mailing_Zip_Postal_Code__c !== '' &&
                pe &&
                pe.Participant_Status__c &&
                pe.Referred_By__c &&
                component.find('emailInput').get('v.validity').valid &&
                pe.Screening_ID__c &&
                (!stateRequired || (stateRequired && participant.Mailing_State_Code__c));
        } else if (!updateMode) {
            //var checkReferred = source == 'ePR' ? true : pe.Referred_By__c ? true : false;
            isValid =
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
        component.set('v.isValid', isValid);
    },

    doCountryCodeChanged: function (component, event, helper) {
        if(!component.get('v.handleChangesEnabled')) return;
        console.log('doCountryCodeChanged');
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var participant = component.get('v.participant');
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        component.set('v.participant.Mailing_State_Code__c', null);
        component.checkFields();
    },

    doCreateDataStamp: function (component, event, helper) {
        var pe = component.get('v.pe');
        component.set('v.dataStamp', JSON.stringify(pe));
    }


})