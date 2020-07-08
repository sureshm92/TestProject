({

  MAX_FILE_SIZE: 2000000, //Max file size 2 MB 2000000 
  CHUNK_SIZE: 2000000,      //Chunk Max size 750Kb 

  next: function (component, event) {
    var showParent = component.get('v.hideParent'),
      parentIsRequired = component.get('v.parentRequired'),
      patientisRequired = component.get('v.patientRequired'),
      positiveCase = component.get('v.positiveCase');
    this.setColor('questionnaireFont');

    if (((showParent === false && showParent != undefined) && (parentIsRequired === false && parentIsRequired != undefined) && (patientisRequired === false && patientisRequired != undefined))) {
      if (positiveCase != undefined && positiveCase === 'false') {
        this.pageNavigate(event, "/thank-you?page_types=underage");
      }
      else {
        this.pageNavigate(event, "/thank-you?page_types=underage");
      }
    } else if (positiveCase != undefined && positiveCase === 'false') {

      if (((showParent === false && showParent != undefined) && (parentIsRequired === false && parentIsRequired != undefined) && (patientisRequired === false && patientisRequired != undefined))) {
        this.pageNavigate(event, "/thank-you?page_types=underage");
      }
      else {
        this.pageNavigate(event, "/thank-you?page_types=underage");
      }

    } else {
      this.moveNext(component, event);
    }

  },

  moveNext: function (component, event) {

    var questionnaire = component.find('questionnaireSection'),
      isQuestionnaireValid = questionnaire.questionnairevalidate(),  // validate the first questionnare section
      currentTab = component.get("v.selTabId"), // get the current selected tab value
      questionnaireOther,
      isQuestionnaireOtherValid,
      contactInfo,
      isContactInfoValid;

    if (currentTab == '1' && isQuestionnaireValid) {
      //this.setTabProperties('2','1', 100);
      component.set("v.selTabId", '2');
      component.set("v.progressLevel1", 100);
    } else if (currentTab == '2') {
      // validate the second questionnare section      
      questionnaireOther = component.find('questionnaireOtherSection');
      isQuestionnaireOtherValid = questionnaireOther.questionnaireOthervalidate();
      if (isQuestionnaireOtherValid) {
        window.scrollTo(0, 0);
        component.set("v.isVisible", false);
        component.set("v.isNextStepVisible", true);
        component.set("v.selTabId", '3');
        component.set("v.progressLevel2", 100);
        this.setColor('contactInfoFont');
      }

    } else if (currentTab == '3') {
      // validate the second contactinfo section
      contactInfo = component.find('contactInfoSection');
      isContactInfoValid = contactInfo.contactInfoValidate();

      if (isContactInfoValid) {
        window.scrollTo(0, 0);
        component.set("v.isSiteVisible", true);
        component.set("v.isNextStepVisible", false);
        component.set("v.selTabId", '4');
        component.set("v.progressLevel3", 100);
      }
    }
  },

  setTabProperties: function (tabId, progressId, progressLevel) {
    component.set("v.selTabId", tabId);
    component.set("v.progressLevel", progressLevel);
  },

  moveSubmit: function (component, event) {
    // validate the second contactinfo section    
    var contactInfo = component.find('contactInfoSection'),
      isContactInfoValid = contactInfo.contactInfoValidate();
    if (isContactInfoValid) {
      this.submit(component, event)
    }
  },

  moveSitemap: function (component) {
    window.scrollTo(0, 0);
    component.set("v.isSiteVisible", true);
    component.set("v.isNextStepVisible", false);
    component.set("v.selTabId", '4');
    component.set("v.progressLevel3", 100);
    this.setColor('siteSelectionFont');
  },

  update: function (component, event) {
    component.set('v.loaded', true);
    var action = component.get('c.updateStudySite'),
      integrationPatientReferrral = component.get("v.integrationPatientReferralObj"),
      email = integrationPatientReferrral.email__c,
      phone = integrationPatientReferrral.phone__c,
      delegateEmail = integrationPatientReferrral.Delegate_Email_Address__c,
      delegatePhone = integrationPatientReferrral.Delegate_Daytime_Phone_Number__c,
      dob = component.get("v.DOB"),
      studySiteNumber = component.get("v.studySitesInstance.Study_Site_Number__c"),
      protocolNumber = $A.get("$Label.c.CPD_Protocol_ID");
    if (studySiteNumber) {
      action.setParams({
        'emailAddress': email,
        'phoneNumber': phone,
        'delegateEmailAddress': delegateEmail,
        'delegatePhoneNumber': delegatePhone,
        'dateOfBirth': dob,
        'siteSelectedId': studySiteNumber,
        'protocolId': protocolNumber
      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === 'SUCCESS') {
          this.pageNavigate(event, "/thank-you?page_types=success");
          component.set('v.loaded', false);
          component.set('v.showError', false);
        } else if (state === 'ERROR') {
          console.log(response.getError('Details')[0]);
        }
      });
      $A.enqueueAction(action);
    } else {
      component.set('v.loaded', false);
      component.set('v.showError', true);
    }
  },

  submit: function (component, event) {
    var integrationPatient = component.get("v.integrationPatientReferralObj"),
      formResult = component.get("v.formResultObj"),
      file = component.get("v.selectedFile");
    this.recordSubmit(component, event);
  },

  recordSubmit: function (component, event) {
    var fileInput = component.get("v.selectedFile"), //component.find("fileData"),
      file,
      self = this;
    file = component.get("v.uploadedFile");
    if (file.size > self.MAX_FILE_SIZE) {
      component.set("v.fileName", 'File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
      return;
    }

    // create a FileReader object 
    var objFileReader = new FileReader();

    // set onload function of FileReader object   
    objFileReader.onload = $A.getCallback(function () {
      var fileContents = objFileReader.result;
      var base64 = 'base64,';
      var dataStart = fileContents.indexOf(base64) + base64.length;
      fileContents = fileContents.substring(dataStart);
      // call the uploadProcess method 
      self.uploadProcess(component, file, fileContents);
    });
    objFileReader.readAsDataURL(file);
  },

  // File uploaded process
  uploadProcess: function (component, file, fileContents) {
    var startPosition = 0;
    var endPosition = Math.max(fileContents.length, startPosition + this.CHUNK_SIZE);
    this.uploadFileInChunk(component, file, fileContents, startPosition, endPosition, '');
  },

  // File chunkc proces
  uploadFileInChunk: function (component, file, fileContents, startPosition, endPosition, attachId) {
    component.set('v.loaded', true);
    var getchunk = fileContents.substring(startPosition, endPosition);
    var fileData = new Object(),
      self = this;
    fileData.fileName = file.name;
    fileData.base64Data = encodeURIComponent(getchunk);
    fileData.contentType = file.type;

    // utm param section 
    self.getQueryForm(component);

    var patientref = component.get("v.integrationPatientReferralObj");
    patientref.ePRPatient_ID_Number = 'NYBC' + Math.floor(Math.random() * 10000) + 1;
    patientref.siteSelected__c = $A.get("$Label.c.CPD_Default_study_site"); //component.get("v.studySitesInstance.Study_Site_Number__c");
    patientref.referralID__c = patientref.siteSelected__c + '_' + patientref.ePRPatient_ID_Number;
    patientref.UTM_campaignSource__c = sessionStorage.getItem('utm_source');
    patientref.UTM_campaignTerm__c = sessionStorage.getItem('utm_term');
    // patientref.Address_State__c = 'New York';
    // patientref.Address_Country__c = 'US';
    patientref.UTM_campaignMedium__c = sessionStorage.getItem('utm_medium');
    patientref.UTM_campaignName__c = sessionStorage.getItem('utm_campaign');
    patientref.UTM_campaignContent__c = sessionStorage.getItem('utm_content');
    // patientref.Delegate_Mailing_State__c = 'New York';
    var positiveCase = component.get('v.positiveCase');
    var formresult = component.get("v.formResultObj");
    formresult.Consent_to_store_info__c = true;
    formresult.Positive_for_COVID_19__c = positiveCase;

    //Set for site location
    /* component.set('v.state', patientref.Address_State__c);
     component.set('v.country', patientref.Address_Country__c);
     component.set('v.zipcode', patientref.Address_ZipCode__c);*/

    var birthDate = component.get("v.DOB");
    var action = component.get("c.enrollPatient");
    action.setParams({
      birthDate: birthDate,
      intPatientReferral: patientref,
      formResult: formresult,
      fileData: JSON.stringify(fileData)
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        window.scrollTo({ top: 10, left: 10, behavior: 'smooth' });
        component.set('v.loaded', false);
        this.moveSitemap(component);
      }
      else if (state === "ERROR") {
        var errors = response.getError();
        component.set('v.loaded', false);
        var errors = action.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            alert(errors[0].message);
          }
        }
      }
      else if (status === "INCOMPLETE") {
        alert('No response from server or client is offline.');
      }
    });
    $A.enqueueAction(action);
  },

  // utm parameters mapping
  getQueryForm: function (component, settings) {
    var patientref = component.get("v.integrationPatientReferralObj"),
      reset = settings && settings.reset ? settings.reset : false,
      self = window.location.toString(),
      querystring = self.split("?");

    if (querystring.length > 1) {
      var pairs = querystring[1].split("&");
      for (var i in pairs) {
        var keyval = pairs[i].split("=");
        if (reset || sessionStorage.getItem(keyval[0]) === null) {
          sessionStorage.setItem(keyval[0], decodeURIComponent(keyval[1]));
        }
      }
    }
  },

  pageNavigate: function (event, pageName) {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": pageName
    });
    urlEvent.fire();
  },

  questionnaireEvent: function (component, event) {
    var positive = event.getParam("positive"),
      DOB = event.getParam("dateOfBirth");
    component.set("v.positiveCase", positive);
    component.set("v.DOB", DOB);
  },

  setColor: function (id) {
    document.getElementById(id).style.color = "#005587";
  },

  // Method name: createDummyAccount()
  // Parametsrs : component, event
  // Descriptions: Creating a dummy account for the map functionalities.
  createDummyAccount: function (component, event) {
    var patientref = component.get("v.integrationPatientReferralObj"),
      action = component.get("c.CreateDummyCovidAccount");
    action.setParams({ intPatientReferral: patientref });
    action.setCallback(this, function (response) {
      this.moveSubmit(component, event);
    });
    $A.enqueueAction(action);
  },

  onclose: function (event) {
    window.onbeforeunload = function (event) {
      var message = 'Important: Please click on \'Save\' button to leave this page.';
      if (typeof event == 'undefined') {
        event = window.event;
      }
      if (event) {
        event.returnValue = message;
      }
      return message;
    };
  }

})