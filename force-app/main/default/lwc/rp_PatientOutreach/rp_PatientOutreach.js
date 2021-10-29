import { LightningElement, wire, api, track } from "lwc";
import fetchOutreachInfo from "@salesforce/apex/rpPatientOutreachController.fetchOutreachInfo";
import peBulkValidate from "@salesforce/apex/rpPatientOutreachController.peBulkValidate";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPatientInfo from "@salesforce/apex/rpPatientOutreachController.getPatientInfo";

export default class Rp_PatientOutreach extends LightningElement {
  @api peIds;
  studies = [];
  studyInfoMap = {};
  outreachInfo;
  loaded = false;
  singleStudy = false;
  singleStudyName = false;
  validation=false;
  @track outreachSuccessMessage = "";
  @track outreachFailureInfo = [];
  connectedCallback() {
    fetchOutreachInfo({ peIds: this.peIds })
      .then((result) => {
        if (result.length == 1) {
          this.singleStudy = true;
          this.singleStudyName = result[0].Study_Code_Name__c;
        } else {
          this.singleStudy = false;
        }
        for (var i = 0; i < result.length; i++) {
          if (i == 0) {
            result[i].cssClass = "slds-tabs_default__item slds-is-active";
            this.outreachInfo = result[i].Patient_Outreach_Info__c;
          } else {
            result[i].cssClass = "slds-tabs_default__item";
          }
          this.studies.push(result[i]);
          this.studyInfoMap[result[i].Id] = result[i].Patient_Outreach_Info__c;
          console.log(JSON.stringify(this.studies));
          this.loaded = true;
        }
      })
      .catch((error) => {
        console.log(error.message);
      });
  }
  scroll = 400;
  leftFn() {
    var t = this.template.querySelector('[data-id="tabsBox"]');
    t.addEventListener("click", function () {
      this.scroll({
        left: 0,
        top: 0,
        behavior: "smooth"
      });
    });
    //for(var i=0;i<this.scroll;i++){
    t.scrollLeft = t.scrollLeft + this.scroll;
    //}
  }
  rightFn() {
    var t = this.template.querySelector('[data-id="tabsBox"]');
    t.addEventListener("click", function () {
      this.scroll({
        left: 0,
        top: 0,
        behavior: "smooth"
      });
    });
    //for(var i=0;i<this.scroll/2;i++){
    t.scrollLeft = t.scrollLeft - this.scroll;
    //}
  }
  changeTab(event) {
    var studySelected = event.target.dataset.item;
    this.outreachInfo = this.studyInfoMap[studySelected];

    var tabs = this.template.querySelectorAll(".slds-tabs_default__item");
    for (var i = 0; i < tabs.length; i++) {
      if (studySelected == tabs[i].dataset.item) {
        tabs[i].classList.add("slds-is-active");
      } else {
        tabs[i].classList.remove("slds-is-active");
      }
    }
  }
  doValidation() {
    this.loaded = false;
	let isBulkPes = Array.isArray(this.peIds);
    let totalPeIds = 0;
    isBulkPes ? (totalPeIds = this.peIds.length)  : (totalPeIds = 1);
    let successPeIds = 0;
			
    let failedPeIds = 0;
    let singlepatientId = "";
    peBulkValidate({
      listOfPeIds: this.peIds
    }).then((validationResult) => {
      if (validationResult) {
        for (let patientId in validationResult) {
						
          if (validationResult.hasOwnProperty(patientId)) {
            failedPeIds = failedPeIds + 1;
            let errmsgrec = {
              patientId: patientId,
              validationMsg: validationResult[patientId]
            };
            this.outreachFailureInfo.push(errmsgrec);
          }
        }
        successPeIds = totalPeIds - failedPeIds;
      }
      if (this.outreachFailureInfo.length <= 0 && !isBulkPes) {
					
            const disasbleoutreach = new CustomEvent('disableoutreachbtn');
            this.dispatchEvent(disasbleoutreach);
        // No error messages=> All success, for single PE Id.
        getPatientInfo({
          peId: this.peIds
        }).then((res) => {
          this.closeUploadModal();
					//	this.validation = false;
						
          this.showNotification(
            "Success",
            res[0].Patient_ID__c + " was successfully sent an Outreach mail.",
            "success",
            "dismissable"
          );
        });
      } else if (this.outreachFailureInfo.length <= 0) {
        // No error messages=> All success for bulk
				
        successPeIds = this.peIds.length;
      }
      this.outreachSuccessMessage =
        successPeIds + " out of " + totalPeIds + " Successfully Submitted!";
    });
    	this.validation = true;
  }
  closeUploadModal() {
    this.dispatchEvent(new CustomEvent("close"));
  }
  showNotification(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }
}