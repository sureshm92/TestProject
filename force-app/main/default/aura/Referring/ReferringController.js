/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        let todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);

        if(!communityService.isDummy()) {
            let trialId = communityService.getUrlParameter("id");
            let peId = communityService.getUrlParameter("peid");
            let hcpeId = communityService.getUrlParameter("hcpeid");
            if (!trialId) communityService.navigateToPage('');
            if (communityService.getUserMode() !== 'HCP') communityService.navigateToPage('');
            let spinner = component.find('mainSpinner');
            let steps = [
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
                hcpeId: hcpeId,
                userMode: communityService.getUserMode(),
                delegateId: communityService.getDelegateId()
            }, function (returnValue) {
                let initData = JSON.parse(returnValue);
                component.set('v.trialId', trialId);
                component.set('v.hcpeId', hcpeId);
                component.set('v.hadDiscussion', undefined);
                component.set('v.stillInterested', undefined);
                component.set('v.trial', initData.trial);
                component.set('v.pEnrollment', initData.participantEnrollment);
                component.set('v.hcpEnrollment', initData.hcpEnrollment);
                component.set('v.pendingPEnrollments', initData.pendingPEnrollments);
                component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Discussion"));
                component.set('v.studySites', initData.studies);
                component.set('v.studySitesPending', initData.studiesPending);
                component.set('v.studySiteMarkers', initData.markers);
                component.set('v.accessUserLevel', initData.delegateAccessLevel);
                component.set('v.showMRRButton', initData.trial.Link_to_Medical_Record_Review__c && initData.trial.Link_to_Pre_screening__c);
                component.set('v.searchResult', undefined);
                component.set('v.mrrResult', 'Pending');
                component.set('v.searchData', {participantId: ''});
                component.set('v.participant', {
                    sobjectType: 'Participant__c'
                });
                component.set('v.genders', initData.genders);
                component.set('v.phoneTypes', initData.phoneTypes);
                component.set('v.counries', initData.countries);
                component.set('v.statesByCountyMap', initData.statesByCountryMap);
                component.set('v.markers', helper.fillMarkers(component));
                if (initData.participantEnrollment) {
                    helper.setParticipant(component, initData.participantEnrollment);
                    if (initData.studies.length > 0) {
                        component.set('v.currentState', 'Screening');
                    } else {
                        component.set('v.currentState', 'No Active Sites');
                    }
                } else {
                    component.set('v.currentState', 'Select Source')
                }
                if (!initData.trial.Link_to_Pre_screening__c) {
                    component.set('v.steps', [$A.get("$Label.c.PG_Ref_Step_Discussion"), $A.get("$Label.c.PG_Ref_Step_Site_Selection"), $A.get("$Label.c.PG_Ref_Step_Contact_Info")]);
                }
                if (!initData.trial.Link_to_Medical_Record_Review__c && initData.trial.Link_to_Pre_screening__c) {
                    component.set('v.currentState', 'Search PE');
                }
                //component.set('v.actions', initData.actions);
                spinner.hide();
            }, function (errHandler) {
                //communityService.navigateToHome();
                spinner.hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doSelectNewAsCurrentSource: function (component, event, helper) {
        helper.checkSites(component);
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

    doStillInterested: function (component,event,helper) {
        let trial = component.get('v.trial');
        let hcpeId = component.get('v.hcpeId');
        window.scrollTo(0, 0);
        if(!hcpeId){
            component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Site_Selection"));
        }
        else if(trial.Link_to_Pre_screening__c){
            helper.addEventListener(component, helper);
            component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Questionnaire"));
        }else{
            component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Contact_Info"));
        }

    },

    doSelectSite: function (component, event, helper) {
        let trial = component.get('v.trial');
        let hcpeId = event.target.dataset.hcpeId;
        component.set('v.hcpeId',hcpeId);
        if(trial.Link_to_Pre_screening__c){
            component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Questionnaire"));
            component.find('mainSpinner').show();
            helper.addEventListener(component, helper);
        }
        else {
            component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Contact_Info"));
        }
        window.scrollTo(0, 0);

    },

    doGoToMedicalRecordReview: function (component) {
        let hcpeId = component.get('v.hcpeId');
        communityService.navigateToPage('medical-record-review?id=' + component.get('v.trialId')+(hcpeId?'&hcpeid='+hcpeId:''));
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },

    doGoFindStudySites : function(component) {
        communityService.navigateToPage('sites-search?id=' + component.get('v.trialId'));
    },

    doReferrAnotherPatient: function (component) {
        let hcpeId = component.get('v.hcpeId');
        communityService.navigateToPage('referring?id=' + component.get('v.trialId')+(hcpeId?'&hcpeid='+hcpeId:''));
    },

    doReferSelectedPE: function (component, event, helper) {
        let peId = event.target.id;
        let pendingList = component.get('v.pendingPEnrollments');
        for(let i = 0; i < pendingList.length; i++){
            let pe = pendingList[i];
            if(pe.Id === peId){
                component.set('v.pEnrollment', pe);
                helper.setParticipant(component, pe);
                helper.checkSites(component);
                component.set('v.currentStep', $A.get("$Label.c.PG_Ref_Step_Discussion"));
                window.scrollTo(0, 0);
                return;
            }
        }
    },

    doCheckfields: function (component, event, helper) {
        helper.checkFields(component,event,helper);
    },

    doCheckDateOfBith: function (component, event, helper) {
        helper.checkParticipantNeedsGuardian(component, helper);
        helper.checkFields(component, event, helper);
    },

    doNeedsGuardian: function (component, event, helper) {
        let participant = component.get('v.participant');
        if (participant.Health_care_proxy_is_needed__c) {
            helper.setDelegate(component);
        } else {
            component.set('v.useThisDelegate', true);
            component.set('v.emailDelegateRepeat', '');
        }
        component.set('v.needsGuardian', participant.Health_care_proxy_is_needed__c);
    },

    doSaveParticipant: function (component) {
        let participant = component.get('v.participant');
        console.log('participant', JSON.parse(JSON.stringify(participant)));
        let delegateParticipant = component.get('v.delegateParticipant');
        console.log('delegateParticipant', JSON.parse(JSON.stringify(delegateParticipant)));

        let trial = component.get('v.trial');
        let hcpeId = component.get('v.hcpeId');
        let pEnrollment = component.get('v.pEnrollment');
        let spinner = component.find('mainSpinner');
        spinner.show();
        communityService.executeAction(component, 'saveParticipant', {
            hcpeId: hcpeId,
            pEnrollmentJSON: JSON.stringify(pEnrollment),
            participantJSON: JSON.stringify(participant),
            participantDelegateJSON: JSON.stringify(delegateParticipant),
            delegateId: communityService.getDelegateId(),
            ddInfo: JSON.stringify(component.get('v.delegateDuplicateInfo'))
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
            let searchResult = component.get('v.searchResult');
            component.set('v.pEnrollment', searchResult.pe);
            helper.checkSites(component);
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
        let statesMapByCountry = component.get('v.statesByCountyMap');
        let participant = component.get('v.participant');
        let emptyStates = true;
        if(participant && participant.Mailing_Country_Code__c){
            let countryCode = participant.Mailing_Country_Code__c;
            let states = statesMapByCountry[countryCode];
            if(!states) states = [];
            emptyStates = states.length === 0;
            if (component.get('v.selectedCountry') != participant.Mailing_Country_Code__c || component.get('v.states').length != states.length) {
                component.set('v.states', states);
            }
            if (states.length == 0) {
                component.set('v. participant.Mailing_Country_Code__c', null);
            }
        }else{
            component.set('v.states', []);
        }

        component.set('v.selectedCountry', participant.Mailing_Country_Code__c);
        helper.checkFields(component, event, helper);
    },

    approveDelegate:function(component, event, helper){
        var ddi = component.get('v.delegateDuplicateInfo');
        var partDel = component.get('v.delegateParticipant');
        if(ddi.contactPhoneType) partDel.Phone_Type__c = ddi.contactPhoneType;
        if(ddi.contactPhoneNumber) partDel.Phone__c = ddi.contactPhoneNumber;
        component.set('v.delegateParticipant', partDel);
        component.find('delegate-phone').focus();
        component.find('delegate-phone').blur();
        component.set('v.useThisDelegate', true);
    },
})