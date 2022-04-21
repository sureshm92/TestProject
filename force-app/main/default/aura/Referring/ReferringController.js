/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        
        let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        if(patientVeiwRedirection){
            component.set('v.patientVeiwRedirection',true); 
        }
        let mystudies = communityService.getUrlParameter('mystudies');
        if(mystudies == undefined){
            component.set('v.myStudies', false);
        }else{
            component.set('v.myStudies', true); 
        }
        
        let todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        if (!communityService.isDummy()) {
            let trialId = communityService.getUrlParameter('id');
            let peId = communityService.getUrlParameter('peid');
            let hcpeId = communityService.getUrlParameter('hcpeid');
            let siteId = communityService.getUrlParameter('siteid');
            let language = communityService.getLanguage();
            if (!trialId) communityService.navigateToPage('');
            if (communityService.getUserMode() !== 'HCP') communityService.navigateToPage('');
            let spinner = component.find('mainSpinner');
            let steps = [
                $A.get('$Label.c.PG_Ref_Step_Discussion'),
                $A.get('$Label.c.PG_Ref_Step_Site_Selection'),
                $A.get('$Label.c.PG_Ref_Step_Questionnaire'),
                $A.get('$Label.c.PG_Ref_Step_Contact_Info')
            ];
            component.set('v.steps', steps);
            spinner.show();
            
            communityService.executeAction(
                component,
                'getInitData',
                {
                    trialId: trialId,
                    peId: peId,
                    hcpeId: hcpeId,
                    userMode: communityService.getUserMode(),
                    delegateId: communityService.getDelegateId(),
                    language: language
                },
                function (returnValue) {
                    let initData = JSON.parse(returnValue);
                    component.set('v.trialId', trialId);
                    component.set('v.hcpeId', hcpeId);
                    component.set('v.hadDiscussion', undefined);
                    component.set('v.stillInterested', undefined);
                    component.set('v.trial', initData.trial);
                    component.set('v.pEnrollment', initData.participantEnrollment);
                    component.set('v.hcpEnrollment', initData.hcpEnrollment);
                    component.set('v.pendingPEnrollments', initData.pendingPEnrollments);
                    component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Discussion'));
                    component.set('v.studySites', initData.studies);
                    component.set('v.studySitesPending', initData.studiesPending);
                    component.set('v.studySiteMarkers', initData.markers);
                    component.set('v.accessUserLevel', initData.delegateAccessLevel);
                    component.set('v.authRequired',initData.trial.Patient_Auth_Upload_Required__c);
                    component.set('v.contentDoc',JSON.parse(initData.contentDoc));
                    if(initData.trial.Patient_Auth_Upload_Required__c && component.get('v.contentDoc') != null){
                        component.set('v.fileRequired',false);
                    }
                    component.set(
                        'v.showMRRButton',
                        initData.trial.Link_to_Medical_Record_Review__c &&
                        initData.trial.Link_to_Pre_screening__c
                    );
                    component.set('v.mrrExist',  initData.trial.Link_to_Medical_Record_Review__c);
                    if(component.get('v.mrrExist') == undefined){
                         //component.set('v.patientVeiwRedirection',true);
                    }
                    component.set('v.searchResult', undefined);
                    component.set('v.mrrResult', 'Pending');
                    component.set('v.searchData', { participantId: '' });
                    component.set('v.participant', {
                        sobjectType: 'Participant__c'
                    });
                    component.set('v.enableGuardian', false);
                    component.set('v.genders', initData.genders);
                    component.set('v.phoneTypes', initData.phoneTypes);
                    component.set('v.yob', initData.yearOfBirth);
                    component.set('v.counries', initData.countries);
                    component.set('v.statesByCountyMap', initData.statesByCountryMap);
                    component.set('v.markers', helper.fillMarkers(component));
                    if (initData.participantEnrollment) {
                        helper.setParticipant(component, initData.participantEnrollment, siteId);
                        if (initData.studies.length > 0) {
                            component.set('v.currentState', 'Screening');
                        } else {
                            component.set('v.currentState', 'No Active Sites');
                        }
                    } else {
                        component.set('v.currentState', 'Select Source');
                    }
                    if (!initData.trial.Link_to_Pre_screening__c) {
                        if(!component.get('v.patientVeiwRedirection')){
                            component.set('v.currentState', 'Search PE');
                          }
                        component.set('v.steps', [
                            $A.get('$Label.c.PG_Ref_Step_Discussion'),
                            $A.get('$Label.c.PG_Ref_Step_Site_Selection'),
                            $A.get('$Label.c.PG_Ref_Step_Contact_Info')
                        ]);
                    }
                    if (
                        !initData.trial.Link_to_Medical_Record_Review__c &&
                        initData.trial.Link_to_Pre_screening__c
                    ) {
                        //let pvr = communityService.getUrlParameter('patientVeiwRedirection');
                        if(!component.get('v.patientVeiwRedirection')){
                            component.set('v.currentState', 'Search PE');
                        }
                    }
                    //component.set('v.actions', initData.actions);
                    if(component.get('v.patientVeiwRedirection')){
                        var dayList = [];
                        var obj = {};
                        for (var i = 1; i <= 31; i++) {
                            if(i >= 10){
                                obj.label = i;
                                obj.value = i;
                            }else{
                                obj.label = '0'+i;
                                obj.value = '0'+i;
                            }
                            dayList.push(obj);
                            obj = {};
                        }
                        component.set('v.days', dayList);
                        var monthList = [];
                        var obj = {};
                        for (var i = 1; i <= 12; i++) {
                            if(i >= 10){
                                obj.label = i;
                                obj.value = i;
                            }else{
                                obj.label = '0'+i;
                                obj.value = '0'+i;
                            }
                            monthList.push(obj);
                            obj = {};
                        }
                        component.set('v.months', monthList);
                        var yearNow = $A.localizationService.formatDateTime(new Date(), "YYYY");
                        var oldyear = yearNow - 121;
                        var yearList = [];
                        var obj = {};
                        for (var i = oldyear; i <= yearNow; i++) {
                            obj.label = i;
                            obj.value = i;
                            yearList.push(obj);
                            obj = {};
                        }
                        component.set('v.years', yearList);
                        component.set('v.pday',null);
                        var penrollment = component.get('v.pEnrollment');
                        //let participant = component.get('v.participant');
                        if(component.get('v.primaryDelegateFirstname') != null){
                            component.set('v.participant.Health_care_proxy_is_needed__c',true);
                            //component.set('v.needsGuardian', true);
                            //component.set('v.enableGuardian', true);
                            component.set('v.delegateExist',true);
                            console.log('DelegateExist');
                        }
                        component.checkdoneeedgaurdian();
                    }
                    spinner.hide();
                },
                function (errHandler) {
                    //communityService.navigateToHome();
                    spinner.hide();
                }
            );
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
        component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Discussion'));
    },
    
    doHadDiscussion: function (component) {
        component.set('v.hadDiscussion', true);
    },
    
    doNoHadDiscussion: function (component) {
        component.set('v.hadDiscussion', false);
    },
    doStillInterested: function (component) {
        component.set('v.hadDiscussionDocumented', true);
    },
    doDiscussionDocumented: function (component, event, helper) {
        if(component.get('v.authRequired') && component.get('v.contentDoc') != null){
            component.set('v.authorizationForm',true);
            component.set('v.discussiondocumented',true);
        }
        else{
            component.set('v.doNext',true);
            component.set('v.discussiondocumented',true);
        }
    },
    
    doNext : function (component, event, helper) {
        let trial = component.get('v.trial');
        let hcpeId = component.get('v.hcpeId');
        window.scrollTo(0, 0);
        if (!hcpeId) {
            component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Site_Selection'));
        } else if (trial.Link_to_Pre_screening__c) {
            helper.addEventListener(component, helper);
            component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Questionnaire'));
        } else {
            component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Contact_Info'));
            let frmpatientVeiw = communityService.getUrlParameter('patientVeiwRedirection');
            if(component.get('v.patientVeiwRedirection')){
                helper.checkGuardianAge(component, event, helper);
            }
        } 
        if(component.get('v.mrrExist') != undefined){
            var peID = communityService.getUrlParameter('peid');
            if(peID == undefined){
                peID = component.get('v.PeID');
            }
            communityService.executeAction(
                component,
                'saveUpdatedPER',
                { peID:peID},
                function (returnValue) {
                    console.log('recordUpdated');
                }
            );
        }
        
    },
    doSelectSite: function (component, event, helper) {
        let trial = component.get('v.trial');
        let hcpeId = event.target.dataset.hcpeId;
        let siteId = event.target.dataset.siteId;
        component.set('v.siteId', siteId);
        component.set('v.hcpeId', hcpeId);
        if (trial.Link_to_Pre_screening__c) {
            component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Questionnaire'));
            component.find('mainSpinner').show();
            helper.addEventListener(component, helper);
        } else { 
            component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Contact_Info'));
        }
        window.scrollTo(0, 0);
    },
    
    doGoToMedicalRecordReview: function (component) {
        let hcpeId = component.get('v.hcpeId');
        let siteId = component.get('v.siteId');
        communityService.navigateToPage(
            'medical-record-review?id=' +
            component.get('v.trialId') +
            (hcpeId ? '&hcpeid=' + hcpeId : '') +
            (siteId ? '&siteid=' + siteId : '')
        );
    },
    
    doGoHome: function (component) {
        if(component.get('v.patientVeiwRedirection')){
            communityService.navigateToPage('my-patients');
            window.location.reload();
        }else{
             communityService.navigateToPage('');   
        }
    },
    
    doGoFindStudySites: function (component) {
        communityService.navigateToPage('sites-search?id=' + component.get('v.trialId'));
    },
    
    doReferrAnotherPatient: function (component,event) {
        let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        if(component.get('v.patientVeiwRedirection')){ 
            
            communityService.navigateToPage('my-patients');
            window.location.reload();
        }else{
            let hcpeId = component.get('v.hcpeId');
            communityService.navigateToPage(
                'referring?id=' + component.get('v.trialId') + (hcpeId ? '&hcpeid=' + hcpeId : '')
            );
        }
    },
    
    doReferSelectedPE: function (component, event, helper) {
        let peId = event.target.id;
        component.set('v.PeID',peId);
        let pendingList = component.get('v.pendingPEnrollments');
        let trialId = communityService.getUrlParameter('id');
        for (let i = 0; i < pendingList.length; i++) {
            let pe = pendingList[i];
            if (pe.Id === peId) {
                component.set('v.pEnrollment', pe);
                helper.setParticipant(component, pe);
                helper.checkSites(component);
                component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Discussion'));
                window.scrollTo(0, 0);
                return;
            }
        }
    },
    
    doCheckfields: function (component, event, helper) {
        helper.checkFields(component, event, helper);
    },
    
    doCheckParticipantDob: function (component, event, helper) {
        var pday = component.get('v.pday');
        var pmonth = component.get('v.pmonth');
        var pyear = component.get('v.pyear');
        if((pday && pmonth && pyear) != null){
            console.log('notnull==>'+pyear+'-'+pmonth+'-'+pday);
            var dt = pyear+'-'+pmonth+'-'+pday;
            component.set('v.participant.Date_of_Birth__c',dt);
            component.checkdobMethod();
        }
    },
    
    doCheckDateOfBith: function (component, event, helper) {
        console.log('dob'+component.get('v.participant.Date_of_Birth__c'));
        var pday = component.get('v.pday');
        var pmonth = component.get('v.pmonth');
        var pyear = component.get('v.pyear');
        if(component.get('v.patientVeiwRedirection')){
            if((pday && pmonth && pyear) != null){
               helper.checkParticipantNeedsGuardian(component, event, helper);
            }
        }else{
           helper.checkParticipantNeedsGuardian(component, event, helper);
        }
        //helper.checkFields(component, event, helper); REF-3070
 
    },
    
    doCheckYearOfBith: function (component, event, helper) {
        helper.checkGuardianAge(component, event, helper);
    },
    
    doNeedsGuardian: function (component, event, helper) {
        let participant = component.get('v.participant');
        if (participant.Health_care_proxy_is_needed__c) {
            helper.setDelegate(component, participant);
             if(component.get('v.patientVeiwRedirection')){
                    component.set('v.hasGaurdian', true);
              }
        } else {
            component.set('v.useThisDelegate', true);
            component.set('v.emailDelegateRepeat', '');
             if(component.get('v.patientVeiwRedirection')){
                 var delegateParticipant = {
                     sobjectType: 'Participant__c',
                     First_Name__c:'',
                     Last_Name__c:'',
                     Email__c:'',
                     Phone__c:'',
                     Phone_Type__c:'',
                     Birth_Year__c:''
                 };
                 component.set('v.delegateParticipant', delegateParticipant);
                 component.set('v.primaryDelegateYob', '');
                 component.set('v.attestAge', false);
                 component.set('v.delegateValueRemoved',true);
                 component.set('v.hasGaurdian', false);
              }
        }
        component.set('v.needsGuardian', participant.Health_care_proxy_is_needed__c);
        helper.checkFields(component, event, helper);
        
    },
    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        component.set("v.fileName",uploadedFiles[0].name);
        component.set("v.disableFile",true);
        component.set("v.contentDocId",uploadedFiles[0].documentId);
        component.set('v.fileRequired',true);
    },
    handleDeleteFile:function(component,event){
        //alert('inside delete file');
        let conDocId=component.get("v.contentDocId");
        //alert('conDocId-'+conDocId);
        communityService.executeAction(
            component,
            'deleteFile',
            {
                contentDocId: conDocId
            },
            function () {
                component.set("v.fileName",'');
                component.set("v.disableFile",false);
                component.set('v.fileRequired',false);
            }
        );
    },
    doSaveParticipant: function (component) {
        let participant = component.get('v.participant');
        console.log('part-->'+JSON.stringify(participant));
        let delegateParticipant = component.get('v.delegateParticipant');
        console.log('delegateParticipant-->'+JSON.stringify(delegateParticipant));
        let trial = component.get('v.trial');
        let hcpeId = component.get('v.hcpeId');
        let pEnrollment = component.get('v.pEnrollment');
        let contentDocId=component.get("v.contentDocId");
        let spinner = component.find('mainSpinner');
        if (!$A.util.isUndefinedOrNull(JSON.stringify(pEnrollment.HCP__r))) {
            pEnrollment.HCP__r.Study__c="";
        }
        spinner.show();
        communityService.executeAction(
            component,
            'saveParticipant',
            {
                hcpeId: hcpeId,
                pEnrollmentJSON: JSON.stringify(pEnrollment),
                participantJSON: JSON.stringify(participant),
                participantDelegateJSON: JSON.stringify(delegateParticipant),
                delegateId: communityService.getDelegateId(),
                ddInfo: JSON.stringify(component.get('v.delegateDuplicateInfo')),
                contentDocId:contentDocId
            },
            function (returnValue) {
                component.set('v.currentState', 'Refer Success');
            },
            null,
            function () {
                window.scrollTo(0, 0);
                spinner.hide();
            }
        );
    },
    
    doFrameLoaded: function (component, event, helper) {
        component.find('mainSpinner').hide();
    },
    
    doStartPreScreening: function (component, event, helper) {
        if (component.get('v.mrrResult') === 'Start Pre-Screening') {
            let searchResult = component.get('v.searchResult');
            component.set('v.pEnrollment', searchResult.pe);
            helper.checkSites(component);
            component.set('v.participant', {
                sobjectType: 'Participant__c',
                First_Name__c: searchResult.pe.Participant_Name__c,
                Last_Name__c: searchResult.pe.Participant_Surname__c,
                Site__c: component.get('v.siteId')
            });
        }
    },
    
    doNoLongerInterested: function (component, event, helper) {
        helper.doFailedReferral(component, 'No Longer Interested', function () {
            let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
            if(component.get('v.patientVeiwRedirection')){ 
                communityService.navigateToPage('my-patients');
            }else{
                component.set('v.currentState', 'No Longer Interested');
            }
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
        if (participant && participant.Mailing_Country_Code__c) {
            let countryCode = participant.Mailing_Country_Code__c;
            let states = statesMapByCountry[countryCode];
            if (!states) states = [];
            emptyStates = states.length === 0;
            if (
                component.get('v.selectedCountry') != participant.Mailing_Country_Code__c ||
                component.get('v.states').length != states.length
            ) {
                component.set('v.states', states);
            }
            if (states.length == 0) {
                component.set('v. participant.Mailing_Country_Code__c', null);
            }
        } else {
            component.set('v.states', []);
        }
        component.set('v.selectedCountry', participant.Mailing_Country_Code__c);
        //Added by Raviteja 
        if(participant.Mailing_Country_Code__c != null && participant.Mailing_Country_Code__c !=undefined &&
           participant.Mailing_Country_Code__c != ''){
           component.set('v.mailingCountryCode', participant.Mailing_Country_Code__c);
        }
        //End
        helper.checkFields(component, event, helper);
    },
    
    approveDelegate: function (component, event, helper) {
        var ddi = component.get('v.delegateDuplicateInfo');
        var partDel = component.get('v.delegateParticipant');
        if (ddi.contactPhoneType) partDel.Phone_Type__c = ddi.contactPhoneType;
        if (ddi.contactPhoneNumber) partDel.Phone__c = ddi.contactPhoneNumber;
        component.set('v.delegateParticipant', partDel);
        component.find('delegate-phone').focus();
        component.find('delegate-phone').blur();
        component.set('v.useThisDelegate', true);
        component.set('v.isNewPrimaryDelegate',false);
    },
    
    openModel : function(component, event, helper){ 
        component.set('v.openmodel',true);
    },
    closeModal:function(component,event,helper){    
        component.set('v.openmodel',false);
    },
    handleConsentUpdate : function(component, event, helper) {
        if(event.getParam('consentMap') != null && event.getParam('consentMap') != undefined && event.getParam('consentMap') != ''){
            console.log('===========>contact'+JSON.stringify(event.getParam('consentMap').contact));
                component.set('v.pEnrollment.Participant_Opt_In_Status_Emails__c', event.getParam('consentMap').contact.Participant_Opt_In_Status_Emails__c);
                component.set('v.pEnrollment.Participant_Opt_In_Status_SMS__c', event.getParam('consentMap').contact.Participant_Opt_In_Status_SMS__c);
                component.set('v.pEnrollment.Participant_Phone_Opt_In_Permit_Phone__c', event.getParam('consentMap').contact.Participant_Phone_Opt_In_Permit_Phone__c); 
                component.set('v.agreePolicy',false);
                component.set('v.pEnrollment.Permit_SMS_Text_for_this_study__c', event.getParam('consentMap').pe.Permit_SMS_Text_for_this_study__c);
                component.set('v.pEnrollment.Permit_Voice_Text_contact_for_this_study__c', event.getParam('consentMap').pe.Permit_Voice_Text_contact_for_this_study__c);
                component.set('v.pEnrollment.Permit_Mail_Email_contact_for_this_study__c', event.getParam('consentMap').pe.Permit_Mail_Email_contact_for_this_study__c);
            
            if( ((component.get('v.participant').Mailing_Country_Code__c == 'US' && event.getParam('consentMap').pe.Permit_SMS_Text_for_this_study__c) || 
                 component.get('v.participant').Mailing_Country_Code__c != 'US' ) && 
               event.getParam('consentMap').pe.Permit_Voice_Text_contact_for_this_study__c && 
               event.getParam('consentMap').pe.Permit_Mail_Email_contact_for_this_study__c 
              ){
              component.set('v.agreePolicy',true);   
            }
            helper.checkFields(component, event, helper);

        }                                          
    }
});