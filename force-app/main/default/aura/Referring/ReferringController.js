/**
 * Created by Leonid Bartenev
 */
 ({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        
        let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        var patientDoesNotExist = communityService.getUrlParameter('patientVeiwRedirection');
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
                    patientDoesNotExist: patientDoesNotExist,
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
                    component.set('v.preScreenerSurvey', initData.preScreenerSurvey);	
                    component.set('v.preMrrSurvey', initData.mrrSurvey);
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
                    let dobFormat = (component.get('v.pEnrollment.Study_Site__r.Participant_DOB_format__c') ? component.get('v.pEnrollment.Study_Site__r.Participant_DOB_format__c') :  component.get('v.hcpEnrollment.Study_Site__r.Participant_DOB_format__c') ? component.get('v.hcpEnrollment.Study_Site__r.Participant_DOB_format__c') : null);
                    component.set('v.studySiteFormat',dobFormat);
                    component.set('v.pyear',null);
                    component.set('v.pmonth',null);
                    component.set('v.pday',null);
                    if(initData.trial.Patient_Auth_Upload_Required__c && component.get('v.contentDoc') != null){
                        component.set('v.fileRequired',false);
                    }
                    component.set(	
                        'v.showMRRButton',	
                        initData.mrrSurvey && initData.mrrSurvey.Link_to_Pre_screening__c &&	
                        initData.preScreenerSurvey && initData.preScreenerSurvey.Link_to_Pre_screening__c	
                    );	
                    component.set('v.mrrExist',  initData.mrrSurvey ? initData.mrrSurvey.Link_to_Pre_screening__c : null);
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
                        component.set('v.pyear',null);
                        component.set('v.pmonth',null);
                        component.set('v.pday',null);
                        if(initData.participantEnrollment.YOB__c) {component.set('v.pyear',initData.participantEnrollment.YOB__c);}
                        if(initData.participantEnrollment.Birth_Month__c && dobFormat!='YYYY') {component.set('v.pmonth',initData.participantEnrollment.Birth_Month__c);}
                        component.dobChangeMethod();
                    } else {
                        component.set('v.currentState', 'Select Source');
                    }
                    if (!initData.preScreenerSurvey || !initData.preScreenerSurvey.Link_to_Pre_screening__c) {
                        if(!component.get('v.patientVeiwRedirection') && communityService.getUrlParameter('navigatetodiscussion')!== 'true'){
                            component.set('v.currentState', 'Search PE');
                          }
                        component.set('v.steps', [
                            $A.get('$Label.c.PG_Ref_Step_Discussion'),
                            $A.get('$Label.c.PG_Ref_Step_Site_Selection'),
                            $A.get('$Label.c.PG_Ref_Step_Contact_Info')
                        ]);
                    }
                    if (	
                        !initData.mrrSurvey &&	
                        (initData.preScreenerSurvey && initData.preScreenerSurvey.Link_to_Pre_screening__c)	
                    ) {
                        //let pvr = communityService.getUrlParameter('patientVeiwRedirection');
                        if(!component.get('v.patientVeiwRedirection')){
                            component.set('v.currentState', 'Search PE');
                        }
                    }
                    //component.set('v.actions', initData.actions);
                        var dayList = [];
                        var obj = {};
                        for (var i = 1; i <= 31; i++) {
                            if(i >= 10){
                                obj.label = ''+i;
                                obj.value = ''+i;
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
                        monthList.push({"value":'01',"label":"January"});
                        monthList.push({"value":'02',"label":"February"});
                        monthList.push({"value":'03',"label":"March"});
                        monthList.push({"value":'04',"label":"April"});
                        monthList.push({"value":'05',"label":"May"});
                        monthList.push({"value":'06',"label":"June"});
                        monthList.push({"value":'07',"label":"July"});
                        monthList.push({"value":'08',"label":"August"});
                        monthList.push({"value":'09',"label":"September"});
                        monthList.push({"value":'10',"label":"October"});
                        monthList.push({"value":'11',"label":"November"});
                        monthList.push({"value":'12',"label":"December"});
                       /*
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
                        }*/
                        component.set('v.months', monthList);
                        var yearNow = $A.localizationService.formatDateTime(new Date(), "YYYY");
                    var oldyear = yearNow - 122;
                        var yearList = [];
                        var obj = {};
                    for (var i = yearNow; i >= oldyear; i--) {
                            obj.label = i;
                            obj.value = i;
                            yearList.push(obj);
                            obj = {};
                        }
                        component.set('v.years', yearList);
                    
                    if(component.get('v.patientVeiwRedirection')){
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
        let preScreenerSurvey = component.get('v.preScreenerSurvey');
        let hcpeId = component.get('v.hcpeId');
        window.scrollTo(0, 0);
        if (!hcpeId) {
            component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Site_Selection'));
        } else if (preScreenerSurvey && preScreenerSurvey.Link_to_Pre_screening__c) {
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
        let preScreenerSurvey = component.get('v.preScreenerSurvey');
        let hcpeId = event.target.dataset.hcpeId;
        let siteId = event.target.dataset.siteId;
        let ssFormat = event.target.dataset.ssFormat;
        component.set('v.siteId', siteId);
        component.set('v.hcpeId', hcpeId);
        component.set('v.studySiteFormat', ssFormat);
        if (preScreenerSurvey && preScreenerSurvey.Link_to_Pre_screening__c) {
            component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Questionnaire'));
            component.find('mainSpinner').show();
            helper.addEventListener(component, helper);
        } else { 
            component.set('v.currentStep', $A.get('$Label.c.PG_Ref_Step_Contact_Info'));
        }
        if(ssFormat=='YYYY') {component.set('v.pmonth',null);}
        component.dobChangeMethod();
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
        if (component.get('v.patientVeiwRedirection')) {
            communityService.navigateToPage('my-patients');
            communityService.reloadPage();
        } else {
             communityService.navigateToPage('');   
        }
    },

    doGoPatientsTab: function (component) {
        communityService.navigateToPage('my-patients');
        communityService.reloadPage();
    },
    
    doGoFindStudySites: function (component) {
        communityService.navigateToPage('sites-search?id=' + component.get('v.trialId'));
    },
    
    doReferrAnotherPatient: function (component, event) {
        let patientVeiwRedirection = communityService.getUrlParameter('patientVeiwRedirection');
        if (component.get('v.patientVeiwRedirection')) {
            communityService.navigateToPage('my-patients');
            communityService.reloadPage();
        } else {
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
                //let dobFormat = (component.get('v.pEnrollment.Study_Site__r.Participant_DOB_format__c') ? component.get('v.pEnrollment.Study_Site__r.Participant_DOB_format__c') :  component.get('v.hcpEnrollment.Study_Site__r.Participant_DOB_format__c') ? component.get('v.hcpEnrollment.Study_Site__r.Participant_DOB_format__c') : null);
                //component.set('v.studySiteFormat',dobFormat);
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
    
    doDayChange: function (component, event, helper) {
        component.set('v.selectedAge','');
        component.set('v.participant.Birth_Day__c',component.get('v.pday'));
        component.set('v.participant.Birth_Month__c',component.get('v.pmonth'));
        component.set('v.participant.Birth_Year__c',component.get('v.pyear'));
        let formatSS = component.get('v.studySiteFormat');
        //component.checkdobMethod();
        if(formatSS == 'DD-MM-YYYY'){helper.doParticipantAge(component);}
        if(formatSS != 'DD-MM-YYYY'){helper.generateAgeOptions(component);}
        component.checkdobMethod();
        if(formatSS != 'YYYY' && formatSS != undefined && formatSS != null){
            helper.validateDOB(component, event, helper);
        }
    },

    doDOBChange: function (component, event, helper) {
        component.set('v.selectedAge','');
        component.set('v.participant.Birth_Day__c',component.get('v.pday'));
        component.set('v.participant.Birth_Month__c',component.get('v.pmonth'));
        component.set('v.participant.Birth_Year__c',component.get('v.pyear'));
        let formatSS = component.get('v.studySiteFormat');
        if(formatSS == 'DD-MM-YYYY'){helper.doMonthPLVChange(component, event, helper);}
        if(formatSS == 'DD-MM-YYYY'){helper.doParticipantAge(component);}
        if(formatSS != 'DD-MM-YYYY'){helper.generateAgeOptions(component);}
        component.checkdobMethod();
        if(formatSS != 'YYYY' && formatSS != undefined && formatSS != null){
            helper.validateDOB(component, event, helper);
        }
        //component.checkdobMethod();
    },
    doAgeChange: function (component, event, helper) {
        component.set('v.participant.Age__c',component.get('v.selectedAge'));
        component.checkdobMethod();
        helper.checkFields(component, event, helper);
    },

    doCheckDateOfBith: function (component, event, helper) {
        helper.doParticipantAge(component);
        var pday = component.get('v.pday');
        var pmonth = component.get('v.pmonth');
        var pyear = component.get('v.pyear');
        let todayDate = new Date();
        let partAge = component.get('v.selectedAge');
        let dobFormat = component.get('v.studySiteFormat');
        if(dobFormat && pyear && 
            (dobFormat == 'YYYY' || (pmonth &&  (dobFormat == 'MM-YYYY' || (dobFormat == 'DD-MM-YYYY'  && pday))) )){
                let higherAge = Number(todayDate.getUTCFullYear())-Number(pyear);
                let endOfMonth = new Date(pyear, pmonth, 0);
                let dd = ((pday) ?   pday : ( higherAge == partAge ? 1 : (dobFormat == 'YYYY' ? 31 : endOfMonth.getDate() ) )  );
                
                let mm = (pmonth) ? pmonth : ( ( higherAge == partAge) ? 1 : 12 );
                component.set('v.participant.Date_of_Birth__c',pyear+'-'+mm+'-'+dd);
                
           helper.checkParticipantNeedsGuardian(component, event, helper);
        }
        //helper.checkFields(component, event, helper); REF-3070
    },
    
    doCheckYearOfBith: function (component, event, helper) {
        helper.checkGuardianAge(component, event, helper);
    },
    
    doNeedsGuardian: function (component, event, helper) {
        //RH-8091 
        if(component.get('v.participant.Adult__c')){
            component.set('v.isConfirmConsentNeeded', true);
        }
        else{
            component.set('v.isConfirmConsentNeeded', false); 
        }
        //RH-8091 
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
                 component.set('v.confirmConsent', false);
              }
        }
        component.set('v.needsGuardian', participant.Health_care_proxy_is_needed__c);
        helper.checkFields(component, event, helper);
        
    },
    handleUploadFinished: function (component, event) {
       
        var cmpTarget1 = component.find("uploadfile");
        $A.util.removeClass(cmpTarget1, "fileBoxwoFile");
        $A.util.addClass(cmpTarget1, "fileBox");
         // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        component.set("v.fileName",uploadedFiles[0].name);
        component.set("v.disableFile",true);
        component.set("v.contentDocId",uploadedFiles[0].documentId);
        component.set('v.fileRequired',true);
        communityService.executeAction(
            component,
            'getContentVersion',
            {
                contDocId: uploadedFiles[0].documentId
            },
            function (returnValue) {
                component.set('v.blobData',returnValue);
                component.set('v.pdfData',returnValue);
            }
        );
    },
    handleDeleteFile:function(component,event){
        //alert('inside delete file');
        let conDocId=component.get("v.contentDocId");
        let spinner = component.find('mainSpinner');
        spinner.show();
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
                var cmpTarget1 = component.find("uploadfile");
                $A.util.addClass(cmpTarget1, "fileBoxwoFile");
                $A.util.removeClass(cmpTarget1, "fileBox");
                spinner.hide();
            }
        );
    },
   
    doReferPatient: function (component) {
        communityService.navigateToPage(
            'referring?id=' +
                component.get('v.trialId') +
                '&peid=' +
                component.get('v.searchResult').pe.Id  
                +
                '&navigatetodiscussion=true'  
        );
    }, 
   
    doSaveParticipant: function (component) {
        if(component.get('v.studySiteFormat') == 'YYYY'){
            component.set('v.participant.Birth_Month__c','');
        }
        let participant = component.get('v.participant');
        console.log('part-->'+JSON.stringify(participant));
        let delegateParticipant = component.get('v.delegateParticipant');
        console.log('delegateParticipant-->'+JSON.stringify(delegateParticipant));
        let trial = component.get('v.trial');
        let hcpeId = component.get('v.hcpeId');
        let pEnrollment = component.get('v.pEnrollment');
        let contentDocId=component.get("v.contentDocId");
        let spinner = component.find('mainSpinner');
        var dupPart = '';
        if (!$A.util.isUndefinedOrNull(JSON.stringify(pEnrollment.HCP__r))) {
            pEnrollment.HCP__r.Study__c="";
        }
        var delID = communityService.getDelegateId();
        spinner.show();
        let action = component.get("c.saveParticipantV2");
        action.setParams({
                hcpeId: hcpeId,
                pEnrollmentJSON: JSON.stringify(pEnrollment),
                participantJSON: JSON.stringify(participant),
                participantDelegateJSON: JSON.stringify(delegateParticipant),
                delegateId: delID,
                ddInfo: JSON.stringify(component.get('v.delegateDuplicateInfo')),
                contentDocId:contentDocId
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                participant.Id = response.getReturnValue()[0];
                dupPart = response.getReturnValue()[1];
                var surveyResponse =component.get('v.preScreenerResponse');
                var action2 = component.get("c.saveParticipantEnrollment");
                action2.setParams({
                    hcpeId: hcpeId,
                    pEnrollmentJSON: JSON.stringify(pEnrollment),
                    participantJSON: JSON.stringify(participant),
                    participantDelegateJSON: JSON.stringify(delegateParticipant),
                    preScreenerResponseJSON: JSON.stringify(surveyResponse),
                    delegateId: delID,
                    ddInfo: JSON.stringify(component.get('v.delegateDuplicateInfo')),
                    contentDocId:contentDocId
        		});
                action2.setCallback(this, function(response){ 
                    var state = response.getState();
                    if (state === "SUCCESS") { 
                        if(response.getReturnValue()!=null){
                            participant.Id = null;
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'dismissible',
                                message: response.getReturnValue(),
                                type : 'error'
                            });
                            toastEvent.fire();
                        }
                        else{
                            if(dupPart!='no duplicate'){
                                var action3 = component.get("c.updateParticipant");
                                action3.setParams({
                                    participantJSON : dupPart
                                });
                                action3.setCallback(this, function(response){
                                });
                                $A.enqueueAction(action3); 
                            }
                            component.set('v.currentState', 'Refer Success');
                        }
                       spinner.hide();
                    }
                    else {
                        console.log("Error in operation");
                    }
                });
                $A.enqueueAction(action2); 
            }	
            else {
                console.log(action.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    doFrameLoaded: function (component, event, helper) {
        component.find('mainSpinner').hide();
    },
    
    doStartPreScreening: function (component, event, helper) {
        if (component.get('v.mrrResult') === 'Start Pre-Screening') {
            let searchResult = component.get('v.searchResult');
            component.set('v.pEnrollment', searchResult.pe);
            let dobFormat = (component.get('v.pEnrollment.Study_Site__r.Participant_DOB_format__c') ? component.get('v.pEnrollment.Study_Site__r.Participant_DOB_format__c') :  component.get('v.hcpEnrollment.Study_Site__r.Participant_DOB_format__c') ? component.get('v.hcpEnrollment.Study_Site__r.Participant_DOB_format__c') : null);
            component.set('v.studySiteFormat',dobFormat);
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
        if(participant != undefined && participant.Mailing_Country_Code__c !=undefined && participant.Mailing_Country_Code__c != null && 
           participant.Mailing_Country_Code__c != ''){
           component.set('v.mailingCountryCode', participant.Mailing_Country_Code__c);
        }
		component.set('v. participant.Mailing_State_Code__c', null);
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
        component.set('v.attestAge', true);
        if( component.get('v.participant.Adult__c')){
            component.set('v.isConfirmConsentNeeded', true);
        }
        else{
            component.set('v.isConfirmConsentNeeded', false); 
        }
        component.set('v.confirmConsent',false);
        //use duplicate,Refer now re-calculation
        helper.checkFields(component, event, helper);
    },
    
    openModel : function(component, event, helper){ 
        component.set('v.openmodel',true);
    },
    closeModal:function(component,event,helper){    
        component.set('v.openmodel',false);
    },
    handleConsentUpdate : function(component, event, helper) {
        if(event.getParam('consentMap') != null && event.getParam('consentMap') != undefined && event.getParam('consentMap') != ''){
            if(event.getParam('consentMap').cType == 'study'){
                component.set('v.pEnrollment.Permit_SMS_Text_for_this_study__c', event.getParam('consentMap').pe.Permit_SMS_Text_for_this_study__c);
                component.set('v.pEnrollment.Permit_Voice_Text_contact_for_this_study__c', event.getParam('consentMap').pe.Permit_Voice_Text_contact_for_this_study__c);
                component.set('v.pEnrollment.Permit_Mail_Email_contact_for_this_study__c', event.getParam('consentMap').pe.Permit_Mail_Email_contact_for_this_study__c);
                component.set('v.pEnrollment.Delegate_Consent__c', event.getParam('consentMap').pe.Delegate_Consent__c);
                component.set('v.pEnrollment.Delegate_SMS_Consent__c', event.getParam('consentMap').pe.Delegate_SMS_Consent__c);
             }
            else{
                component.set('v.pEnrollment.Participant_Opt_In_Status_Emails__c', event.getParam('consentMap').contact.Participant_Opt_In_Status_Emails__c);
                component.set('v.pEnrollment.Participant_Opt_In_Status_SMS__c', event.getParam('consentMap').contact.Participant_Opt_In_Status_SMS__c);
                component.set('v.pEnrollment.Participant_Phone_Opt_In_Permit_Phone__c', event.getParam('consentMap').contact.Participant_Phone_Opt_In_Permit_Phone__c); 
                component.set('v.pEnrollment.IQVIA_Direct_Mail_Consent__c', event.getParam('consentMap').contact.IQVIA_Direct_Mail_Consent__c); 
            }
                helper.checkFields(component, event, helper);

        }                                      
    },
    doStartMRR: function (component) {
        communityService.navigateToPage('medical-record-review?id=' + component.get('v.trialId'));
    },
    doClearForm: function (component) {
        component.set('v.searchResult', undefined);
        component.set('v.searchData', {
            participantId: ''
        });
        component.set('v.mrrResult', 'Pending');
    },
    loadpdf : function(component, event, helper) { 
        var pdfjsframe = component.find('pdfFrame');
        var idParamValue = component.get('v.pdfData');
        var resId = helper.getURLParameterValue().resId;
        var lang = helper.getURLParameterValue().lang;
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const updates = urlParams.get('updates');
        if (updates) {
            var button = component.find('button');
            $A.util.addClass(button, 'button-hide');
        }
        if (typeof idParamValue !== 'undefined') {
            component.set('v.hideDivResource', 'slds-hide');
            component.set('v.isResourceVisible', 'true');
            var ss = idParamValue.split(' ').join('+');
            window.setTimeout(
                $A.getCallback(function () { 
                    component.set('v.pdfData', ss);
                    helper.loadpdf(component, event);
                }),
                500
            );
        }
	}
});