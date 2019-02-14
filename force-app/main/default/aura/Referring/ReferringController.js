/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        var trialId = communityService.getUrlParameter("id");
        var peId = communityService.getUrlParameter("peid");
        if(!trialId) communityService.navigateToPage('');
        if(communityService.getUserMode() !== 'HCP') communityService.navigateToPage('');
        var spinner = component.find('mainSpinner');
        var steps = [
            $A.get("$Label.c.PG_Ref_Step_Discussion"),
            $A.get("$Label.c.PG_Ref_Step_Site_Selection"),
            $A.get("$Label.c.PG_Ref_Step_Questionnaire"),
            $A.get("$Label.c.PG_Ref_Step_Contact_Info")
        ];
        component.set('v.steps', steps);
        spinner.show();

        communityService.executeAction(component, 'getInitData', {
            trialId: trialId,
            peId: peId,
            userMode: communityService.getUserMode()
        }, function (returnValue) {
            debugger;
            var initData = JSON.parse(returnValue);
            component.set('v.trialId', trialId);
            component.set('v.hadDiscussion', undefined);
            component.set('v.stillInterested', undefined);
            component.set('v.trial', initData.trial);
            component.set('v.pEnrollment', initData.participantEnrollment);
            component.set('v.hcpEnrollment', initData.hcpEnrollment);
            component.set('v.pendingPEnrollments', initData.pendingPEnrollments);
            component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Discussion"));
            component.set('v.studySites', initData.studies);
            component.set('v.showMRRButton', initData.trial.Link_to_Medical_Record_Review__c && initData.trial.Link_to_Pre_screening__c);
            component.set('v.searchResult', undefined);
            component.set('v.mrrResult', 'Pending');
            component.set('v.searchData', {participantId : ''});
            component.set('v.participant', {
                sobjectType: 'Participant__c'
            });
            component.set('v.counries', initData.countries);
            component.set('v.statesByCountyMap', initData.statesByCountryMap);

            if(initData.participantEnrollment) {
                helper.setParticipant(component, initData.participantEnrollment);
                component.set('v.currentState', 'Screening');
            }else{
                component.set('v.currentState', 'Select Source')
            }
            if(!initData.trial.Link_to_Pre_screening__c){
                component.set('v.steps', [$A.get("$Label.c.PG_Ref_Step_Discussion"), $A.get("$Label.c.PG_Ref_Step_Contact_Info")]);
            }
            if(!initData.trial.Link_to_Medical_Record_Review__c && initData.trial.Link_to_Pre_screening__c){
                component.set('v.currentState', 'Search PE');
            }
            component.set('v.actions', initData.actions);
            spinner.hide();
        }, function (errHandler) {
            //communityService.navigateToHome();
            spinner.hide();
        });
    },

    doSelectNewAsCurrentSource: function (component) {
        component.set('v.currentState', 'Screening');
    },

    doStartOver: function (component) {
        component.set('v.currentState', 'Select Source');
        component.set('v.hadDiscussion', undefined);
        component.set('v.stillInterested', undefined);
        component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Discussion"));
    },

    doHadDiscussion: function (component) {
        component.set('v.hadDiscussion', true);
    },

    doNoHadDiscussion: function (component) {
        component.set('v.hadDiscussion', false);
    },

    doStillInterested: function (component) {
        var trial = component.get('v.trial');
        window.scrollTo(0, 0);
        if(trial.Link_to_Pre_screening__c){
            component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Site_Selection"));
        }else{
            component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Contact_Info"));
        }

    },

    doSelectSite: function (component, event, helper) {
        component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Questionnaire"));
        component.find('mainSpinner').show();
        helper.addEventListener(component, helper);
        window.scrollTo(0, 0);

    },

    doGoToMedicalRecordReview: function (component) {
        communityService.navigateToPage('medical-record-review?id=' + component.get('v.trialId'));
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },

    doReferrAnotherPatient: function (component) {
        communityService.navigateToPage('referring?id=' + component.get('v.trialId'));
    },

    doReferSelectedPE: function (component, event, helper) {
        var peId = event.target.id;
        var pendingList = component.get('v.pendingPEnrollments');
        for(var i = 0; i < pendingList.length; i++){
            var pe = pendingList[i];
            if(pe.Id === peId){
                component.set('v.pEnrollment', pe);
                helper.setParticipant(component, pe);
                component.set('v.currentState', 'Screening');
                component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Discussion"));
                window.scrollTo(0, 0);
                return;
            }
        }
    },

    doCheckfields: function (component, event, helper) {
        helper.checkFields(component);
    },

    doSaveParticipant: function (component) {
        var participant = component.get('v.participant');
        var trial = component.get('v.trial');
        var pEnrollment = component.get('v.pEnrollment');
        var spinner = component.find('mainSpinner');
        spinner.show();

        communityService.executeAction(component, 'saveParticipant', {
            trialId: trial.Id,
            pEnrollmentJSON: JSON.stringify(pEnrollment),
            participantJSON: JSON.stringify(participant)
        }, function (returnValue) {
            component.set('v.currentState', 'Refer Success');
        }, null, function () {
            window.scrollTo(0, 0);
            spinner.hide();
        });

    },

    doFrameLoaded: function (component, event, helper) {
        component.find('mainSpinner').hide();
    },

    doStartPreScreening: function (component, event, helper) {
        if(component.get('v.mrrResult') === 'Start Pre-Screening'){
            var searchResult = component.get('v.searchResult');
            component.set('v.pEnrollment', searchResult.pe);
            component.set('v.currentState', 'Screening');
            component.set('v.participant', {
                sobjectType: 'Participant__c',
                First_Name__c: searchResult.pe.Participant_Name__c,
                Last_Name__c: searchResult.pe.Participant_Surname__c
            });

        }
    },

    doNoLongerInterested: function (component, event, helper) {
        helper.doFailedReferral(component, 'No Longer Interested', function () {
            component.set('v.currentState', 'No Longer Interested');
        });
    },

    doHadDiscussionNotInterested: function (component, event, helper) {
        helper.doFailedReferral(component, 'Had Discussion, Not Interested', function () {
            component.set('v.currentState', 'Had Discussion, Not Interested');
        });
    },

    doCountryChange: function (component, event, helper) {
        var statesMapByCountry = component.get('v.statesByCountyMap');
        var participant = component.get('v.participant');
        var emptyStates = true;
        if(participant && participant.Mailing_Country_Code__c){
            var countryCode = participant.Mailing_Country_Code__c;
            var states = statesMapByCountry[countryCode];
            if(!states) states = [];
            emptyStates = states.length === 0;
            component.set('v.states', states);
        }else{
            component.set('v.states', []);
        }
        if(component.get('v.countryInitialized')) component.set('v.participant.Mailing_State_Code__c', null);
        helper.checkFields(component);
    }


})