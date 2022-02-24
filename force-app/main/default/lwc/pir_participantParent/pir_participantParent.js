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

  connectedCallback() {
    getStudyAccessLevel()
      .then((result) => {
        console.log(">>>result11>>" + JSON.stringify(result));
        this.lststudysiteaccesslevel = result;
        console.log(">>>lststudysiteaccesslevel>>" + JSON.stringify(this.lststudysiteaccesslevel));
      })
      .catch((error) => {
        this.error = error;
      });
  }
  get isStatusDetail(){
     if(this.selectedTab == "Status Details"){
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
    console.log("pe-parent" + JSON.stringify(this.selectedPE));
    console.log('>>siteid>>'+this.selectedPE.siteId);
    
    
    if(this.lststudysiteaccesslevel[this.selectedPE.siteId])
    {
       
      console.log('>>coming iff>>');
      console.log('>>syudyaccess>>'+this.lststudysiteaccesslevel[this.selectedPE.siteId]);
      if(this.lststudysiteaccesslevel[this.selectedPE.siteId] == 'Level 3'){
        this.isMedicalHistryAccess = false;
        console.log('>>2nf id>>'); 
      } 
    } 
     
    this.template.querySelector("c-pir_participant-header").selectedPE =this.selectedPE;
    this.template.querySelector("c-pir_participant-header").doSelectedPI();
    this.template.querySelector("c-pir_participant-Status-Details").selectedPE_ID = this.selectedPE.id;
    this.template.querySelector("c-pir_participant-Status-Details").doSelectedPI();
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
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
  checkStatusDetailChanges(event){ 
    this.statusDetailValueChanged = event.detail;
    if(event.detail){
      this.discardTab = false;
    }
  }
  handleStatusTab(){
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
    this.selectedTab = "Status Details";
  }
  handleParticipantTab() {
      if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) {
        this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
        this.selectedTab = "Participant Details";
        this.isModalOpen = true;
      }else{
        this.selectedTab = "Participant Details";
      }
  }
  handleSharingTab() {
    if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) {
      this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
      this.selectedTab = "Sharing Options";
      this.isModalOpen = true;   
    }else{
      this.template.querySelector("c-pir_sharing-option").selectedPE =this.selectedPE;
      this.template.querySelector("c-pir_sharing-option").fetchInitialDetails(); 
      this.selectedTab = "Sharing Options";
    }
 }
 handleMedicalTab() {
  if ((this.statusDetailValueChanged || this.disablebtn) && this.discardTab == false) {
    this.template.querySelector("lightning-tabset").activeTabValue = "Status Details";
    this.selectedTab = "Health Information";
    this.isModalOpen = true;
  }else{
    this.template.querySelector("c-medicalinformation").selectedPe = this.selectedPE.id;
    this.template.querySelector("c-medicalinformation").doSelectedPI();
    this.selectedTab = "Health Information";
  }
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