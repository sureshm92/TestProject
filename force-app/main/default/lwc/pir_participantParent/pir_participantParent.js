import { LightningElement, api, wire, track } from "lwc";
import pirResources from "@salesforce/resourceUrl/pirResources";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getStudyAccessLevel from "@salesforce/apex/PIR_HomepageController.getStudyAccessLevel";
import bulkstatusDetail from "@salesforce/apex/PIR_HomepageController.bulkstatusDetail";
import RH_PP_Add_New_Participant from '@salesforce/label/c.RH_PP_Add_New_Participant';
import RH_PP_Select_Study_Site from '@salesforce/label/c.RH_PP_Select_Study_Site';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import RH_ExportSelected from '@salesforce/label/c.RH_ExportSelected';
import BTN_Export_All from '@salesforce/label/c.BTN_Export_All';
import RH_ParticipantSelected from '@salesforce/label/c.RH_ParticipantSelected';
import Continue from '@salesforce/label/c.Continue';
import PG_VP_L_Study_site from '@salesforce/label/c.PG_VP_L_Study_site';
import CC_Study from '@salesforce/label/c.CC_Study';
import ListView_ChangeStatus from '@salesforce/label/c.ListView_ChangeStatus';
import ListView_New_Status from '@salesforce/label/c.ListView_New_Status';
import ListView_Current_Status from '@salesforce/label/c.ListView_Current_Status';
import PG_ACPE_L_Reason from '@salesforce/label/c.PG_ACPE_L_Reason';
import FD_PE_Field_Final_Consent from '@salesforce/label/c.FD_PE_Field_Final_Consent';
import PG_ACPE_L_Notes from '@salesforce/label/c.PG_ACPE_L_Notes';
import Submit from '@salesforce/label/c.Submit';
import { NavigationMixin } from 'lightning/navigation';
import { label } from "c/pir_label";
import getTelevisitVisibility from "@salesforce/apex/TelevisitCreationScreenController.televisistPrerequisiteCheck";
export default class Pir_participantParent extends NavigationMixin(LightningElement) {
  @api peId;
  @api firstName;
  @api phoneNumber;
  @api studyName;
  @api referredBy;
  @api selectedPE;
  @api isLoaded = false;
  @api disablebtn = false;
  @api statusDetailValueChanged = false;
  @api isModalOpen = false;
  @api lststudysiteaccesslevel = [];
  @api isMedicalHistryAccess = false;
  @api selectedTab = "Status Details";  
  @api discardTab = false;
  @api addNewParticipant = false;
  @track utilLabels = label;
  setList = true;
  backArrow = pirResources + "/pirResources/icons/triangle-left.svg";
  usericon= pirResources+'/pirResources/icons/user.svg';
  disableMedicalSaveButton = true;
  isMedicalTab ; 
  isMedicalModalOpen = false;
  isMedicalDetailChanged = false;
  discardMedicalTab = false;
  progressValue;
  countValue=0;
  cancelCheckbox;
  removeParticipant=true;
  isParticipantDetail=false;
  dropdownLabel;
  ondisableButton=true;
  getSelectedbox=[];
  openpopup=false;
  isSharingOptionsChanged = false;
  discardSharingTab = false;
  isSPModalOpen = false;
  isSharingTab = false;
  @api studylist;
  studyToStudySite;
  studySiteList;
  enableTelevisitTab = false;
  selectedStudy='';selectedSite='';saving = false;studysiteaccess=false;
  label = {
    RH_PP_Add_New_Participant,
    RH_PP_Select_Study_Site,
    BTN_Cancel,
    Continue,
    PG_VP_L_Study_site,
    CC_Study,
    ListView_ChangeStatus,
    ListView_New_Status,
    PG_ACPE_L_Reason,
    FD_PE_Field_Final_Consent,
    PG_ACPE_L_Notes,
    Submit,
    ListView_Current_Status,
    RH_ExportSelected,
    RH_ParticipantSelected,
    BTN_Export_All

  };
  
  @wire(getStudyAccessLevel)
  wiredAccess({ error, data }) {
    if (data) {
        this.lststudysiteaccesslevel = data;
    } else if (error) {
        this.error = error;
    }

  getTelevisitVisibility(peid){
    getTelevisitVisibility({ParticipantEnrollmentId : peid})
            .then((result) => {
                this.enableTelevisitTab = result;
            })
            .catch((error) => {
                console.log(error);
            });
  }
  handleStudyAndSite(event){
    this.studylist = event.detail.studylist;
    this.siteAccessLevels = event.detail.siteAccessLevels;
    this.studyToStudySite = event.detail.studyToStudySite;
    this.studysiteaccess = true;
  }
    
  

  studyhandleChange(event) {
    var picklist_Value = event.target.value;
    this.selectedStudy = picklist_Value;

    var accesslevels = Object.keys(this.siteAccessLevels).length;
    var conts = this.studyToStudySite;
    let options = [];
    var i = this.siteAccessLevels;
    for (var key in conts) {
      if (key == picklist_Value) {
          var temp = conts[key];
        for (var j in temp) {
               if(accesslevels == 0){
                  options.push({ label: temp[j].Name, value: temp[j].Id });
               }else{
                  var level = this.siteAccessLevels[temp[j].Id];
                  if(level != 'Level 3' && level != 'Level 2'){
                     options.push({ label: temp[j].Name, value: temp[j].Id });
                  }
               }
        }
      }
    }
    this.studySiteList = options;
    this.selectedSite = '';
    this.studysiteaccess = false;

  }
  studysitehandleChange(event) {
    this.selectedSite = event.target.value;
  }
  get isStatusDetail(){
     if(this.selectedTab === "Status Details"){
       return true;
     }else{
         if(this.isModalOpen){
          return true;
         }else{
          return false;
         }
     }
  }

  selectedPI(event) {
    this.selectedPE = event.detail;
    this.isMedicalHistryAccess = true;
    this.isMedicalDetailChanged = false;
    this.isDetailModalOpen = false;
    this.isMedicalTab = false;
    this.isParticipantDetail = false;
    this.isDetailsUpdate = false;
    this.isSharingOptionsChanged = false;
    this.discardSharingTab = false;
    this.isSPModalOpen = false;
    this.isSharingTab = false;

    console.log("pe-parent" + JSON.stringify(this.selectedPE));
    this.getTelevisitVisibility(this.selectedPE.id);
    
    if(this.lststudysiteaccesslevel[this.selectedPE.siteId])
    {
      if(this.lststudysiteaccesslevel[this.selectedPE.siteId] == 'Level 3'){
        this.isMedicalHistryAccess = false; 
      } 
    } 

    this.template.querySelector("c-pir_participant-header").selectedPE =this.selectedPE;
    this.template.querySelector("c-pir_participant-header").doSelectedPI();
    this.template.querySelector("c-pir_participant-Status-Details").selectedPE_ID = this.selectedPE.id;
    this.template.querySelector("c-pir_participant-Status-Details").doSelectedPI();
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
    this.template.querySelector("c-pir_sharing-Option").selectedPE =this.selectedPE;
    this.fetchAccessLevel();
    this.discardTab = false;
    this.statusDetailValueChanged = false;
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details"; 
    this.selectedTab = "Status Details";
  }
  curentMobileView = "list";
  mobileViewToggle() { 
    if (this.curentMobileView == "list") {
      this.curentMobileView = "detail";
      this.template.querySelectorAll(".D").forEach(function (D) {
        D.classList.remove("hideMobile");
      });
      this.template.querySelectorAll(".L").forEach(function (L) {
        L.classList.add("hideMobile");
      });
    } else {
      this.curentMobileView = "list";
      this.template.querySelectorAll(".L").forEach(function (L) {
        L.classList.remove("hideMobile");
      });
      this.template.querySelectorAll(".D").forEach(function (D) {
        D.classList.add("hideMobile");
      });
    }
  }
  //pagination
  totalRecord;
  showZeroErr  = false;
  initialLoad = true;
  pageChanged(event) {
    this.page = event.detail.page;
    this.template.querySelector("c-pir_participant-list").pageNumber =
      this.page;
      if(!this.initialLoad){
        this.template.querySelector("c-pir_participant-list").fetchList();
      }
      this.initialLoad = false;
  }
  recCountUpdate(event) {
    this.totalRecord = event.detail;
    if(this.totalRecord == 0){
      this.showZeroErr = true;
    }
    else{
      this.showZeroErr = false;
    }
  }
  handleSpinner(event) {
    this.isLoaded = event.detail;
  }
  changePage(event) {
    let dir = event.detail;
    if (dir == "next") { 
      this.template.querySelector("c-pir_participant-pagination").nextPage();
    }
    if (dir == "prev") {
      this.template
        .querySelector("c-pir_participant-pagination")
        .previousPage();
    }
  }

  doSave() {
    this.isModalOpen = false;
    this.statusDetailValueChanged = false;
    this.discardTab = false;
    this.template
      .querySelector("c-pir_participant-Status-Details")
      .callSaveMethod();
  }
  get disableButton() {
    return this.disablebtn;
  }
  checkvalidation(event) {
    this.disablebtn = event.detail;
  }


  checkMedicalSaveBtn(event){
    if(event.detail.isBMIError){ 
      this.isMedicalDetailChanged = event.detail.isBMIError;
      this.disableMedicalSaveButton = event.detail;

    }
    else { 
    this.disableMedicalSaveButton = !event.detail;
  this.isMedicalDetailChanged = event.detail;

    }
    
    this.discardMedicalTab = false;
  }
  //participant detail
  disableDetailSaveButton =false;
  isDetailsUpdate=false;
  isDetailModalOpen=false;
  discardDetailTab = false;
  checkStatusDetailChanges(event){ 
    this.statusDetailValueChanged = event.detail;
    if(event.detail){
      this.discardTab = false;
    }
  }
  toggleDetailSave(event){
    this.disableDetailSaveButton = !event.detail;
  }
  // doSaveDetail(){
  //   this.template.querySelector("c-pir_participant-Detail").save();
  // }
  detailsUpdate(event){
    this.isDetailsUpdate=false;
    this.isDetailModalOpen=false;
    this.discardDetailTab = false;
    this.isDetailsUpdate = event.detail;
  }
  doSaveDetail(){
    try{
    this.isDetailsUpdate=false;
    this.isDetailModalOpen=false;
    this.discardDetailTab = false;
    this.template.querySelector("c-pir_participant-Detail").save();
    this.disableDetailSaveButton = true;
    }catch(e){
      console.log(e.message +'>>'+e.stack);
    }
 }
 handleDiscardDetail(){
    this.discardDetailTab = true;
    this.isDetailModalOpen = false;    
    this.isParticipantDetail = false;
    this.template.querySelector("c-pir_participant-Detail").peid=this.selectedPE.id;
    this.template.querySelector("lightning-tabset").activeTabValue =  this.selectedTab;
  }
  handleCloseModalDetail(){
    this.selectedTab = "Participant Details";
    this.isDetailModalOpen = false;
  }

  handleStatusTab(){
    this.isMedicalTab = false;
    if(this.isMedicalDetailChanged && this.discardMedicalTab == false){
     
      this.selectedTab = "Status Details";
      this.isMedicalModalOpen = true;
      this.template.querySelector("lightning-tabset").activeTabValue = "Health Information";
    }else if(this.isDetailsUpdate && !this.discardDetailTab){
      this.selectedTab = "Status Details";
      this.isDetailModalOpen = true;
      this.template.querySelector("lightning-tabset").activeTabValue = "Participant Details";
    }else if(this.isSharingOptionsChanged && !this.discardSharingTab){
      this.selectedTab = "Status Details";
      this.isSPModalOpen = true;
      //this.isSharingTab = true;
      this.template.querySelector("lightning-tabset").activeTabValue = "Sharing Options";
    }else{
      this.isSharingTab = false;
    this.isParticipantDetail = false;
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
    this.selectedTab = "Status Details";
    
    }
  }
  handleParticipantTab() {
    if(!this.isDetailModalOpen){     
      this.isParticipantDetail = true;
      this.isMedicalTab = false;
      if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) {
        this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
        this.selectedTab = "Participant Details";
        this.isModalOpen = true;
      } else if(this.isMedicalDetailChanged && this.discardMedicalTab == false){
        
        this.selectedTab = "Participant Details";
        this.isMedicalModalOpen = true;
        this.template.querySelector("lightning-tabset").activeTabValue = "Health Information";
      } else if(this.isSharingOptionsChanged && !this.discardSharingTab){
        this.selectedTab = "Participant Details";
        this.isSPModalOpen = true;
        this.isParticipantDetail = false;
        this.template.querySelector("lightning-tabset").activeTabValue = "Sharing Options";        
      } else{
        this.isSharingTab = false;
        this.selectedTab = "Participant Details";
        
      }
    }
  }
  handleSharingTab() {
    this.isMedicalTab = false;
    if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) {
      this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
      this.selectedTab = "Sharing Options";
      this.isModalOpen = true;   
    }else if(this.isDetailsUpdate && !this.discardDetailTab){
      this.selectedTab = "Sharing Options";
      this.isDetailModalOpen = true;
      this.template.querySelector("lightning-tabset").activeTabValue = "Participant Details";
    }else if(this.isMedicalDetailChanged && this.discardMedicalTab == false){
      this.selectedTab = "Sharing Options";
      this.isMedicalModalOpen = true;
      this.template.querySelector("lightning-tabset").activeTabValue = "Health Information";
     
      
    }else{
      if(!this.isSharingOptionsChanged || !this.isSPModalOpen) {
        this.isSharingTab = true;
        this.isParticipantDetail = false;
        this.discardSharingTab = false;
        this.fetchAccessLevel();
        this.template.querySelector("c-pir_sharing-Option").fetchInitialDetails();      

      }
      
      
    }
 }
 handleMedicalTab() {
  if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) { 
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
    this.selectedTab = "Health Information";
    this.isModalOpen = true;
    this.isMedicalTab = false;
  }else if(this.isDetailsUpdate && !this.discardDetailTab){
    this.selectedTab = "Health Information";
    this.isDetailModalOpen = true;
    this.template.querySelector("lightning-tabset").activeTabValue = "Participant Details";
  }else if(this.isSharingOptionsChanged && !this.discardSharingTab){
    this.selectedTab = "Health Information";
    this.isSPModalOpen = true;
    this.template.querySelector("lightning-tabset").activeTabValue = "Sharing Options";
  }else if(this.isMedicalModalOpen == false){ 
    this.isSharingTab = false;
    this.selectedTab = "Health Information"; 
    this.isMedicalTab = true;
    this.disableMedicalSaveButton = true;
     this.isParticipantDetail = false;
    this.template.querySelector("c-medicalinformation").doSelectedPI();  
   
  }else{
    this.isSharingTab = false;
    this.isMedicalTab = true;
    this.isParticipantDetail = false;
    //this.disableMedicalSaveButton = true;
  }
 }
 isTelevisitTab=false;
 handleTelevisitTab(){
   this.selectedTab = 'Televisit';
    //this.isStatusDetail=false;
    this.isMedicalTab=false;
    this.isParticipantDetail=false;
    //this.isSharingTab=false;
    this.isTelevisitTab= true;
    
 }

 @api
 doSaveMedical(){
  this.isMedicalModalOpen = false;
  this.isMedicalDetailChanged = false;
  this.discardMedicalTab = false;
  this.template.querySelector("c-medicalinformation").dosaveMedicalInfo();
  this.disableMedicalSaveButton = true;
 }


  handleDiscard(){
    this.discardTab = true;
    this.isModalOpen = false;
    this.template.querySelector("c-pir_participant-Status-Details").doSelectedPI();
    this.template.querySelector("lightning-tabset").activeTabValue =  this.selectedTab;
  }
  handleCloseModal(){
    this.selectedTab = "Status Details";
    this.isModalOpen = false;
  }
  handleDiscardMedical(){
    this.discardMedicalTab = true;
    this.isMedicalModalOpen = false;
    this.template.querySelector("c-medicalinformation").doSelectedPI();
    this.template.querySelector("lightning-tabset").activeTabValue =  this.selectedTab;
  }

  handleCloseModalMedical(){
    this.selectedTab = "Health Information";
    this.isMedicalModalOpen = false;
  }


  handleTabs(){
    this.statusDetailValueChanged = false;
    this.template.querySelector("lightning-tabset").activeTabValue =  this.selectedTab;
  }
  @api
  docallheader() {
    this.template.querySelector("c-pir_participant-header").doSelectedPI();
  }
  @api
  docallparticipantstatusdetail() {
    this.template
      .querySelector("c-pir_participant-Status-Details")
      .doSelectedPI();
  }
  showErrorToast(msg) {
    const evt = new ShowToastEvent({
      title: msg,
      message: msg,
      variant: "error",
      mode: "dismissible",
    });
    this.dispatchEvent(evt);
  }

  fetchAccessLevel() {
    if(this.lststudysiteaccesslevel && this.selectedPE) {
        if(this.lststudysiteaccesslevel[this.selectedPE.siteId]) {
          this.delegateLevel = this.lststudysiteaccesslevel[this.selectedPE.siteId];
        }
    }
}
handlestatusspinner(){
  this.saving ? this.saving=false:this.saving=true
}
  hanldeProgressValueChange(event){
    this.progressValue=event.detail;
    this.template.querySelectorAll(".linenone").forEach(function (L) {
      L.classList.add("boxShadownone");
  });
 
  }
  exportDisable=true;
  handleCount(event){
    this.countValue=event.detail;
    if(this.countValue> 0){
      this.ondisableButton=false;
      this.exportDisable=false;
    }
    else{
      this.ondisableButton=true;
      this.exportDisable=true;
    }
    if(this.countValue>40){
      this.showErrorToast('Error');
    }
  }
  exportItem=false;addParticipant=false;siteAccessLevels;bulkStatusSpinner=false;
  handleDropLabel(event){
    this.dropdownLabel=event.detail;
    if(this.dropdownLabel=='Add New Participant'){
        this.addParticipant = true;
        this.studysiteaccess = true;
    }else{
      if(this.dropdownLabel=='Export'){
        this.exportItem=true;
      }
      else{
        this.exportItem=false;
      }
    }
  }
  handlepopup(event){
    this.openpopup=event.detail;
    
  }
  handleCloseParticipant(){
    this.addParticipant = false;
    this.selectedSite = '';
    this.selectedStudy = '';
    this.template.querySelector("c-pir_participant-list").hideCheckbox();
  }
  get handleContinue(){
      if(this.selectedStudy !='' && this.selectedSite !='' && this.selectedStudy != null && this.selectedSite !=null){
         return false;
      }else{
         return true;
      }
  }
  handleNewParticipant(){
      this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            pageName: 'add-patient'
        },
        state: {
            'id' : this.selectedStudy,
            'ssId': this.selectedSite,
            'participantVeiwRedirection': true
        }
    });
  }
  showErrorToast(msg) {
    const evt = new ShowToastEvent({
        title: msg,
        message: msg,
        variant: 'error',
        duration:400,
        mode: 'dismissible'
    });
    this.dispatchEvent(evt);
}
  onCancel(){
    this.progressValue=false;
    this.cancelCheckbox=false;
    this.ondisableButton=true;
    this.exportDisable=true;
    this.template.querySelectorAll(".linenone").forEach(function (L) {
        L.classList.remove("boxShadownone");
    });
  
    this.template.querySelector("c-pir_participant-list").hideCheckbox();
    this.removeParticipant=false;
    this.countValue=0;
    this.template.querySelector("c-pir_participant-pagination").goToStart();    
  }
  handleExportSelcted(event){
    this.template.querySelector("c-pir_participant-list").handleExport();
  }

  handleExportAll(event){
    this.template.querySelector("c-pir_participant-list").getExportAll();
  }
  handleresetparent(event){
    this.onCancel();
  }
  handleReset(event){
      this.countValue = 0;
      this.ondisableButton = true;
      this.saving = false;
      this.isStatusChange = false;
    }
    get notesLabel() {
        if(this.newStatusSelected == "Unable to Reach" && this.selectedreason == ""){
          this.bulkButtonValidation();
          return this.utilLabels.PG_ACPE_L_Notes_Required;
        }else if(this.newStatusSelected == "Contacted - Not Suitable" && this.selectedreason == ""){
          this.bulkButtonValidation();
          return this.utilLabels.PG_ACPE_L_Notes_Required;
        }else if(this.notesNeeded.includes(this.selectedreason)){
          this.bulkButtonValidation();
          return this.utilLabels.PG_ACPE_L_Notes_Required;
         }else {
           this.bulkButtonValidation();
          return this.utilLabels.PG_ACPE_L_Notes_Optional;
        }
    }
    changeInputValue(event) {
      let datavalue = event.target.dataset.value;
      if (event.target.dataset.value === "additionalNotes") {
        this.additionalNote = event.target.value;
        this.bulkButtonValidation();
      }
      if (event.target.dataset.value === "FinalConsent") {
        this.finalConsentvalue = event.target.checked;
        this.bulkButtonValidation();
      }
    }
    bulkButtonValidation(){
      let notes = this.additionalNote.trim();
      let btnValidationSuccess = false;
      let validationList = [];
       
      //1.
      if (this.notesNeeded.includes(this.selectedreason)) {
          if (notes != null && notes != "" && notes.length != 0) {
            btnValidationSuccess = true;
            validationList.push(btnValidationSuccess);
          } else {
            btnValidationSuccess = false;
            validationList.push(btnValidationSuccess);
          }
      }
      //2.
      if(this.finalConsentRequired == true){
         if(this.finalConsentvalue == true){
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
         }else{
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
         }
      }
      //3.
      if((this.newStatusSelected == "Unable to Reach" || this.newStatusSelected == "Contacted - Not Suitable") && this.selectedreason == ""){
        if (notes != null && notes != "" && notes.length != 0) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
  }

  if(validationList.includes(false)) {
    this.bulkSubmit = true;    
 }else {
   this.bulkSubmit = false;  
 }
}

handleReasonChange(event){
 if(event.target.value == null || event.target.value == ' '){
    this.selectedreason = '';
 }else{
   this.selectedreason = event.detail.value;
 }
}
isStatusChange= false;newStatusSelected='';oParticipantStatus='';studyID='';bulkSubmit=false;
additionalNote = '';finalConsent=false;finalConsentRequired = false;
handleStatusChanges(event){
 this.newStatusSelected = event.detail.newStatusSelected;
 this.oParticipantStatus = event.detail.oParticipantStatus;
 this.studyID = event.detail.studyId;
}
reasoneoptions = [];selectedreason='';notesNeeded = [];isReasonEmpty = false;finalConsentvalue=false;
  doAction(){
    if(this.dropdownLabel=='Change Status'){
      this.notesNeeded = [];this.additionalNote = '';this.selectedreason = '';this.finalConsent=false;this.finalConsentRequired = false;
      this.bulkStatusSpinner = true;
      bulkstatusDetail({ newStatus: this.newStatusSelected, studyId: this.studyID })
     .then(result => {
         let reasons = result.reason;
         if(reasons != undefined){
           if(reasons.charAt(0) == ';'){
              reasons=reasons.substring(1);
           }
           let reasonList = reasons.split(";");
           let trans_reasonopts = [];
           for (let i = 0; i < reasonList.length; i++) {
             let outcomeReason = reasonList[i];
             if (outcomeReason.endsWith("*")) {
                 outcomeReason = outcomeReason.substring(0,outcomeReason.length - 1);
                 if(outcomeReason.length != 1){
                   this.notesNeeded.push(outcomeReason);
                 }else{
                   this.notesNeeded.push('BLANK');
                 }
             }
             trans_reasonopts.push({
               label: this.utilLabels[outcomeReason],
               value: outcomeReason
             });
            
           }
           this.reasoneoptions = trans_reasonopts;
           if(this.newStatusSelected == "Contacted - Not Suitable"){
             this.selectedreason ='';
           }else{
             this.selectedreason =  reasonList[0];
           }
           this.isReasonEmpty = false;
         }else{
            this.selectedreason ='';
            this.isReasonEmpty = true;
         }
         if(result.finalConsent && (result.Step == 'PWS_Randomization_Card_Name' || result.Step == 'PWS_Enrolled_Card_Name')){
             this.finalConsent = result.finalConsent;
             if(this.newStatusSelected == 'Enrollment Success' || this.newStatusSelected == 'Randomization Success'){
                 this.finalConsentRequired = true;
             }
         }
         this.bulkStatusSpinner =false;
     })
     .catch(error => {
        console.log(error);
        this.bulkStatusSpinner = false;
        this.showErrorToast(error);  
     });
      this.isStatusChange=true;
    }
    else{
      this.openpopup=false;
    }
    if(this.dropdownLabel=='Send to DCT'){
      this.template.querySelector("c-pir_participant-list").updateSendtoDCT();
      this.saving = true;
    }
    if(this.dropdownLabel=='Invite to Patient Portal'){
      this.template.querySelector("c-pir_participant-list").updateInvitetoPP();
      this.saving = true;
    }
    
  }
  handleBulkUpdate(){
    this.template.querySelector("c-pir_participant-list").updateBulkStatusChange();
    this.saving = true;
  }
  handleCloseStatus(){
    this.isStatusChange = false;
  }
  checkFormChanges(event) {
    this.isSharingOptionsChanged = true;
    this.isSharingTab = true;
  }
  
  handleNotification(event) {
    if(event.detail.action === 'close') {
      this.selectedTab = "Sharing Options";       
      this.isSharingTab = true;
      this.isSPModalOpen = false;
    } else if(event.detail.action === 'discard') {       
      this.isSharingTab = false;
      this.isSharingOptionsChanged = false;
      this.isSPModalOpen = false;
      this.discardSharingTab = true;
      this.template.querySelector("lightning-tabset").activeTabValue =  this.selectedTab;
    }

  }
  resetFormChanges() {
    this.isSharingOptionsChanged = false;     
    //this.isSharingTab = true;
  }
  disableAll(){    
    this.template.querySelector(".pir-parent").classList.toggle("disable-click");
  }
  handleresetpagination(event){
    this.initialLoad = true;
    this.template.querySelector("c-pir_participant-pagination").goToStart();
  }
  settopageone(event){
    //this.initialLoad = true;
    this.template.querySelector("c-pir_participant-pagination").goToStart();
  }

}