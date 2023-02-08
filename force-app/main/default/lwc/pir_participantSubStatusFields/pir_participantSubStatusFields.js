import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecievedHistory from "@salesforce/apex/PIR_StatusDetailController.getRecievedHistory";
import getContactHistory from "@salesforce/apex/PIR_StatusDetailController.getContactHistory";
import getInitialVisitHistory from "@salesforce/apex/PIR_StatusDetailController.getInitialVisitHistory";
import getEligibilityHistory from "@salesforce/apex/PIR_StatusDetailController.getEligibilityHistory";
import getScreeningHistory from "@salesforce/apex/PIR_StatusDetailController.getScreeningHistory";
import getEnrollmentHistory from "@salesforce/apex/PIR_StatusDetailController.getEnrollmentHistory";
import doSaveStatusDetails from "@salesforce/apex/PIR_StatusDetailController.doSaveStatusDetails";
import isSuccessfullyReEngaged from "@salesforce/apex/PIR_StatusDetailController.isSuccessfullyReEngaged";
import FD_PE_Field_Initial_Visit_Attended_Validation from '@salesforce/label/c.FD_PE_Field_Initial_Visit_Attended_Validation';
import FG_PE_Inf_Consent_Validation from '@salesforce/label/c.FG_PE_Inf_Consent_Validation';
import PWS_Withdrew_Conscent_Disclaimer from '@salesforce/label/c.PWS_Withdrew_Conscent_Disclaimer';
import PWS_Declined_Conscent_Disclaimer from '@salesforce/label/c.PWS_Declined_Conscent_Disclaimer';
import Task_Type_Not_Selected from '@salesforce/label/c.Task_Type_Not_Selected';
import PG_RP_L_Not_selected from '@salesforce/label/c.PG_RP_L_Not_selected';
import PG_AC_Select from '@salesforce/label/c.PG_AC_Select';
import PIR_Initial_Visit_Validation from '@salesforce/label/c.PIR_Initial_Visit_Validation';
import PIR_Initial_Visit_Signed_Date_Validation from '@salesforce/label/c.PIR_Initial_Visit_Signed_Date_Validation';
import PIR_Signed_Date_Validation from '@salesforce/label/c.PIR_Signed_Date_Validation';
import RH_RP_Record_Saved_Successfully from '@salesforce/label/c.PIR_Record_Save';
import BTN_Yes from '@salesforce/label/c.BTN_Yes';
import BTN_No from '@salesforce/label/c.BTN_No';
import RH_TV_InitialVisitPopUpMessage from '@salesforce/label/c.RH_TV_InitialVisitPopUpMessage';
import PWS_Contact_Outcome_Placeholder from '@salesforce/label/c.PWS_Contact_Outcome_Placeholder';
import getTelevisitVisibility from "@salesforce/apex/TelevisitCreationScreenController.televisistPrerequisiteCheck";
import PIR_Reason_Required from '@salesforce/label/c.PIR_Reason_Required';
import Gender_Female from '@salesforce/label/c.Gender_Female';
import Gender_Male from '@salesforce/label/c.Gender_Male';
import PE_Sex_At_Birth from '@salesforce/label/c.PIR_Gender';
import { label } from "c/pir_label";
import TIME_ZONE from '@salesforce/i18n/timeZone';
import DOB_outcome_error from '@salesforce/label/c.DOB_outcome_error';
import RH_Pir_Confirm_Televisit from '@salesforce/label/c.RH_Pir_Confirm_Televisit';
import RH_TV_Confirm from '@salesforce/label/c.RH_TV_Confirm';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import Log_in_and_sign from '@salesforce/label/c.Log_in_and_sign';
import RH_Pir_Add_Televisit from '@salesforce/label/c.RH_Pir_Add_Televisit';
import { NavigationMixin } from "lightning/navigation";
import RH_Pir_Add_Televisit_ForScreeningVisit from '@salesforce/label/c.RH_Pir_Add_Televisit_ForScreeningVisit';
export default class Pir_participantSubStatusFields extends NavigationMixin(LightningElement) {
  @api index = "";
  @api outcomeToReasonMap = {};
  @api visitplanoptions = {};
  @api outcomeValues = {};
  @api groupStatus = "Received";
  @api currentitems;
  @api peid = "";
  @api historyResults = [];
  @track utilLabels = label;
  @api historyNull = false;
  @api groupname = "";
  @api isinitialvisit = false;
  @api grpicons = "";
  @api isinitialvisitpresent = false;
  @api pe_record;
  @api scduledtime;
  selectedOutcome = "";
  selectedOutcomeIV = "";
  @track selectedvisitplan;
  selectedreason = "";
  selectedreasonIV = "";
  revisitDateReq = false;
  isScreeningReq = false;
  isWithdrew = false;
  @api initialvisitsctime = "";
  @api isfinalconsentrequired = false;
  @api isvprequired = false;
  @api selectedPlan = "";
  @api isModalOpen = false;
  @api isfovNull = false;
  @api reVisitDt = "";
  @api plan = "";
  @api currentuserdate = "";
  @api latestStatusGrp = '';
  @api isrtl = false;
  @api addTelevisitForInitialVisit = false;
  @track disableTelevisitCheckbox = true;
  @track disableTelevisitCheckbox2 = true;
  @track disableInitialVisitCheckbox = true;
  @track televisitInitialVisitCheckboxStatus = 'Disabled';
  @track isTelevisitModalOpen = false;
  @track proceedSaveRecord = false;
  @api getreengaged = false;
  redirecturl=''; @api e_consentConfigured=false;
  eConsentRedirect = false;
  maindivcls;
  label = {
    FD_PE_Field_Initial_Visit_Attended_Validation,
    FG_PE_Inf_Consent_Validation,
    PWS_Withdrew_Conscent_Disclaimer,
    PWS_Declined_Conscent_Disclaimer,
    Task_Type_Not_Selected,
    PG_AC_Select,
    PIR_Initial_Visit_Validation,
    PIR_Initial_Visit_Signed_Date_Validation,
    PIR_Signed_Date_Validation,
    RH_RP_Record_Saved_Successfully,
    BTN_No,
    BTN_Yes,
    PWS_Contact_Outcome_Placeholder,
    PG_RP_L_Not_selected,
    RH_TV_InitialVisitPopUpMessage,
    PIR_Reason_Required,
    PE_Sex_At_Birth,
    DOB_outcome_error,
    RH_Pir_Confirm_Televisit,
    RH_TV_Confirm,
    BTN_Cancel,
    RH_Pir_Add_Televisit,
    Log_in_and_sign,
    RH_Pir_Add_Televisit_ForScreeningVisit
  };
  connectedCallback() {
    if (this.isrtl) {
      this.maindivcls = 'rtl';
    } else {
      this.maindivcls = 'ltr';
    }
  }
  @api noShow = false;
  changeInputValue(event) {
    let datavalue = event.target.dataset.value;

    if (event.target.dataset.value === "sitePreference") {
      this.participantrecord.Site_Communication_Preference__c =
        event.target.checked;
    } else if (event.target.dataset.value === "Reason") {
      if (event.target.value == null || event.target.value == ' ') {
        this.participantrecord.Non_Enrollment_Reason__c = '';
        this.selectedreason = '';
        if (this.selectedOutcomeIV == "Declined_Consent") {
          if (this.selectedreason == "PWS_Picklist_Value_Other") {
            this.selectedreasonIV = "PWS_Picklist_Value_Other";
          } else {
            this.selectedreasonIV = event.target.value;
          }
        }
      } else {
        this.participantrecord.Non_Enrollment_Reason__c = event.target.value;
        this.selectedreason = event.target.value;
        if (this.selectedOutcomeIV == "Declined_Consent") {
          //Patch Release
          this.statusChanged = true;
          this.participantrecord.Participant_Status__c = "Declined Consent";
          this.participantrecord.Informed_Consent__c = false;

          if (this.selectedreason == "PWS_Picklist_Value_Other") {
            this.selectedreasonIV = "PWS_Picklist_Value_Other";
          } else {
            this.selectedreasonIV = event.target.value;
          }
        }
      }
    } else if (event.target.dataset.value === "InitialVisitDate") {
      this.participantrecord.Initial_visit_scheduled_date__c =
        event.target.value;
    } else if (event.target.dataset.value === "InitialVisitTime") {
      this.participantrecord.Initial_visit_scheduled_time__c =
        event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "additionalNotes") {
      this.additionalNote = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "additionalNotesIV") {
      this.additionalNoteIV = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "screeningID") {
      this.participantrecord.IVRS_IWRS__c = event.target.value.trim();
      if (this.participantrecord.Clinical_Trial_Profile__r.Tokenization_Support__c) {
        if (!this.participantrecord.IVRS_IWRS__c || this.participantrecord.IVRS_IWRS__c == '') {
          this.isScreeningReq = true;
          this.customButtonValidation();
        } else {
          this.customButtonValidation();
        }
      }
    } else if (event.target.dataset.value === 'SexatBirth') {
      this.participantRec.Gender__c = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "RevisitDate") {
      this.participantrecord.Revisit_Date__c = event.target.value;
      this.reVisitDt = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "SignedDate") {
      this.participantrecord.Informed_Consent_Date__c = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "AttentedDate") {
      this.participantrecord.Initial_visit_occurred_date__c =
        event.target.value;
    } else if (event.target.dataset.value === "RunInWashOut") {
      if (event.target.value == "Yes") {
        this.participantrecord.Washout_Run_In_Applies__c = true;
        this.runinwashout = "Yes";
        this.customButtonValidation();
      } else {
        this.participantrecord.Washout_Run_In_Applies__c = false;
        this.runinwashout = "No";
        this.reVisitDt = "";
        this.participantrecord.Revisit_Date__c = null; // patch release
        this.customButtonValidation();
      }
    } else if (event.target.dataset.value === "InitialVisitAttended") {
      if (event.target.value == "Yes") {
        this.noShow = false; this.additionalNote = "";
        this.participantrecord.Initial_visit_occurred_flag__c = true;
        this.initialvisitattended = "Yes";
        this.customFieldValidation(datavalue);
        this.participantrecord.Initial_visit_occurred_date__c = this.currentuserdate;
        this.participantrecord.ParticipantNoShow__c = false;
        if (this.selectedOutcomeIV != "BTN_Yes") {
          this.customFieldValidation("Consent Signed");
        }
        if (
          this.participantrecord.Informed_Consent__c &&
          this.participantrecord.Initial_visit_scheduled_date__c != null &&
          this.participantrecord.Initial_visit_scheduled_date__c != "" &&
          this.pe_record.Participant_Status__c != "Ready to Screen" &&
          this.participantrecord.isBulkUpdate__c == false
        ) {
          this.participantrecord.Participant_Status__c = "Ready to Screen";
          this.participantrecord.Non_Enrollment_Reason__c = '';
        } else {
          delete this.participantrecord.Participant_Status__c;
          this.participantrecord.isBulkUpdate__c = false;
        }
      } else {
        this.additionalNote = "";
        this.participantrecord.Initial_visit_occurred_flag__c = false;
        this.initialvisitattended = "No";
        this.customFieldValidation(datavalue);
        //Patch Release Fix--------------------
        //delete this.participantrecord.Initial_visit_occurred_date__c;
        this.participantrecord.Initial_visit_occurred_date__c = '';

        if (this.selectedOutcomeIV != "BTN_Yes") {
          this.customFieldValidation("Consent Signed");
        }
        if (this.participantrecord.Participant_Status__c == "Ready to Screen") {
          delete this.participantrecord.Participant_Status__c;
        }
      }
    } else if (event.target.dataset.value === "EnrollmentID") {
      this.participantrecord.Screening_ID__c = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "RandomizationID") {
      this.participantrecord.Screening_ID__c = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "FinalConsent") {
      this.participantrecord.Final_consent__c = event.target.checked;
      this.customButtonValidation();
      if (event.target.checked) {
        this.customFieldValidation("FinalConsent");
      }
    } else if (event.target.dataset.value === "VisitPlan") {
      this.participantrecord.Visit_Plan__c = event.target.value;
      this.plan = event.target.value;
      this.customButtonValidation();
      this.customFieldValidation("VisitPlan");
    } else if (event.target.dataset.value === "PartcipantNoShow") {
      this.participantrecord.ParticipantNoShow__c = event.target.checked;
      if (event.target.checked) {
        this.noShow = true; this.additionalNote = "";
        this.participantrecord.Non_Enrollment_Reason__c = '';
        this.participantrecord.Participant_Status__c = "Participant No Show";
        this.statusChanged = true;
      } else {
        this.noShow = false;
        this.additionalNote = "";
        delete this.participantrecord.Participant_Status__c;
        this.statusChanged = false;
      }
    }
    this.isdataChanged();
    this.validateTelevisitVisibility();
    this.validateTelevisitVisibility2();
  }

  customFieldValidation(dataValue) {
    let element = this.template.querySelector(
      '[data-value="' + dataValue + '"]'
    );
    let fieldValue = element.value;
    let fieldLabel = element.label;
    let fieldname = element.name;
    if (fieldname == "Initial Visit Attended") {
      if (this.initialvisitattended == "No") {
        element.setCustomValidity(this.label.FD_PE_Field_Initial_Visit_Attended_Validation);
        element.reportValidity();
      } else {
        element.setCustomValidity("");
        element.reportValidity();
      }
    }
    if (fieldname == "ConsentSigned") {
      if (this.selectedOutcomeIV != "BTN_Yes") {
        if (!this.pe_record.Informed_Consent__c) {
          element.setCustomValidity(this.label.FG_PE_Inf_Consent_Validation);
          element.reportValidity();
        }
      } else {
        element.setCustomValidity("");
        element.reportValidity();
      }
    }
    if (fieldname == "FinalConsent") {
      if (this.participantrecord.Final_consent__c) {
        element.setCustomValidity("");
        element.reportValidity();
      }
    }
    if (fieldname == "VisitPlan") {
      if (this.plan != null && this.plan != "") {
        element.setCustomValidity("");
        element.reportValidity();
      }
    }
    if (fieldname == "ScreeningOutcome") {
      element.setCustomValidity(this.label.PWS_Withdrew_Conscent_Disclaimer);
      element.reportValidity();
    }
  }
  @track initialVisitTelevisitVisible = false;
  get isTelevisitEnabled() {
    getTelevisitVisibility({ ParticipantEnrollmentId: this.peid })
      .then((result) => {
        this.initialVisitTelevisitVisible = result;
      })
      .catch((error) => {
        console.log(error);
        return false;
      });
    return true;
  }

  get isReceived() {
    if (this.currentitems.index == 0) {
      return true;
    } else {
      return false;
    }
  }

  get isContact() {
    if (this.currentitems.index == 1) {
      return true;
    } else {
      return false;
    }
  }

  get isInitialvist() {
    if (
      this.currentitems.index == 2 &&
      this.groupname != "PWS_Eligibility_Card_Name"
    ) {
      this.validateTelevisitVisibility2();
      return true;
    } else {
      return false;
    }
  }

  get isEligibility() {
    if (
      this.currentitems.index == 2 &&
      this.groupname == "PWS_Eligibility_Card_Name"
    ) {
      return true;
    } else {
      return false;
    }
  }

  get isScreening() {
    if (this.currentitems.index == 3) {
      return true;
    } else {
      return false;
    }
  }

  get isEnrolled() {
    if (
      this.currentitems.index == 4 &&
      this.groupname != "PWS_Randomization_Card_Name"
    ) {
      return true;
    } else {
      return false;
    }
  }

  get isRandomized() {
    if (
      this.currentitems.index == 4 &&
      this.groupname == "PWS_Randomization_Card_Name"
    ) {
      return true;
    } else {
      return false;
    }
  }
  get isconsentSigned() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      return false;
    } else {
      return this.pe_record.Informed_Consent__c;
    }
  }
  get isTokanizationSupportReq() {
    if (this.pe_record.Clinical_Trial_Profile__r.Tokenization_Support__c) {
      return true;
    } else {
      return false;
    }
  }
  get isconsentSignedPlaceholder() {
    if (this.pe_record.Participant_Status__c == "Withdrew Consent") {
      return " ";
    } else if (this.pe_record.Informed_Consent__c) {
      return this.utilLabels.BTN_Yes;
    } else {
      return " ";
    }
  }
  get reasonLabel() {
    if (this.selectedOutcome == "Pre_review_Failed" ||
      this.selectedOutcome == "Screening_Failed" ||
      this.selectedOutcome == "Unable_to_Screen" ||
      this.selectedOutcome == "Withdrew_Consent" ||
      this.selectedOutcome == "Withdrew_Consent_After_Screening" ||
      this.selectedOutcome == "Declined_Final_Consent" ||
      this.selectedOutcome == "Eligibility_Failed" ||
      this.selectedOutcome == "Enrollment_Failed" ||
      this.selectedOutcome == "Randomization_Failed" ||
      this.selectedOutcome == "Contacted_Not_Suitable"
    ) {
      return this.label.PIR_Reason_Required;
    } else {
      return this.utilLabels.PG_ACPE_L_Reason;
    }
  }

  reasoneoptions = [];
  outcomeoptions = [];
  participantrecord;
  participantRec;
  additionalNote = "";
  @api runinwashout = "";
  statusChanged = false;
  @api initialvisitattended = "";
  additionalNoteIV = "";
  @api consentSigned = false;
  notesNeeded = [];
  @api
  get setOpt() {
    return this.outcomeoptions;
  }
  set setOpt(value) {
    this.reasoneoptions = [];
    this.outcomeoptions = [];
    this.selectedOutcome = "";
    this.selectedOutcomeIV = "";
    this.selectedreason = "";
    this.selectedreasonIV = "";
    this.additionalNote = "";
    this.additionalNoteIV = "";
    this.notesNeeded = [];
    this.statusChanged = false;
    this.participantrecord = JSON.parse(JSON.stringify(this.pe_record));
    this.participantRec = {
      Id: this.participantrecord.Participant__c,
      Gender__c: this.participantrecord.Participant__r.Gender__c
    };
    this.consentSigned = this.pe_record.Informed_Consent__c;
    this.reVisitDt = this.participantrecord.Revisit_Date__c;


    if (this.participantrecord.Washout_Run_In_Applies__c) {
      this.runinwashout = "Yes";
    } else {
      this.runinwashout = "No";
    }
    if (this.participantrecord.Initial_visit_occurred_flag__c) {
      this.initialvisitattended = "Yes";
    } else {
      this.initialvisitattended = "No";
    }

    this.setOutcomeOptions();
  }
  renderedCallback() {
    if (this.currentitems.index == 3) {
      if (this.pe_record.Clinical_Trial_Profile__r.Initial_Visit_Required__c) {
        if (this.pe_record.Participant_Status__c == "Withdrew Consent") {
          let datavalue = "ScreeningOutcome";
          let element = this.template.querySelector(
            '[data-value="' + datavalue + '"]'
          );
          element.setCustomValidity(this.label.PWS_Withdrew_Conscent_Disclaimer);
          element.reportValidity();
        }
        if (this.pe_record.Participant_Status__c == "Declined Consent") {
          let datavalue = "ScreeningOutcome";
          let element = this.template.querySelector(
            '[data-value="' + datavalue + '"]'
          );
          element.setCustomValidity(this.label.PWS_Declined_Conscent_Disclaimer);
          element.reportValidity();
        }
      }
    }
  }
  get checkContactStatus() {
    if (this.grpicons == "success") {
      if (this.isinitialvisit) {
        if (this.isinitialvisitpresent || (this.pe_record.Informed_Consent__c && this.pe_record.Initial_visit_occurred_flag__c)) {
          return false;
        } else {
          if (this.pe_record.Participant_Status__c == 'Declined Consent') {
            return false;
          } else {
            return true;
          }
        }
      } else {
        return false;
      }
    } else if (this.grpicons == "failure") {
      return true;
    } else if (this.grpicons == "inProgress") {
      return true;
    } else {
      return false;
    }
  }
  get checkEligibilityStatus() {
    if (this.grpicons == "success") {
      return false;
    } else if (this.grpicons == "failure") {
      return true;
    } else if (this.grpicons == "inProgress") {
      return true;
    } else {
      return false;
    }
  }
  get checkScreeningStatus() {
    if (this.grpicons == "success") {
      return false;
    } else if (this.grpicons == "failure") {
      return true;
    } else if (this.grpicons == "inProgress") {
      return true;
    } else {
      return false;
    }
  }
  get disableRevisitdt() {
    if (this.runinwashout == "Yes") {
      return false;
    } else {
      return true;
    }
  }
  get disableAttendeddt() {
    if (this.initialvisitattended == "Yes") {
      return false;
    } else {
      return true;
    }
  }
  get consentSignedDate() {
    if (this.selectedOutcomeIV == "Withdrew_Consent") {
      return true;
    } else if (this.selectedOutcomeIV == "Declined_Consent") {
      return true;
    } else if (this.selectedOutcomeIV == "BTN_Yes") {
      return false;
    } else if (this.pe_record.Informed_Consent__c) {
      return false;
    } else {
      return true;
    }
  }
  get isinitialvisitattended() {
    if (this.initialvisitattended == "Yes") {
      return true;
    } else {
      return false;
    }
  }
  get isOnlyVisitPlan() {
    if (this.isvprequired && !this.isfinalconsentrequired) {
      return true;
    } else {
      return false;
    }
  }
  get isOnlyFinalConsent() {
    if (!this.isvprequired && this.isfinalconsentrequired) {
      return true;
    } else {
      return false;
    }
  }
  get isVisitPlanAndFinalConsentRequired() {
    if (this.isfinalconsentrequired && this.isvprequired) {
      return true;
    } else {
      return false;
    }
  }
  get isVisitPlanAndFinalConsentNotRequired() {
    if (!this.isfinalconsentrequired && !this.isvprequired) {
      return true;
    } else {
      return false;
    }
  }
  get screeningPlaceholder() {
    if (
      this.participantrecord.Clinical_Trial_Profile__r.Initial_Visit_Required__c
    ) {
      if (this.pe_record.Participant_Status__c == "Withdrew Consent") {
        return this.label.PG_RP_L_Not_selected;
      } else if (this.pe_record.Participant_Status__c == "Declined Consent") {
        return this.utilLabels.Declined_Consent;
      } else if (this.pe_record.Participant_Status__c == "Ready to Screen") {
        return this.utilLabels.Ready_to_Screen;
      } else {
        return this.label.PG_RP_L_Not_selected;
      }
    } else {
      return this.label.PG_RP_L_Not_selected;
    }

  }
  get checkOldStatus() {
    if (this.pe_record.Clinical_Trial_Profile__r.Initial_Visit_Required__c) {
      if (
        this.pe_record.Participant_Status__c == "Withdrew Consent" ||
        this.pe_record.Participant_Status__c == "Declined Consent"
      ) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }

  }
  get checkOutcome() {
    if (this.selectedOutcomeIV == "Declined_Consent") {
      return true;
    } else {
      return false;
    }
  }
  get signedReasonPlaceHolder() {
    if (this.selectedOutcomeIV == "Declined_Consent") {
      //return this.label.PG_AC_Select;
      return " ";
    } else if (this.selectedOutcomeIV == "Withdrew_Consent") {
      if (this.selectedreasonIV == null || this.selectedreasonIV == "") {
        return " ";
      } else {
        return this.pe_record.Non_Enrollment_Reason__c;
      }
    } else {
      return " ";
    }
  }
  setOutcomeOptions() {
    let objKeys = Object.keys(this.outcomeToReasonMap);
    let opts = this.createopts(objKeys);
    let trans_opts = [];
    if (this.pe_record.Clinical_Trial_Profile__r.Initial_Visit_Required__c) {
      if (this.pe_record.Participant_Status__c == "Withdrew Consent") {
        trans_opts.push({
          label: this.utilLabels.PWS_Picklist_Value_Withdrew,
          value: "Withdrew_Consent"
        });
        trans_opts.push({ label: this.utilLabels.BTN_Yes, value: "BTN_Yes" });
        let withdrewReasons = {
          'Transportation Issues': 'PWS_Picklist_Value_Transportation_Issues',
          'Childcare Issues': 'PWS_Picklist_Value_Childcare_Issues',
          'Protocol Concerns': 'PWS_Picklist_Value_Protocol_Concerns',
          'Participant Not Interested': 'PWS_Picklist_Value_Participant_Not_Interested',
          'Other': 'PWS_Picklist_Value_Other'
        };
        this.selectedreasonIV = withdrewReasons[this.pe_record.Non_Enrollment_Reason__c];
        this.selectedOutcomeIV = "Withdrew_Consent";
      } else if (this.pe_record.Participant_Status__c == "Declined Consent") {
        for (let i = 0; i < opts.length; i++) {
          if (opts[i].label === "BTN_Yes") {
            trans_opts.push({
              label: this.utilLabels.BTN_Yes,
              value: opts[i].value
            });
          } else if (opts[i].label === "Declined_Consent") {
            trans_opts.push({
              label: this.utilLabels.PIR_Declined,
              value: opts[i].value
            });
          }
        }
        this.selectedOutcomeIV = "Declined_Consent";
        let reasonopts = this.createopts(
          this.outcomeToReasonMap[this.selectedOutcomeIV]
        );
        let trans_reasonopts = [];
        for (let i = 0; i < reasonopts.length; i++) {
          let outcomeReasonLabel = reasonopts[i].label;
          let outcomeReasonValue = reasonopts[i].value;
          if (outcomeReasonValue.endsWith("*")) {
            outcomeReasonLabel = outcomeReasonLabel.substring(
              0,
              outcomeReasonLabel.length - 1
            );
            outcomeReasonValue = outcomeReasonValue.substring(
              0,
              outcomeReasonValue.length - 1
            );
            if (outcomeReasonLabel.length != 1) {
              this.notesNeeded.push(outcomeReasonValue);
            } else {
              this.notesNeeded.push('BLANK');
            }
          }
          trans_reasonopts.push({
            label: this.utilLabels[outcomeReasonLabel],
            value: outcomeReasonValue
          });
        }
        this.reasoneoptions = trans_reasonopts;
        let declinedReasons = {
          'Transportation Issues': 'PWS_Picklist_Value_Transportation_Issues',
          'Childcare Issues': 'PWS_Picklist_Value_Childcare_Issues',
          'Protocol Concerns': 'PWS_Picklist_Value_Protocol_Concerns',
          'Participant Not Interested': 'PWS_Picklist_Value_Participant_Not_Interested',
          'Other': 'PWS_Picklist_Value_Other'
        };
        this.selectedreasonIV = declinedReasons[this.pe_record.Non_Enrollment_Reason__c];
      } else {
        for (let i = 0; i < opts.length; i++) {
          if (opts[i].label === "Screening In Progress - Wash Out Period") {
            trans_opts.push({
              label: this.utilLabels.In_Wash_Out_Period,
              value: "Screening In Progress - Wash Out Period"
            });
          } else if (opts[i].label === "Declined_Consent") {
            trans_opts.push({
              label: this.utilLabels.PIR_Declined,
              value: opts[i].value
            });
          } else {
            if (opts[i].label === "Declined_Final_Consent") {
              if (this.pe_record.Clinical_Trial_Profile__r.Final_Consent_Required__c) {
                trans_opts.push({
                  label: this.utilLabels[opts[i].label],
                  value: opts[i].value
                });
              }
            }
            else {
              trans_opts.push({
                label: this.utilLabels[opts[i].label],
                value: opts[i].value
              });
            }
          }
        }
      }
    } else {
      for (let i = 0; i < opts.length; i++) {
        if (opts[i].label === "Screening In Progress - Wash Out Period") {
          trans_opts.push({
            label: this.utilLabels.In_Wash_Out_Period,
            value: "Screening In Progress - Wash Out Period"
          });
        } else if (opts[i].label === "Declined_Consent") {
          trans_opts.push({
            label: this.utilLabels.PIR_Declined,
            value: opts[i].value
          });
        } else {
          if (opts[i].label === "Declined_Final_Consent") {
            if (this.pe_record.Clinical_Trial_Profile__r.Final_Consent_Required__c) {
              trans_opts.push({
                label: this.utilLabels[opts[i].label],
                value: opts[i].value
              });
            }
          }
          else {
            trans_opts.push({
              label: this.utilLabels[opts[i].label],
              value: opts[i].value
            });
          }
        }
      }
    }

    this.outcomeoptions = trans_opts;
  }
  createopts(optList) {
    let options = [];
    for (let i = 0; i < optList.length; i++) {
      options.push({ label: optList[i], value: optList[i] });
    }
    return options;
  }
  outcomeHandleChange(event) {
    let datavalue = event.target.dataset.value;
    this.selectedOutcome = event.detail.value;
    if (datavalue === "Consent Signed") {
      if (this.selectedOutcome == "BTN_Yes") {
        this.participantrecord.Informed_Consent__c = true;
        delete this.participantrecord.Participant_Status__c;
      } else if (this.selectedOutcome == "Declined_Consent") {
        this.participantrecord.Participant_Status__c = "Declined Consent";
        this.participantrecord.Informed_Consent__c = false;
      } else {
        this.participantrecord.Informed_Consent__c = false;
        this.participantrecord.Informed_Consent_Date__c = "";
        delete this.participantrecord.Participant_Status__c;
      }
    } else {
      if (event.detail.value == "Screening In Progress - Wash Out Period") {
        this.participantrecord.Participant_Status__c =
          "Screening In Progress - Wash Out Period";
      } else {
        this.participantrecord.Participant_Status__c = this.outcomeValues[event.detail.value];
      }
    }
    this.statusChanged = true;
    let reasonopts = this.createopts(
      this.outcomeToReasonMap[this.selectedOutcome]
    );
    let trans_reasonopts = [];
    for (let i = 0; i < reasonopts.length; i++) {
      let outcomeReasonLabel = reasonopts[i].label;
      let outcomeReasonValue = reasonopts[i].value;
      if (outcomeReasonValue.endsWith("*")) {
        outcomeReasonLabel = outcomeReasonLabel.substring(
          0,
          outcomeReasonLabel.length - 1
        );
        outcomeReasonValue = outcomeReasonValue.substring(
          0,
          outcomeReasonValue.length - 1
        );
        if (outcomeReasonLabel.length != 1) {
          this.notesNeeded.push(outcomeReasonValue);
        } else {
          this.notesNeeded.push('BLANK');
        }
      }
      trans_reasonopts.push({
        label: this.utilLabels[outcomeReasonLabel],
        value: outcomeReasonValue
      });
    }
    this.reasoneoptions = trans_reasonopts;
    if (this.reasoneoptions.length > 0) {
      if (datavalue === "Consent Signed") {
        this.selectedreason = "";
        this.participantrecord.Non_Enrollment_Reason__c = "";
      } else {
        if (this.reasoneoptions[0].label == undefined) {
          this.selectedreason = "";
          this.participantrecord.Non_Enrollment_Reason__c = "";
        } else {
          //Reason fix
          //this.selectedreason = this.reasoneoptions[0].value;
          //this.participantrecord.Non_Enrollment_Reason__c = this.reasoneoptions[0].value;
          this.selectedreason = "";
          this.participantrecord.Non_Enrollment_Reason__c = '';
        }
      }
    } else {
      this.selectedreason = "";
      this.participantrecord.Non_Enrollment_Reason__c = "";
    }
    if (datavalue === "Consent Signed") {
      if (this.selectedOutcome != null && this.selectedOutcome != "") {
        this.customFieldValidation("InitialVisitAttended");
      }
      this.customFieldValidation("Consent Signed");
      this.customButtonValidation();
    }
    if (this.participantrecord.Clinical_Trial_Profile__r.Tokenization_Support__c) {
      if (this.selectedOutcome === "Screening_Passed") {
        this.isScreeningReq = true;
        this.customButtonValidation();
      } else if (this.selectedOutcome === "Randomization_Success" || this.selectedOutcome === "PE_STATUS_ENROLLMENT_SUCCESS") {
        this.customButtonValidation();
      } else {
        this.isScreeningReq = false;
        this.customButtonValidation();
      }
    }
    if (this.selectedOutcome == "Unable_to_Reach") {
      this.customButtonValidation();
    }
    this.isdataChanged();
    this.validateTelevisitVisibility();
    this.validateTelevisitVisibility2();
  }
  @api consSign = false;
  outcomeHandleChangeIV(event) {
    let datavalue = event.target.dataset.value;
    this.selectedOutcomeIV = event.detail.value;
    if (this.selectedOutcomeIV == "BTN_Yes") {
      this.participantrecord.Informed_Consent__c = true;
      this.participantrecord.Re_consent__c = false;
      this.participantrecord.Participant_Status__c = "Ready to Screen";
      this.customFieldValidation("Consent Signed");
      if (this.initialvisitattended == "No") {
        this.customFieldValidation("InitialVisitAttended");
        this.consSign = true;
      }else{this.consSign = false;}
    } else if (this.selectedOutcomeIV == "Declined_Consent") {
      this.participantrecord.Participant_Status__c = "Declined Consent";
      this.participantrecord.Informed_Consent__c = false;
      this.consSign = false;
    } else if (this.selectedOutcomeIV == "Withdrew_Consent") {
      this.participantrecord.Participant_Status__c = "Withdrew Consent";
      this.participantrecord.Informed_Consent__c = false;
      this.consSign = false;
    } else {
      this.participantrecord.Informed_Consent__c = false;
      this.participantrecord.Re_consent__c = false;
      delete this.participantrecord.Participant_Status__c;
      this.consSign = false; 
    }

    this.statusChanged = true;
    let reasonopts = this.createopts(
      this.outcomeToReasonMap[this.selectedOutcomeIV]
    );
    let trans_reasonopts = [];
    if (this.pe_record.Participant_Status__c != "Withdrew Consent") {
      for (let i = 0; i < reasonopts.length; i++) {
        let outcomeReasonLabel = reasonopts[i].label;
        let outcomeReasonValue = reasonopts[i].value;
        if (outcomeReasonValue.endsWith("*")) {
          outcomeReasonLabel = outcomeReasonLabel.substring(
            0,
            outcomeReasonLabel.length - 1
          );
          outcomeReasonValue = outcomeReasonValue.substring(
            0,
            outcomeReasonValue.length - 1
          );
          if (outcomeReasonLabel.length != 1) {
            this.notesNeeded.push(outcomeReasonValue);
          } else {
            this.notesNeeded.push('BLANK');
          }
        }
        trans_reasonopts.push({
          label: this.utilLabels[outcomeReasonLabel],
          value: outcomeReasonValue
        });
      }
    }
    this.reasoneoptions = trans_reasonopts;
    this.selectedreason = "";
    this.selectedreasonIV = "";
    this.participantrecord.Non_Enrollment_Reason__c = "";
    if (this.selectedOutcomeIV != null && this.selectedOutcomeIV != "") {
      this.customFieldValidation("InitialVisitAttended");
    }

    this.customFieldValidation("Consent Signed");
    this.customButtonValidation();
    this.isdataChanged();
  }
  get reasonDisabled() {
    if (this.selectedOutcomeIV == "BTN_Yes") {
      let elements = this.template.querySelector(
        '[data-value="' + 'Reason' + '"]'
      );
      elements.setCustomValidity("");
      elements.reportValidity();
    }
    return this.reasoneoptions == 0;
  }
  get screeningReasonDisabled() {
    if (this.pe_record.Clinical_Trial_Profile__r.Initial_Visit_Required__c) {
      if (
        this.pe_record.Participant_Status__c == "Withdrew Consent" ||
        this.pe_record.Participant_Status__c == "Declined Consent"
      ) {
        return true;
      } else {
        return this.reasoneoptions == 0;
      }
    } else {
      return this.reasoneoptions == 0;
    }
  }

  get notesLabel() {
    if (this.selectedOutcome == "Contacted_Not_Suitable" && this.selectedreason == "") {
      this.customButtonValidation();
      return this.utilLabels.PG_ACPE_L_Notes_Optional;
    } else if (this.selectedOutcome == "Unable_to_Reach" && this.selectedreason == "") {
      this.customButtonValidation();
      return this.utilLabels.PG_ACPE_L_Notes_Required;
    } else {
      if (this.notesNeeded.includes(this.selectedreason)) {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Required;
      } else {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Optional;
      }
    }
  }
  get notesLabelIV() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      if (this.selectedOutcomeIV == "BTN_Yes") {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Required;
      } else if (
        this.selectedOutcomeIV == "Declined_Consent" &&
        this.selectedreason == "PWS_Picklist_Value_Other"
      ) {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Required;
      } else {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Optional;
      }
    } else {
      if (this.selectedreason == "PWS_Picklist_Value_Other") {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Required;
      } else {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Optional;
      }
    }
  }
  get notesRequiredIV() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      if (this.selectedOutcomeIV == "BTN_Yes") {
        return true;
      } else {
        return false;
      }
    } else {
      if (this.selectedreasonIV == "PWS_Picklist_Value_Other") {
        return true;
      } else {
        return false;
      }
    }
  }
  get signeddtRequiredIV() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      if (this.selectedOutcomeIV == "BTN_Yes") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
  get checkPerStatus() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Successfully Contacted" ||
      this.pe_record.Participant_Status__c == "Successfully re-engaged" ||
      this.pe_record.Participant_Status__c == "Ready to Screen" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      return false;
    } else {
      return true;
    }
  }
  customButtonValidation() {
    let notes = this.additionalNote.trim();
    let btnValidationSuccess = false;
    let validationList = [];

    //1.
    if (this.notesNeeded.includes(this.selectedreason)) {
      if (this.notesNeeded.includes(this.selectedreasonIV)) {
        let noteIV = this.additionalNoteIV.trim();
        if (noteIV != null && noteIV != "" && noteIV.length != 0) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      } else {
        if (notes != null && notes != "" && notes.length != 0) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      }
    }

    //2.
    if (this.runinwashout == "Yes") {
      this.revisitDateReq = true; //patch release
      if (this.participantrecord.Revisit_Date__c) {
        btnValidationSuccess = true;
        validationList.push(btnValidationSuccess);
      } else {
        btnValidationSuccess = false;
        validationList.push(btnValidationSuccess);
      }
    } else {
      this.revisitDateReq = false; //patch release
      btnValidationSuccess = true;
      validationList.push(btnValidationSuccess);
    }
    //3.
    if (
      (this.selectedOutcome == "Randomization_Success" ||
        this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS") ||
      (this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success'))
    ) {
      let enrollment_or_randomizationid =
        this.participantrecord.Screening_ID__c == undefined
          ? ""
          : this.participantrecord.Screening_ID__c;
      let screeningids = enrollment_or_randomizationid.trim();
      if (this.isfinalconsentrequired) {
        if (this.participantrecord.Final_consent__c) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      }
      if (
        screeningids != null &&
        screeningids != "" &&
        screeningids.length != 0
      ) {
        btnValidationSuccess = true;
        validationList.push(btnValidationSuccess);
      } else {
        btnValidationSuccess = false;
        validationList.push(btnValidationSuccess);
      }
      if (this.isvprequired) {
        if (this.plan != null && this.plan != "" && this.plan.length != 0) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
          this.participantrecord.Visit_Plan__c = this.plan;
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      }
    }
    //4.
    if (
      this.selectedOutcomeIV == "Declined_Consent" &&
      this.selectedreasonIV == ""
    ) {
      btnValidationSuccess = false;
      validationList.push(btnValidationSuccess);
    } else {
      btnValidationSuccess = true;
      validationList.push(btnValidationSuccess);
    }
    //5.
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      let notesIV = this.additionalNoteIV.trim();
      if (this.selectedOutcomeIV == "BTN_Yes") {
        if (notesIV != null && notesIV != "" && notesIV.length != 0) {
          if (this.runinwashout == "Yes") {
            if (this.participantrecord.Revisit_Date__c) {
              btnValidationSuccess = true;
              validationList.push(btnValidationSuccess);
            } else {
              btnValidationSuccess = false;
              validationList.push(btnValidationSuccess);
            }
          } else {
            btnValidationSuccess = true;
            validationList.push(btnValidationSuccess);
          }
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
        if (
          this.participantrecord.Informed_Consent_Date__c != null &&
          this.participantrecord.Informed_Consent_Date__c != ""
        ) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      }
    }

    //6.
    if ((this.selectedOutcome == "Contacted_Not_Suitable" || this.selectedOutcome == "Unable_to_Reach") && this.participantrecord.Non_Enrollment_Reason__c == '') {
      if (notes != null && notes != "" && notes.length != 0) {
        btnValidationSuccess = true;
        validationList.push(btnValidationSuccess);
      } else {
        btnValidationSuccess = false;
        validationList.push(btnValidationSuccess);
      }
    }

    //7.
    if (this.participantrecord.Initial_visit_scheduled_time__c <= '04:59:00.000' || this.participantrecord.Initial_visit_scheduled_time__c >= '23:46:00.000') {
      btnValidationSuccess = false;
      validationList.push(btnValidationSuccess);
    } else {
      btnValidationSuccess = true;
      validationList.push(btnValidationSuccess);
    }

    //8.
    if (this.selectedOutcome == "Pre_review_Failed" ||
      this.selectedOutcome == "Screening_Failed" ||
      this.selectedOutcome == "Unable_to_Screen" ||
      this.selectedOutcome == "Withdrew_Consent" ||
      this.selectedOutcome == "Withdrew_Consent_After_Screening" ||
      this.selectedOutcome == "Declined_Final_Consent" ||
      this.selectedOutcome == "Eligibility_Failed" ||
      this.selectedOutcome == "Enrollment_Failed" ||
      this.selectedOutcome == "Randomization_Failed" ||
      this.selectedOutcome == "Contacted_Not_Suitable"
    ) {
      if (this.selectedreason == "") {
        btnValidationSuccess = false;
        validationList.push(btnValidationSuccess);
      }
    }
    //9.
    if (this.isScreeningReq && (!this.participantrecord.IVRS_IWRS__c || this.participantrecord.IVRS_IWRS__c == '')) {
      btnValidationSuccess = false;
      validationList.push(btnValidationSuccess);
    } else if (this.isSexatBirthReq && (!this.participantRec.Gender__c || this.participantrecord.Gender__c == '')) {
      btnValidationSuccess = false;
      validationList.push(btnValidationSuccess);
    } else {
      btnValidationSuccess = true;
      validationList.push(btnValidationSuccess);
    }
    var discardChanges = ((this.selectedOutcome == 'PE_STATUS_ENROLLMENT_SUCCESS' || this.selectedOutcome == 'Randomization_Success') && !this.pe_record.Is_Participant_DOB_Valid__c)||this.invalidForEligibility;
    if (discardChanges) {
      const validatesavebtn = new CustomEvent("validatesavebutton", {
        detail: true
      });
      this.dispatchEvent(validatesavebtn);
    }
    else if (validationList.includes(false)) {
      const validatesavebtn = new CustomEvent("validatesavebutton", {
        detail: true
      });
      this.dispatchEvent(validatesavebtn);
    } else {
      const validatesavebtn = new CustomEvent("validatesavebutton", {
        detail: false
      });
      this.dispatchEvent(validatesavebtn);
    }
  }

  get runinoptions() {
    return [
      { label: this.label.BTN_No, value: "No" },
      { label: this.label.BTN_Yes, value: "Yes" }
    ];
  }
  get sexAssignedBirth() {
    return [
      { label: Gender_Male, value: 'Male' },
      { label: Gender_Female, value: 'Female' },

    ];
  }
  get initialVisitAttended() {
    return [
      { label: this.label.BTN_No, value: "No" },
      { label: this.label.BTN_Yes, value: "Yes" }
    ];
  }
  todaydate() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;
    return today;
  }
  //Accordian
  toggleAccordian(event) {
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (L) {
        L.classList.toggle("slds-hide");
      });
    this.template.querySelectorAll("." + event.currentTarget.dataset.name + "Bg").forEach(function (L) {
      L.classList.toggle("bg-white");
    });
  }

  getReceivedHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
    this.template.querySelectorAll("." + event.currentTarget.dataset.name + "Bg").forEach(function (L) {
      L.classList.toggle("bg-white");
    });
    getRecievedHistory({ pe: this.peid })
      .then((result) => {
        if (result.length == 0) {
          this.historyNull = true;
        } else {
          this.historyResults = result;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
      });

  }
  @api contactHistorys;
  getContactHistorySection(event) {
    this.historyResults = ""; this.contactHistorys = '';
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
    this.template.querySelectorAll("." + event.currentTarget.dataset.name + "Bg").forEach(function (L) {
      L.classList.toggle("bg-white");
    });
    getContactHistory({ pe: this.peid, groupName: this.latestStatusGrp })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          let contactHistory = result;
          var historyList = [];
          var obj = {};
          for (var i = 0; i < result.length; i++) {
            if (!contactHistory[i].isAdditionalNote) {
              let detailDate = "";
              let finalDtTim = "";
              let ampm = "";
              let hrs = "";
              let mns = "";
              let ms = "";
              detailDate = contactHistory[i].detailDate.substring(0, 11);

              ampm = contactHistory[i].detailDate.substring(20, 22);
              hrs = contactHistory[i].detailDate.substring(11, 13);
              mns = contactHistory[i].detailDate.substring(14, 16);
              ms = contactHistory[i].detailDate.substring(17, 19);
              if (ampm.includes("A")) {
                if (hrs == "12") {
                  hrs == "00";
                }
              } else {
                if (hrs == "1" || hrs == "01") {
                  hrs = "13";
                } else if (hrs == "2" || hrs == "02") {
                  hrs = "14";
                } else if (hrs == "3" || hrs == "03") {
                  hrs = "15";
                } else if (hrs == "4" || hrs == "04") {
                  hrs = "16";
                } else if (hrs == "5" || hrs == "05") {
                  hrs = "17";
                } else if (hrs == "6" || hrs == "06") {
                  hrs = "18";
                } else if (hrs == "7" || hrs == "07") {
                  hrs = "19";
                } else if (hrs == "8" || hrs == "08") {
                  hrs = "20";
                } else if (hrs == "9" || hrs == "09") {
                  hrs = "21";
                } else if (hrs == "10" || hrs == "010") {
                  hrs = "22";
                } else if (hrs == "11" || hrs == "011") {
                  hrs = "23";
                }
              }

              finalDtTim =
                detailDate + "T" + hrs + ":" + mns + ":" + ms + ".000Z";
              finalDtTim = finalDtTim.replace(/ /g, "");
              obj.detailDate = finalDtTim;
              obj.createdBy = contactHistory[i].createdBy;
              obj.title = contactHistory[i].historyTitle;
              obj.number = contactHistory[i].noteKey;
              obj.isAdditionalNote = false;
              historyList.push(obj);
              obj = {};
            }
          }

          historyList.sort(function (a, b) {
            return new Date(a.detailDate) - new Date(b.detailDate);
          });

          this.historyResults = historyList.reverse();
          var historyLists = [];
          var conts = this.historyResults;
          for (var key in conts) {
            if (conts[key].number != undefined) {
              for (var i = 0; i < result.length; i++) {
                if (result[i].isAdditionalNote && (result[i].noteKey == conts[key].number)) {
                  historyLists.push(result[i]);
                }
              }
            }
            historyLists.push(conts[key]);
          }
          for (var i = 0; i < result.length; i++) {
            if (result[i].isAdditionalNote && result[i].isAdditionalNoteOld) {
              historyLists.push(result[i]);
            }
          }
          this.contactHistorys = historyLists;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  getInitialVisitHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
    this.template.querySelectorAll("." + event.currentTarget.dataset.name + "Bg").forEach(function (L) {
      L.classList.toggle("bg-white");
    });

    getInitialVisitHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          this.historyResults = result;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  getEligibilityHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
    this.template.querySelectorAll("." + event.currentTarget.dataset.name + "Bg").forEach(function (L) {
      L.classList.toggle("bg-white");
    });

    getEligibilityHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          this.historyResults = result;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }
  @api screeningHistorys;
  getScreeningHistorySection(event) {
    this.historyResults = "";this.screeningHistorys = '';
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
      this.template.querySelectorAll("."+event.currentTarget.dataset.name+"Bg").forEach(function (L) {
        L.classList.toggle("bg-white");
    });
     //historyStarts
     getScreeningHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          let screenHistory = result;
          var historyList = [];
          var obj = {};
          for (var i = 0; i < result.length; i++) {
            if (!screenHistory[i].isAdditionalNote) {
              let detailDate = "";
              let finalDtTim = "";
              let ampm = "";
              let hrs = "";
              let mns = "";
              let ms = "";
              detailDate = screenHistory[i].detailDate.substring(0, 11);

              ampm = screenHistory[i].detailDate.substring(20, 22);
              hrs = screenHistory[i].detailDate.substring(11, 13);
              mns = screenHistory[i].detailDate.substring(14, 16);
              ms = screenHistory[i].detailDate.substring(17, 19);
              if (ampm.includes("A")) {
                if (hrs == "12") {
                  hrs == "00";
                }
              } else {
                if (hrs == "1" || hrs == "01") {
                  hrs = "13";
                } else if (hrs == "2" || hrs == "02") {
                  hrs = "14";
                } else if (hrs == "3" || hrs == "03") {
                  hrs = "15";
                } else if (hrs == "4" || hrs == "04") {
                  hrs = "16";
                } else if (hrs == "5" || hrs == "05") {
                  hrs = "17";
                } else if (hrs == "6" || hrs == "06") {
                  hrs = "18";
                } else if (hrs == "7" || hrs == "07") {
                  hrs = "19";
                } else if (hrs == "8" || hrs == "08") {
                  hrs = "20";
                } else if (hrs == "9" || hrs == "09") {
                  hrs = "21";
                } else if (hrs == "10" || hrs == "010") {
                  hrs = "22";
                } else if (hrs == "11" || hrs == "011") {
                  hrs = "23";
                }
              }

              finalDtTim =
                detailDate + "T" + hrs + ":" + mns + ":" + ms + ".000Z";
              finalDtTim = finalDtTim.replace(/ /g, "");
              obj.detailDate = finalDtTim;
              obj.createdBy = screenHistory[i].createdBy;
              obj.title = screenHistory[i].historyTitle;
              obj.number = screenHistory[i].noteKey;
              obj.isAdditionalNote = false;
              historyList.push(obj);
              obj = {};
            }
          }

          historyList.sort(function (a, b) {
            return new Date(a.detailDate) - new Date(b.detailDate);
          });
          
          this.historyResults = historyList.reverse();
          var historyLists = [];
          var conts =  this.historyResults;
          for (var key in conts) {
                if(conts[key].number != undefined){
                  for (var i = 0; i < result.length; i++) {
                    if (result[i].isAdditionalNote && (result[i].noteKey == conts[key].number)) {
                      historyLists.push(result[i]);
                    }
                  }
                }
                historyLists.push(conts[key]);
          }
          for (var i = 0; i < result.length; i++) {
            if (result[i].isAdditionalNote){
                  historyLists.push(result[i]);
            }
          }
          this.screeningHistorys = historyLists;
          this.historyNull = false;
        } 
      })
      .catch((error) => {
        console.log(error);
      });
     
    //historyEnds
  }

  getEnrollmentHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
    this.template.querySelectorAll("." + event.currentTarget.dataset.name + "Bg").forEach(function (L) {
      L.classList.toggle("bg-white");
    });

    getEnrollmentHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          this.historyResults = result;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  get makerequiredfinalConsent() {
    if (
      this.selectedOutcome == "Randomization_Success" ||
      this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS"
    ) {
      return true;
    } else if (this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success')) {
      return true;
    } else {
      return false;
    }
  }

  get makerequiredvisitplan() {
    if (
      this.selectedOutcome == "Randomization_Success" ||
      this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS"
    ) {
      return true;
    } else if (this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success')) {
      return true;
    } else {
      return false;
    }
  }
  get isSexatBirthReq() {
    if (
      this.selectedOutcome == "Randomization_Success" ||
      this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS"
    ) {
      return true;
    } else if (this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success')) {
      return true;
    } else {
      return false;
    }
  }
  get makerequiredrandomizationid() {
    if (
      this.selectedOutcome == "Randomization_Success" ||
      this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS"
    ) {
      return true;
    } else if (this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success')) {
      return true;
    } else {
      return false;
    }
  }

  get isvisitplanreadonly() {
    if (this.visitplanoptions.length <= 1) {
      return true;
    } else {
      return false;
    }
  }

  @api
  checkFinalValidation() {
    if (
      this.selectedOutcome == "Pre_review_Failed" ||
      this.selectedOutcome == "Contacted_Not_Suitable" ||
      this.selectedOutcome == "Unable_to_Reach"
    ) {
      if (
        this.participantrecord.Initial_visit_scheduled_date__c != null ||
        this.participantrecord.Initial_visit_scheduled_time__c != null
      ) {
        if (
          this.participantrecord.Initial_visit_scheduled_date__c != null &&
          this.participantrecord.Initial_visit_scheduled_time__c != null &&
          this.participantrecord.Initial_visit_scheduled_date__c != "" &&
          this.participantrecord.Initial_visit_scheduled_time__c != ""
        ) {
          this.isfovNull = false;
        } else {
          this.isfovNull = true;
        }
        this.isModalOpen = true;
      } else {
        this.getSaved();
      }
    } else {
      this.getSaved();
    }
  }

  isdataChanged() {
    let hasChanges = [];
    if (this.pe_record.Site_Communication_Preference__c != this.participantrecord.Site_Communication_Preference__c ||
      this.pe_record.Initial_visit_occurred_flag__c != this.participantrecord.Initial_visit_occurred_flag__c ||
      this.pe_record.Informed_Consent__c != this.participantrecord.Informed_Consent__c ||
      this.pe_record.Washout_Run_In_Applies__c != this.participantrecord.Washout_Run_In_Applies__c ||
      this.pe_record.Final_consent__c != this.participantrecord.Final_consent__c ||
      this.pe_record.ParticipantNoShow__c != this.participantrecord.ParticipantNoShow__c ||
      this.pe_record.Initial_visit_scheduled_date__c != this.participantrecord.Initial_visit_scheduled_date__c ||
      this.pe_record.Initial_visit_scheduled_time__c != this.participantrecord.Initial_visit_scheduled_time__c ||
      this.pe_record.Informed_Consent_Date__c != this.participantrecord.Informed_Consent_Date__c ||
      this.pe_record.IVRS_IWRS__c != this.participantrecord.IVRS_IWRS__c ||
      this.pe_record.Revisit_Date__c != this.participantrecord.Revisit_Date__c ||
      this.pe_record.Screening_ID__c != this.participantrecord.Screening_ID__c ||
      this.pe_record.Final_consent__c != this.participantrecord.Final_consent__c
    ) {
      hasChanges.push(true);
    } else {
      hasChanges.push(false);
    }

    let notes = this.additionalNote.trim();
    if (notes != null && notes != "" && notes.length != 0) {
      hasChanges.push(true);
    } else {
      hasChanges.push(false);
    }

    let notesIV = this.additionalNoteIV.trim();
    if (notesIV != null && notesIV != "" && notesIV.length != 0) {
      hasChanges.push(true);
    } else {
      hasChanges.push(false);
    }

    if (this.selectedOutcome != '' && this.selectedOutcome != null) {
      hasChanges.push(true);
    } else {
      hasChanges.push(false);
    }
    var discardChanges = ((this.selectedOutcome == 'PE_STATUS_ENROLLMENT_SUCCESS' || this.selectedOutcome == 'Randomization_Success') && !this.pe_record.Is_Participant_DOB_Valid__c)||this.invalidForEligibility;
    if (hasChanges.includes(true) && !discardChanges) {
      const valueChangeEvent = new CustomEvent("statusdetailsvaluechange", {
        detail: true
      });
      this.dispatchEvent(valueChangeEvent);
    } else {
      const valueChangeEvent = new CustomEvent("statusdetailsvaluechange", {
        detail: false
      });
      this.dispatchEvent(valueChangeEvent);
    }

  }
  isReEngaged = false;
  getSaved() {
    if (this.addTelevisitForInitialVisit && !this.proceedSaveRecord) {
      this.handleTelevisitOpenModal();
      return;
    }
    // if(this.additionalNote != null && this.additionalNote !=''){
    if (this.statusChanged) {
      if ((this.additionalNote != "") & (this.additionalNote != null)) {
        this.participantrecord.Last_Status_Changed_Notes__c = this.additionalNote;
      } else {
        this.participantrecord.Last_Status_Changed_Notes__c = this.additionalNoteIV;
      }
    } else {
      if ((this.additionalNote != "") & (this.additionalNote != null)) {
        this.participantrecord.Last_Status_Changed_Additional_Notes__c = this.additionalNote;
      } else {
        this.participantrecord.Last_Status_Changed_Additional_Notes__c = this.additionalNoteIV;
      }
    }
    // }
    if (!this.statusChanged) {
      if (this.participantrecord.Participant_Status__c != "Ready to Screen") {
        delete this.participantrecord.Participant_Status__c;
      }
      delete this.participantrecord.Non_Enrollment_Reason__c;
    }
    if (
      this.selectedOutcome == "Successfully_Contacted" ||
      this.selectedOutcome == "Pre_review_Passed"
    ) {
      this.participantrecord.ParticipantNoShow__c = false;
    } else if (
      this.pe_record.ParticipantNoShow__c ==
      this.participantrecord.ParticipantNoShow__c
    ) {
      delete this.participantrecord.ParticipantNoShow__c;
    }
    let isDeclinedAndConsentAsYes = false;
    if(this.consSign == true && this.initialvisitattended == "No" && this.pe_record.Participant_Status__c == "Declined Consent"){
       this.participantrecord.Participant_Status__c = "Successfully Contacted";
       this.participantrecord.Non_Enrollment_Reason__c = '';
       isDeclinedAndConsentAsYes = true;
    }else{
       isDeclinedAndConsentAsYes = false;
    }

    if (this.participantrecord.Participant_Status__c == "Ready to Screen") {
      if (
        this.participantrecord.Informed_Consent__c &&
        this.participantrecord.Initial_visit_occurred_flag__c &&
        this.participantrecord.Initial_visit_scheduled_date__c != null &&
        this.participantrecord.Initial_visit_scheduled_date__c != ""
      ) {
        this.participantrecord.Participant_Status__c = "Ready to Screen";
        this.participantrecord.Non_Enrollment_Reason__c = '';
      } else {
        delete this.participantrecord.Participant_Status__c;
      }
    }
    if (this.participantrecord.Participant_Status__c == "Declined Final Consent") {
      this.participantrecord.Final_consent__c = false;
    }

    if (this.participantrecord.Participant_Status__c == "Withdrew Consent" && this.participantrecord.Initial_visit_occurred_flag__c == true) {
      this.participantrecord.Informed_Consent__c = false;
    }

    if (this.participantrecord.Clinical_Trial_Profile__r.Initial_Visit_Required__c) {
      if (this.participantrecord.Succesfully_Re_Engaged__c == true &&
        ((this.participantrecord.Participant_Status__c == "Successfully Contacted" ||
          this.pe_record.Participant_Status__c == "Successfully Contacted")
          ||
          (this.participantrecord.Participant_Status__c == 'Eligibility Passed' ||
            this.pe_record.Participant_Status__c == 'Eligibility Passed'))
        &&
        this.participantrecord.Initial_visit_scheduled_date__c != null &&
        this.participantrecord.Initial_visit_scheduled_time__c != null
      ) {
        this.participantrecord.Succesfully_Re_Engaged__c = false;
      }
    }

    let outcome = this.selectedOutcome;

    let occuredDt = this.participantrecord.Initial_visit_occurred_date__c;
    let signedDate = this.participantrecord.Informed_Consent_Date__c;
    if(signedDate != undefined){
      let splitDate = signedDate.split('-');
     signedDate = new Date(splitDate[0],splitDate[1]-1,splitDate[2]);
    }
    
    let todayDt = new Date();
    let intVistDt;
    let tdyDt = this.currentuserdate;
     if(occuredDt != undefined){
      let splitDate = occuredDt.split('-');
      intVistDt = new Date(splitDate[0],splitDate[1]-1,splitDate[2]);
    }
    if((signedDate > todayDt) && (intVistDt > todayDt)){
      this.showErrorToast(this.label.PIR_Initial_Visit_Signed_Date_Validation);
    }else if (tdyDt < occuredDt) {
      this.showErrorToast(this.label.PIR_Initial_Visit_Validation);
    }else if(signedDate > todayDt){
      this.showErrorToast(this.label.PIR_Signed_Date_Validation);
    } else {
      let visitPln = 'null';
      if (this.participantrecord.Visit_Plan__c) {
        visitPln = this.participantrecord.Visit_Plan__c;
      }
      if (this.pe_record.Participant_Status__c == 'Ready to Screen' && this.participantrecord.Participant_Status__c == 'Ready to Screen') {
        delete this.participantrecord.Participant_Status__c;
      }
      const selectedEvent = new CustomEvent("recordsave", {});
      this.dispatchEvent(selectedEvent);

      if (this.participantrecord.ParticipantNoShow__c && this.participantrecord.Participant_Status__c != 'Participant No Show') {
        this.participantrecord.Participant_Status__c = 'Participant No Show';
        delete this.participantrecord.Non_Enrollment_Reason__c;
      }

      doSaveStatusDetails({ perRecord: this.participantrecord, perRec: this.participantRec, visitPlan: visitPln, isDeclinedAndConsentAsYes : isDeclinedAndConsentAsYes })
        .then((result) => {
          this.showSuccessToast(this.label.RH_RP_Record_Saved_Successfully);
          const selectedEvent = new CustomEvent("saved", {});
          this.dispatchEvent(selectedEvent);
          if (outcome == "Eligibility_Passed" || this.participantrecord.Participant_Status__c == "Ready to Screen" ||
            this.participantrecord.Participant_Status__c == "Participant No Show") {
            const selectEventHeader = new CustomEvent(
              "callparticipantstatusdetail",
              {}
            );
            this.dispatchEvent(selectEventHeader);
          }
        })
        .catch((error) => {
          console.error("Error:", error);
          this.showErrorToast(JSON.stringify(error.body.message));
        });
    }
  }

  handleCloseModal() {
    this.isModalOpen = false;
  }
  handleCancelModal() {
    this.isModalOpen = false;
  }
  handleProceedModal() {
    this.participantrecord.Initial_visit_scheduled_time__c = "";
    this.participantrecord.Initial_visit_scheduled_date__c = "";
    this.isModalOpen = false;
    this.getSaved();
  }
  showSuccessToast(Message) {
    const evt = new ShowToastEvent({
      title: Message,
      message: Message,
      variant: "success",
      mode: "dismissible"
    });
    this.dispatchEvent(evt);
  }
  showErrorToast(msg) {
    const evt = new ShowToastEvent({
      title: msg,
      message: msg,
      variant: "error",
      mode: "dismissible"
    });
    this.dispatchEvent(evt);
  }
  handleTelevisitCheckboxChange(event) {
    this.addTelevisitForInitialVisit = event.target.checked;
    if (event.target.name === 'televisitCheckbox')
      this.participantrecord.Add_televisit_for_Initial_Visit__c = this.template.querySelector('[data-value="televisitCheckbox"]').checked;
    if (event.target.name === 'televisitCheckbox2')
      this.participantrecord.Add_televisit_for_Initial_Visit__c = this.template.querySelector('[data-value="televisitCheckbox2"]').checked;
  }
  validateTelevisitVisibility() {
    var initialVisitDateValue = this.template.querySelector('[data-value="InitialVisitDate"]').value;
    var initialVisitTimeValue = this.template.querySelector('[data-value="InitialVisitTime"]').value;
    var today = new Date().toLocaleString('sv-SE', { timeZone: TIME_ZONE }).slice(0, 10);
    var currentTime = new Date().toLocaleTimeString('en-US', { timeZone: TIME_ZONE });
    //initialVisitTimeValue = this.getTwentyFourHourTime(initialVisitTimeValue);
    currentTime = this.getTwentyFourHourTime(currentTime);
    var oldValue = this.pe_record.Add_televisit_for_Initial_Visit__c;
    //!this.template.querySelector('[data-value="televisitCheckbox"]').checked
    if (oldValue) {
      this.disableTelevisitCheckbox = true;
    } else if (this.selectedOutcome === 'Successfully_Contacted' &&
      initialVisitDateValue != null &&
      initialVisitDateValue != undefined &&
      initialVisitDateValue != '' &&
      initialVisitTimeValue != null &&
      initialVisitTimeValue != undefined &&
      initialVisitTimeValue != '') {
      if (today < initialVisitDateValue) {
        this.disableTelevisitCheckbox = false;
      } else if (today == initialVisitDateValue && currentTime <= initialVisitTimeValue) {
        this.disableTelevisitCheckbox = false;
      } else {
        if (this.checkContactStatus) {
          this.template.querySelector('[data-value="televisitCheckbox"]').checked = false;
          this.participantrecord.Add_televisit_for_Initial_Visit__c = this.template.querySelector('[data-value="televisitCheckbox"]').checked;
          this.addTelevisitForInitialVisit = false;
        }
        this.disableTelevisitCheckbox = true;
      }


    } else {
      //if(this.checkContactStatus){
      if (this.template.querySelector('[data-value="televisitCheckbox"]') !== null) {
        this.template.querySelector('[data-value="televisitCheckbox"]').checked = oldValue;
        this.participantrecord.Add_televisit_for_Initial_Visit__c = oldValue;
        this.addTelevisitForInitialVisit = oldValue;
      }
      //}      
      this.disableTelevisitCheckbox = true;
    }
  }
  validateTelevisitVisibility2() {
    var initialVisitDateValue;
    var initialVisitTimeValue;
    if (this.template.querySelector('[data-value="InitialVisitDate"]') !== null) {
      initialVisitDateValue = this.template.querySelector('[data-value="InitialVisitDate"]').value;
    }
    if (this.template.querySelector('[data-value="InitialVisitTime"]') !== null) {
      initialVisitTimeValue = this.template.querySelector('[data-value="InitialVisitTime"]').value;
    }
    var today = new Date().toLocaleString('sv-SE', { timeZone: TIME_ZONE }).slice(0, 10);
    var currentTime = new Date().toLocaleTimeString('en-US', { timeZone: TIME_ZONE });
    currentTime = this.getTwentyFourHourTime(currentTime);

    var oldValue = this.pe_record.Add_televisit_for_Initial_Visit__c;
    if (oldValue) {
      this.disableTelevisitCheckbox2 = true;
    } else if (today < initialVisitDateValue) {
      this.disableTelevisitCheckbox2 = false;
    } else if (today == initialVisitDateValue && currentTime <= initialVisitTimeValue) {
      this.disableTelevisitCheckbox2 = false;
    } else {
      if (this.template.querySelector('[data-value="televisitCheckbox2"]') !== null) {
        this.template.querySelector('[data-value="televisitCheckbox2"]').checked = oldValue;
        this.participantrecord.Add_televisit_for_Initial_Visit__c = oldValue;
        this.addTelevisitForInitialVisit = oldValue;
      }
      this.disableTelevisitCheckbox2 = true;
    }

  }

  handleTelevisitCloseModal() {
    this.isTelevisitModalOpen = false;
    this.proceedSaveRecord = false;
    this.disableInitialVisitCheckbox = false;
  }
  proceedTelevisitSave() {
    this.isTelevisitModalOpen = false;
    this.proceedSaveRecord = true;
    this.getSaved();
  }
  handleTelevisitOpenModal() {
    this.isTelevisitModalOpen = true;
  }
  getTwentyFourHourTime(amPmString) {
    var d = new Date("1/1/2013 " + amPmString);
    let h = d.getHours();
    let m = d.getMinutes();
    h = h < 10 ? '0' + h : h;
    m = m < 10 ? '0' + m : m;
    return h + ':' + m + ':00.000';
  }
  get dobErr() {
    return ((this.selectedOutcome == 'PE_STATUS_ENROLLMENT_SUCCESS' || this.selectedOutcome == 'Randomization_Success') && !this.pe_record.Is_Participant_DOB_Valid__c);
  }
  get invalidForEligibility(){
    return (this.pe_record.Clinical_Trial_Profile__r.Promote_to_SH__c && (this.pe_record.Study_Site__r.Study_Site_Type__c =='Virtual'|| this.pe_record.Study_Site__r.Study_Site_Type__c =='Hybrid') && this.selectedOutcome == 'Eligibility_Passed' && !this.pe_record.Is_Participant_DOB_Valid__c);
  }
  
  handleConsentLogin(event) {
    window.open(this.pe_record.Study_Site__r.E_Consent_Vendor__r.Vendor_URL__c,'popup','toolbar=no,scrollbars=no,resizable=no,top=2000,left=10000,width=600,height=500'); 
    return false;    
  }
}
