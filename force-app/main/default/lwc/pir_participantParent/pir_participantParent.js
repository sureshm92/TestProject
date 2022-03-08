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
    this.discardTab = false;
    this.statusDetailValueChanged = false;
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details"; 
    this.selectedTab = "Status Details";
    this.isMedicalTab = false;
    
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
  pageChanged(event) {
    this.page = event.detail.page;
    this.template.querySelector("c-pir_participant-list").pageNumber =
      this.page;
    this.template.querySelector("c-pir_participant-list").fetchList();
  }
  recCountUpdate(event) {
    this.totalRecord = event.detail;
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
    this.disableMedicalSaveButton = false;
    this.isMedicalDetailChanged = true;
    this.discardMedicalTab = false;
  }
  checkStatusDetailChanges(event){ 
    this.statusDetailValueChanged = event.detail;
    if(event.detail){
      this.discardTab = false;
    }
  }
  handleStatusTab(){
    this.isMedicalTab = false;
    if(this.isMedicalDetailChanged && this.discardMedicalTab == false){
     
      this.selectedTab = "Status Details";
      this.isMedicalModalOpen = true;
      this.template.querySelector("lightning-tabset").activeTabValue = "Health Information";
    }else{
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
    this.selectedTab = "Status Details";
    
    }
  }
  handleParticipantTab() {
    this.isMedicalTab = false;
      if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) {
        this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
        this.selectedTab = "Participant Details";
        this.isModalOpen = true;
      }else if(this.isMedicalDetailChanged && this.discardMedicalTab == false){
        
        this.selectedTab = "Participant Details";
        this.isMedicalModalOpen = true;
        this.template.querySelector("lightning-tabset").activeTabValue = "Health Information";
      }else{
        this.selectedTab = "Participant Details";
      }
  }
  handleSharingTab() {
    this.isMedicalTab = false;
    if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) {
      this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
      this.selectedTab = "Sharing Options";
      this.isModalOpen = true;   
    }else if(this.isMedicalDetailChanged && this.discardMedicalTab == false){
      this.selectedTab = "Sharing Options";
      this.isMedicalModalOpen = true;
      this.template.querySelector("lightning-tabset").activeTabValue = "Health Information";
     
      
    }else{
      console.log('>>in sharing else>>');this.selectedTab = "Sharing Options";
      console.log('stab1'+this.selectedTab);
      //this.template.querySelector("c-pir_sharing-Option").selectedPE =this.selectedPE;
      this.template.querySelector("c-pir_sharing-Option").fetchInitialDetails(); 
      
      console.log('stab'+this.selectedTab);
      
      
    }
 }
 handleMedicalTab() {
  console.log('stb-1->'+this.selectedTab);
  if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) { 
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
    this.selectedTab = "Health Information";
    this.isModalOpen = true;
    this.isMedicalTab = false;
  }else if(this.isMedicalModalOpen == false){ 
    this.selectedTab = "Health Information"; 
    console.log('stb-1->'+this.selectedTab);
    this.isMedicalTab = true;
    this.disableMedicalSaveButton = true;
    this.template.querySelector("c-medicalinformation").doSelectedPI();  
   
  }else{
    this.isMedicalTab = true;
    this.disableMedicalSaveButton = true;
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
}