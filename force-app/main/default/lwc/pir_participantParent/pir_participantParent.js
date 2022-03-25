import { LightningElement, api } from "lwc";
import pirResources from "@salesforce/resourceUrl/pirResources";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getStudyAccessLevel from "@salesforce/apex/PIR_HomepageController.getStudyAccessLevel";

export default class Pir_participantParent extends LightningElement {
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
  backArrow = pirResources + "/pirResources/icons/triangle-left.svg";
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


  connectedCallback() {
    getStudyAccessLevel()
      .then((result) => {
        this.lststudysiteaccesslevel = result;
      })
      .catch((error) => {
        this.error = error;
      });
  }
  get isStatusDetail(){
    console.log('selectedtab-->'+this.selectedTab);
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
    
    if(this.lststudysiteaccesslevel[this.selectedPE.siteId])
    {
      console.log('>>syudyaccess>>'+this.lststudysiteaccesslevel[this.selectedPE.siteId]);
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
  pageChanged(event) {
    this.page = event.detail.page;
    this.template.querySelector("c-pir_participant-list").pageNumber =
      this.page;
    this.template.querySelector("c-pir_participant-list").fetchList();
  }
  recCountUpdate(event) {
    this.totalRecord = event.detail;
    if(this.totalRecord == 0){
      this.showZeroErr = true;
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
        console.log('>>in sharing else>>');this.selectedTab = "Sharing Options";
        console.log('stab1'+this.selectedTab);
        this.isSharingTab = true;
        this.isParticipantDetail = false;
        this.discardSharingTab = false;
        this.fetchAccessLevel();
        this.template.querySelector("c-pir_sharing-Option").fetchInitialDetails();      
        
        console.log('stab'+this.selectedTab);
      }
      
      
    }
 }
 handleMedicalTab() {
    console.log('stb-1medical->'+this.selectedTab);
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
    console.log('stb-1->'+this.selectedTab);
    this.isMedicalTab = true;
    this.isParticipantDetail = false;
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
    console.log('>>selectedTab>>'+this.selectedTab);
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
    console.log('fetchAccessLevel:'+this.delegateLevel);
  }
  hanldeProgressValueChange(event){
    this.progressValue=event.detail;
    console.log('this.progressValue',this.progressValue);
  }
  handleCount(event){
    this.countValue=event.detail;
    if(this.countValue> 0){
      this.ondisableButton=false;
    }
    else{
      this.ondisableButton=true;
    }
    console.log('this.countValue',this.countValue);
  }
  handleDropLabel(event){
    this.dropdownLabel=event.detail;
    console.log('this.dropdownLabel',this.dropdownLabel);
  }
  handlepopup(event){
    this.openpopup=event.detail;
    
    console.log('this.openpopup',this.openpopup);
  }
  onCancel(){
    this.progressValue=false;
    //this.selectedPI();
    console.log('this.selectedPE',this.selectedPE);
    this.cancelCheckbox=false;
    console.log('this.cancelCheckbox',this.cancelCheckbox);
    this.template.querySelector("c-pir_participant-list").hideCheckbox();
    this.removeParticipant=false;
    this.countValue=0;
  }
  
  doAction(){
    if(this.dropdownLabel=='Change Status'){
    this.openpopup=true;
    }
    else{
      this.openpopup=false;
    }
  }

  checkFormChanges(event) {
    console.log('FormChangeEvent:'+JSON.stringify(event.detail));
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

}