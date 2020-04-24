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
        component.set('v.visitPlanRequired', formData.visitPlansLVList.length > 0);
    },

     doCheckFields: function (component, event, hepler) {
        console.log('pe', JSON.parse(JSON.stringify(component.get('v.pe'))));
        console.log('part', JSON.parse(JSON.stringify(component.get('v.participant'))));
        console.log('doCheckFields');
        var helpText = component.find('helpText');
        var participant = component.get('v.participant');
        var participantDelegate = component.get('v.participantDelegate');
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        var pe = component.get('v.pe');
        var updateMode = component.get('v.updateMode');
        var isFinalUpdate = component.get('v.isFinalUpdate');
        var stateRequired = component.get('v.statesLVList')[0];
        var stateCmp = component.find('stateField');
        var stateVaild = stateCmp && stateCmp.get('v.validity') && stateCmp.get('v.validity').valid;
        var dataStamp = component.get('v.dataStamp');
        var isValid = false;
        const screeningIdRequiredStatuses = 'Enrollment Success; Treatment Period Started; Follow-Up Period Started; Participation Complete; Trial Complete';
        let screeningIdRequired = false;
        var isEnrollmentSuccess = false;
        var today = new Date();
        var inDate = new Date(participant.Date_of_Birth__c);
        var currentDate = today.setHours(0, 0, 0, 0);
        var inputDate = inDate.setHours(0, 0, 0, 0);
        if(pe.MRN_Id__c){
            component.set('v.disableSourceId', true);
        } else {
            component.set('v.disableSourceId', false);
        }
        if (pe && pe.Participant_Status__c) {
            isEnrollmentSuccess = pe.Participant_Status__c === 'Enrollment Success';
            screeningIdRequired = isFinalUpdate || screeningIdRequiredStatuses.indexOf(pe.Participant_Status__c) !== -1;
            component.set('v.visitPlanDisabled', pe.Id && screeningIdRequiredStatuses.indexOf(pe.Participant_Status__c) !== -1);
        }
        let isVisitPlanNotRequired = !component.get('v.visitPlanRequired') || !screeningIdRequired;
        component.set('v.screeningRequired', screeningIdRequired);
        if (updateMode && !isFinalUpdate && dataStamp) {
            var oldPE = JSON.parse(dataStamp);
            var isRemovedValue =
                (oldPE.Participant__r.First_Name__c && !participant.First_Name__c) ||
                (oldPE.Participant__r.Last_Name__c && !participant.Last_Name__c) ||
                (oldPE.Participant__r.Date_of_Birth__c && !participant.Date_of_Birth__c) ||
                (oldPE.Participant__r.Gender__c && !participant.Gender__c) ||
                (oldPE.Participant__r.Phone__c && !participant.Phone__c) ||
                (oldPE.Participant__r.Phone_Type__c && !participant.Phone_Type__c) ||
                (oldPE.Participant__r.Email__c && !participant.Email__c) ||
                (oldPE.Participant__r.Mailing_Country_Code__c && !participant.Mailing_Country_Code__c) ||
                (stateRequired && oldPE.Participant__r.Mailing_State_Code__c && !participant.Mailing_State_Code__c) ||
                (oldPE.Participant__r.Mailing_Zip_Postal_Code__c && !participant.Mailing_Zip_Postal_Code__c) ||
                (oldPE.Screening_ID__c && !pe.Screening_ID__c) ||
                (oldPE.Referred_By__c && !pe.Referred_By__c) ||
                (oldPE.MRN_Id__c && !pe.MRN_Id__c);
            console.log(isRemovedValue);
            isValid = !isRemovedValue;
            if(component.get('v.fromActionParticipant') && !isRemovedValue){
                console.log('component.get(\'v.fromActionParticipant\') && !isRemovedValue');
                if (participant.First_Name__c.trim() &&
                    participant.Last_Name__c.trim() &&
                    inputDate <= currentDate &&
                    participant.Gender__c.trim() &&
                    (participantDelegate || participant.Phone__c.trim()) &&
                    (participantDelegate || participant.Phone_Type__c.trim()) &&
                    (participantDelegate || participant.Email__c && component.find('emailInput').get('v.validity').valid) &&
                    (!participantDelegate || participantDelegate.Phone__c.trim()) &&
                    (!participantDelegate || participantDelegate.First_Name__c.trim()) &&
                    (!participantDelegate || participantDelegate.Last_Name__c.trim()) &&
                    participant.Mailing_Zip_Postal_Code__c.trim() !== ''){
                        isValid = true;
                } else {
                    isValid = false;
                }
                console.log('isValid1' + isValid);
            }
        } else if (updateMode && isFinalUpdate) {
            isValid =
                participant.First_Name__c &&
                participant.Last_Name__c &&
                participant.Date_of_Birth__c &&
                participant.Gender__c &&
                (participantDelegate || participant.Phone__c.trim()) &&
                (participantDelegate || participant.Phone_Type__c.trim()) &&
                (participantDelegate || participant.Email__c && component.find('emailInput').get('v.validity').valid) &&
                (!participantDelegate || participantDelegate.Phone__c.trim()) &&
                (!participantDelegate || participantDelegate.First_Name__c.trim()) &&
                (!participantDelegate || participantDelegate.Last_Name__c.trim()) &&
                participant.Email__c &&
                participant.Mailing_Zip_Postal_Code__c !== '' &&
                pe &&
                pe.Participant_Status__c &&
                (pe.Visit_Plan__c || isVisitPlanNotRequired) &&
                pe.Screening_ID__c &&
                stateVaild;
            console.log('isValid2' + isValid);
            if(component.get('v.fromActionParticipant') && !isRemovedValue){
                console.log('component.get(\'v.fromActionParticipant\') && !isRemovedValue');
                if(participant.First_Name__c.trim() &&
                    participant.Last_Name__c.trim() &&
                    inputDate <= currentDate &&
                    participant.Gender__c.trim() &&
                    (participantDelegate || participant.Phone__c.trim()) &&
                    (participantDelegate || participant.Phone_Type__c.trim()) &&
                    (participantDelegate || participant.Email__c && component.find('emailInput').get('v.validity').valid) &&
                    (!participantDelegate || participantDelegate.Phone__c.trim()) &&
                    (!participantDelegate || participantDelegate.First_Name__c.trim()) &&
                    (!participantDelegate || participantDelegate.Last_Name__c.trim()) &&
                    participant.Mailing_Zip_Postal_Code__c.trim() !== ''){
                        isValid = true;
                } else {
                    isValid = false;
                }
                console.log('isValid3' + isValid);
            }

                //(!stateRequired || (stateRequired && (participant.Mailing_State_Code__c !== '' || participant.Mailing_State_Code__c !== undefined || participant.Mailing_State_Code__c !== null)));
        } else if (!updateMode) {
            console.log('!updateMode');
            //var checkReferred = source == 'ePR' ? true : pe.Referred_By__c ? true : false;
            isValid =
                participant.First_Name__c &&
                participant.Last_Name__c &&
                participant.Date_of_Birth__c &&
                participant.Gender__c &&
                (participantDelegate || participant.Phone__c.trim()) &&
                (participantDelegate || participant.Phone_Type__c.trim()) &&
                (participantDelegate || participant.Email__c && component.find('emailInput').get('v.validity').valid) &&
                (!participantDelegate || participantDelegate.Phone__c.trim()) &&
                (!participantDelegate || participantDelegate.First_Name__c.trim()) &&
                (!participantDelegate || participantDelegate.Last_Name__c.trim()) &&
                participant.Mailing_Zip_Postal_Code__c &&
                pe &&
                pe.Participant_Status__c &&
                (!isEnrollmentSuccess || (isEnrollmentSuccess && pe.Screening_ID__c)) &&
                //(!stateRequired || (stateRequired && (participant.Mailing_State_Code__c !== '' || participant.Mailing_State_Code__c !== undefined || participant.Mailing_State_Code__c !== null))) &&
                stateVaild &&
                (pe.Visit_Plan__c || isVisitPlanNotRequired) &&
                pe.Referred_By__c;
            console.log('isValid4' + isValid);
        }
        if(participant.Alternative_Phone_Number__c && !participant.Alternative_Phone_Type__c){
            isValid = false;
        }
        component.set('v.isValid', isValid);
         console.log('isValid5' + isValid);
        return isValid;
    },

    doCountryCodeChanged: function (component, event, helper) {
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var countryMap =  component.get('v.formData.countriesLVList');
        var participant = component.get('v.participant');
        for (let i = 0; i <countryMap.length ; i++) {
            if(countryMap[i].value == participant.Mailing_Country_Code__c){
                component.set('v.participant.Mailing_Country__c', countryMap[i].label);
                break;
            }
        }
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        component.set('v.participant.Mailing_State_Code__c', null);
        component.set('v.participant.Mailing_State__c', null);
        component.checkFields();
    },

    doStateChange: function(component, event, helper){
    	var states = component.get('v.statesLVList');
    	if (states){
            var participant = component.get('v.participant');
            for (let i = 0; i < states.length ; i++) {
                if(states[i].value == participant.Mailing_State_Code__c){
                    component.set('v.participant.Mailing_State__c', states[i].label);
                    break;
                }
            }
        }
        component.checkFields();
    },

    doCreateDataStamp: function (component, event, helper) {
        var pe = component.get('v.pe');
        component.set('v.dataStamp', JSON.stringify(pe));
    },

    doRefreshView: function(component, event, helper){
    	component.set('v.isRefreshView', true);
    	component.set('v.isRefreshView', false);
    },

    hideHelp: function (component) {
        component.set('hideHelp', false);
    }


})