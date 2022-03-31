import { LightningElement, api, wire } from 'lwc';
import getListViewData from '@salesforce/apex/PIR_HomepageController.getListViewData';
import updateParticipantData from '@salesforce/apex/PIR_BulkActionController.updateParticipantData';
import createUserForPatientProtal from '@salesforce/apex/PIR_BulkActionController.createUserForPatientProtal';
import pirResources from '@salesforce/resourceUrl/pirResources';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import RH_RP_No_Item_To_Display from '@salesforce/label/c.RH_RP_No_Item_To_Display';
import Records_sent_to_SH from '@salesforce/label/c.Records_sent_to_SH';
import ParticipantLimit from '@salesforce/label/c.ParticipantLimit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPEData from '@salesforce/apex/PIR_HomepageController.getPEData';
import Janssen_Community_Template_Name from '@salesforce/label/c.Janssen_Community_Template_Name';
import Records_all_invited from '@salesforce/label/c.Records_all_invited';

export default class Pir_participantList extends LightningElement {    
    filterIcon = pirResources+'/pirResources/icons/filter.svg';
    currentPageReference = null; 
    urlStateParameters = null;
    @api noRecords = false;
    @api cancelCheck;
    dropDownChange=false;
    valueChecked=false;
    @api dropDownLabel="Actions";
    enableStatus=false;
    dctCheck=false;
    selectedCheckboxes = [];
    pagecountCheck=0;
    selectall = false;
    @api per;
    @api allowshvalue;
    showDCT=false;
    showPP=false;
    saving=false;
    showStatus=false;
    selectedStatusList;
    selectedStatusValue = 'Received';isPPFiltered = false;
    @api get fetch(){
        return true;
    }
    set fetch(val){
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
        }).then(() => {
            this.fetchList(); 
        }).catch((error) => {
             console.log('Error: ' + error.message);
             console.log('Error: ' + error.stack);
        });
    }
    /* Params from Url */
    urlStudyId = null;
    urlSiteId = null;

    label = {
        RH_RP_No_Item_To_Display,
        Janssen_Community_Template_Name,
        Records_sent_to_SH,
        ParticipantLimit,
        Records_all_invited
    };
    
    @api isCheckboxhidden=false;
    activeCheckboxesCount=0;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
    @api hideCheckbox(){
        this.isCheckboxhidden=false;
        this.selectedCheckboxes=[];
        this.dropDownLabel="Actions";
        this.dropDownChange=false;
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.remove("slds-p-bottom--x-small");
        });
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.add("slds-p-bottom--x-large");
        });
        if(this.isPPFiltered == true){
            this.isPPFiltered = false;
            this.totalRecordCount = -1;
            this.isResetPagination = true; 
            this.fetchList();
        }
        
    }

    setParametersBasedOnUrl() {
       this.urlStudyId = this.urlStateParameters.id || null;
       this.urlSiteId = this.urlStateParameters.siteId || null;
    }
    totalRecordCount = -1;
    @api pageNumber = 1;
    participantList;
    selectedParticipantList;
    studyIdlist=null;
    siteIdlist=null;
    iconHighRisk =pirResources+'/pirResources/icons/status-alert.svg';
    iconHighPriority = pirResources+'/pirResources/icons/arrow-up.svg';
    iconActionReq = pirResources+'/pirResources/icons/bell.svg';    
    err='';
    peMap = new Map();
    peCurrentIndexMap = new Map();
    selectedIndex = -1 ;
    @api selectedPE;
    @api communityTemplate ='';
    backSwap = false;
    keypress = false;
    keyScope = '';
    yesHighPriority=[];
    noHighPriority=[];

    connectedCallback(){   
        // this.template.querySelectorAll(".dropsize").forEach(function (L) {
        //     L.classList.add("slds-p-bottom--x-large");
        // });     
       if(this.urlStudyId !== null && this.urlSiteId !== null){
        this.studyIdlist = [];
        this.studyIdlist.push(this.urlStudyId);
        this.siteIdlist = [];
        this.siteIdlist.push(this.urlSiteId);   
       
       }
        // loadScript(this, RR_COMMUNITY_JS)
        // .then(() => {
        //     this.communityTemplate = communityService.getCurrentCommunityTemplateName();
        // }).then(() => {
        //     this.fetchList(); 
        // }).catch((error) => {
        //      console.log('Error: ' + error.message);
        //      console.log('Error: ' + error.stack);
        // });
     
    }   
    rendered=false;
    renderedCallback(){
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.add("slds-p-bottom--x-large");
        });
        if(!this.rendered){
            this.rendered=true;
            this.setKeyAction();  
        }        
        this.keyScope += 'ren';        
    }
    @api fetchList(){
        this.selectall = false;
        var selectCount=0;
        var enableCount=0;
        this.participantList=null;
        getListViewData({pageNumber : this.pageNumber, totalCount : this.totalRecordCount, studyIdlist : this.studyIdlist, siteIdlist : this.siteIdlist, sponsorName  : this.communityTemplate, selectedStatusList : this.selectedStatusList, isPPFiltered: this.isPPFiltered })
        .then(result => {
            this.participantList = result.listViewWrapper;
            if(result.listViewWrapper.length>0){
                this.noRecords = false;
                if(!this.backSwap){
                    this.selectedIndex = 0;
                    this.selectedPE=result.listViewWrapper[0];   
                }else{
                    this.backSwap = false;
                    this.selectedIndex = result.listViewWrapper.length -1;
                    this.selectedPE=result.listViewWrapper[result.listViewWrapper.length -1];   
                }

            }else{
                this.noRecords = true;
            }
            if(this.selectedStatusList!=null && (this.selectedStatusValue!='All Active Statuses' && this.selectedStatusValue!= 'All Inactive Statuses') ){
                this.showStatus=true;
            }
            else{
                this.showStatus=false;
            }
            this.showDCT=false;
            for(var i=0 ; i<result.listViewWrapper.length;i++){
                this.participantList[i].cs = 'tooltiptextBottom slds-align_absolute-center';
                if(i>4)
                    this.participantList[i].cs = 'tooltiptextTop slds-align_absolute-center';
                
                this.participantList[i].check = this.selectedCheckboxes.includes(this.participantList[i].id);
                
                if(this.participantList[i].check){
                    selectCount++;
                }
                this.participantList[i].getlabel=this.dropDownLabel;
                
                this.participantList[i].showActionbtnDisabled = true;
                
                if(this.participantList[i].promotetoSH &&  this.participantList[i].isAllowedForSH)
                {
                    this.participantList[i].showActionbtnDisabled = false;
                    enableCount++;
                }
                else  if(this.participantList[i].promotetoSH &&  !this.participantList[i].isAllowedForSH)
                {
                    this.participantList[i].showActionbtnDisabled = true;
                }
                else{
                    this.participantList[i].showActionbtnDisabled = false;
                }
                if(this.participantList[i].isAllowedForSH){
                    this.showDCT=true;
                }
               
                this.peMap.set(result.listViewWrapper[i].id,result.listViewWrapper[i]);
                this.peCurrentIndexMap.set(i,result.listViewWrapper[i].id);
                
            }
            this.showPP = result.isEnablePP;
            if(selectCount==this.participantList.length){
                this.selectall = true;
            }
            if(selectCount==enableCount && selectCount!=0 &&  enableCount!=0){
                this.selectall = true;
            }
            
            if(this.totalRecordCount !=  result.totalRecordCount){
                this.totalRecordCount =  result.totalRecordCount;
                const updateCount = new CustomEvent("reccountupdate", {
                    detail: this.totalRecordCount
                });
                this.dispatchEvent(updateCount);
            }
            if(!this.siteIdlist){
                this.siteIdlist = result.siteIdlist;
            }
            if(!this.studyIdlist){
                this.studyIdlist = result.studyIdlist;
            }
            this.saving = false;       
            window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(this.changeSelected.bind(this), 50); 
        })
        .catch(error => {
            this.err = error;
            this.saving = false;
            console.log('Error : '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
            this.participantList = undefined;
        });
       
    }
    @api updateSendtoDCT(){
        updateParticipantData({peIdList : this.selectedCheckboxes})
        .then(result => {
            this.saving = true;
            this.showSuccessToast(this.label.Records_sent_to_SH);
            this.selectedCheckboxes = [];
            this.totalRecordCount = -1;
            this.isResetPagination = true;
            this.fetchList();
            const selectedEvent = new CustomEvent("resetcount");
            this.dispatchEvent(selectedEvent); 
        })
        .catch(error => {
            this.err = error;
            console.log('Error new: '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
        });
    }
    @api updateInvitetoPP(){    
        createUserForPatientProtal({peId : this.selectedCheckboxes, sendEmails: true})
        .then(result => {
            this.saving = true;
            this.showSuccessToast(this.selectedCheckboxes.length+' '+this.label.Records_all_invited);
            this.selectedCheckboxes = [];
            this.totalRecordCount = -1;
            this.isResetPagination = true;
             const gotofirstEvent = new CustomEvent("gotofirst");
             this.dispatchEvent(gotofirstEvent); 
             
             const resetcountEvent = new CustomEvent("resetcount");
             this.dispatchEvent(resetcountEvent); 
            
        })
        .catch(error => {
            this.err = error;
            console.log('Error new: '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
        });
    }
    setKeyAction(){
        this.template.querySelector('.keyup').addEventListener('keydown', (event) => {                  
            var name = event.key; 
            if((name=='ArrowDown' || name=='ArrowUp')){
                this.keypress = true;    
                this.keyScope = 'down';  
                event.preventDefault();
                event.stopPropagation();
                var updateSelected=false;
                if(name=='ArrowDown' ) {
                    if( this.selectedIndex < (this.participantList.length - 1)){
                        this.selectedIndex++;
                        updateSelected=true;
                    }else if(this.selectedIndex == (this.participantList.length - 1)){
                        //goto to next page
                        const pageswap = new CustomEvent("pageswap", {
                            detail: "next"
                        });
                        this.dispatchEvent(pageswap); 
                    }
                }
                if(name=='ArrowUp') {
                    if( this.selectedIndex>0){
                        this.selectedIndex--;
                        updateSelected=true;
                    }else if(this.selectedIndex == 0){
                        //goto to previous page
                        if(this.pageNumber != 1){
                            this.backSwap = true;
                        }
                        const pageswap = new CustomEvent("pageswap", {
                            detail: "prev"
                        });
                        this.dispatchEvent(pageswap); 
                    }
                }
                if(updateSelected){
                    this.changeSelected();
                }
            }
        }, false);
    
        this.template.querySelector('.keyup').addEventListener('keyup', (event) => {
            var name = event.key;
            if((name=='ArrowDown' || name=='ArrowUp')){
                const selectedEvent = new CustomEvent("selectedpevaluechange", {
                    detail: this.selectedPE
                });
                this.dispatchEvent(selectedEvent);              
                this.keypress = false;
            }
        }, false);
    }
    showSuccessToast(messageRec) {
        const evt = new ShowToastEvent({
            title: 'Success Message',
            message: messageRec,
            variant: 'success',
            duration:400,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    
    handleMouseSelect(event){
        const mToggle = new CustomEvent("mtoggle", {
            detail: ""
        });
        this.dispatchEvent(mToggle); 
        if(this.selectedIndex != event.currentTarget.dataset.id){
            this.selectedIndex = event.currentTarget.dataset.id;
            this.changeSelected();
        }
    }
    changeSelected(){
        this.keyScope += 'chsec';
        if(this.selectedIndex != -1){
            var cards = this.template.querySelectorAll('.list-card');
            for(var j = 0; j < cards.length; j++){
                if(j==this.selectedIndex){
                    cards[j].classList.add("selected");
                    cards[j].focus();
                    this.selectedPE= this.peMap.get(this.peCurrentIndexMap.get(j)); 
                    if((!this.keypress) || this.keyScope == 'downrenrenchsec'){
                        const selectedEvent = new CustomEvent("selectedpevaluechange", {
                         detail: this.selectedPE
                        });
                        this.dispatchEvent(selectedEvent); 
                        this.keypress = false;
                    }
                }
                else{
                    cards[j].classList.remove("selected");
                }
            }
        }
        if(this.isResetPagination)
            this.resetPagination();
    }
    get pageLimit(){
        return this.pageNumber>200;
    }
    get options() {
        return [
            { label: 'Received', value: 'Received' },
            
        ];
    }
    
    handleChange(event) {
        this.value = event.detail.value;
        this.enableStatus=false;
    }
    handlenewOnSelect(event){
        
        
        var selectedVal=event.target.dataset.id;
        
        this.dropDownLabel=selectedVal;
        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.remove("slds-is-open");
        });
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.remove("slds-p-bottom--x-large");
        });
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.add("slds-p-bottom--x-small");
        });
        
        if(selectedVal != 'Add New Participant'){ 
            this.dropDownChange=true; 
            this.isCheckboxhidden=true;
        }else{
            this.isCheckboxhidden=false;
        }
        if(event.target.dataset.id == 'Invite to Patient Portal'){
            this.isPPFiltered = true;
            this.saving = true;
            this.totalRecordCount = -1;
            this.isResetPagination = true;
            this.pageNumber = 1;
            this.fetchList();
        }
        
        
        if( this.dropDownLabel=='Change Status'){
            this.enableStatus=true;
        }
        else{
            this.enableStatus=false;
        }

        if( this.dropDownLabel=='Send to DCT'){
            this.dctCheck=true;
        }
        else{
            this.dctCheck=false;
        }


        if(this.dropDownLabel != 'Add New Participant'){
            const selectedEvent = new CustomEvent("progressvaluechange", {
                detail: this.isCheckboxhidden
            });
            this.dispatchEvent(selectedEvent);
        }
          const selectedEventnew = new CustomEvent("droplabel", {
            detail: this.dropDownLabel
          });
          this.dispatchEvent(selectedEventnew); 
    }
    opendropdown(event){
        
        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.toggle("slds-is-open");
        });
        
    }
    handleonblur(event){
        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.remove("slds-is-open");
        });
    }
   
    handleCheckChange(event){
        if(event.target.checked==true) {
            this.activeCheckboxesCount++;
            if(this.selectedCheckboxes.length>=0 && this.selectedCheckboxes.length<40){
            this.selectedCheckboxes.push(event.target.getAttribute("data-value"));
            }
            else{
                event.target.checked=false;
                this.showErrorToast(this.label.ParticipantLimit);
            }
        } else  {
            this.activeCheckboxesCount--;
            var index=this.selectedCheckboxes.indexOf(event.target.getAttribute("data-value"));
            this.selectedCheckboxes.splice(index,1);
            this.selectall=false;
        }
  

        const selectedEvent = new CustomEvent("countvaluecheckbox", {
            detail: this.selectedCheckboxes.length
          });
          this.dispatchEvent(selectedEvent); 
    }

    handleSelectAll(event){ 
        
        let i;
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]');
        this.selectall = event.target.checked;
        let countvalue = 0; let total = 0;
        for(let n=0; n<checkboxes.length; n++) {
            if(!this.selectedCheckboxes.includes(this.participantList[n].id))
            {
                countvalue = countvalue + 1;
            }
        }
        total = this.selectedCheckboxes.length + countvalue;
        if(total <= 40){
            for(i=0; i<checkboxes.length; i++) {
                if((!this.participantList[i].showActionbtnDisabled || this.dropDownLabel!='Send to DCT') ){
                    checkboxes[i].checked = event.target.checked;
                    if(checkboxes[i].checked==true){
                        if(!this.selectedCheckboxes.includes(this.participantList[i].id))
                        {
                            if(this.selectedCheckboxes.length>=0 && this.selectedCheckboxes.length<40){
                                this.selectedCheckboxes.push(this.participantList[i].id);
                            }
                            else{ 
                                event.target.checked=false;
                                checkboxes[i].checked=false;
                            }
                        }
                        
                    }
                    else{
                            if(this.selectedCheckboxes.length>=0 && this.selectedCheckboxes.length<=40){
                                var index=this.selectedCheckboxes.indexOf(this.participantList[i].id);
                                this.selectedCheckboxes.splice(index,1 );
                            }
                        }
                }
            }
            const selectedEvent = new CustomEvent("countvaluecheckbox", {
            detail: this.selectedCheckboxes.length
            });
            this.dispatchEvent(selectedEvent); 
        }else{
            this.selectall = false;
            event.target.checked=false;
            this.showErrorToast(this.label.ParticipantLimit);
        }
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

    //Filter
    showFilter = false;
    toggleFilter(){
        this.showFilter = !this.showFilter;
    }
    isResetPagination = false;
    handleFilterEvent(event){
        this.studyIdlist = event.detail.selectedStudy;
        this.siteIdlist = event.detail.selectedSite;
        this.urlStudyId = event.detail.selectedStudy;
        this.urlSiteId = event.detail.selectedSite;
        this.selectedStatusValue = event.detail.selectedStatus;
        var selectedStatusListOptions = [];
        if(event.detail.selectedStatus == 'All Active Statuses'){
            selectedStatusListOptions.push('Received');
            selectedStatusListOptions.push('Pre-review Passed');
            selectedStatusListOptions.push('Contact Attempted');
            selectedStatusListOptions.push('Successfully Contacted');
            selectedStatusListOptions.push('Screening In Progress');
            selectedStatusListOptions.push('Screening In Progress - Wash Out Period');
            selectedStatusListOptions.push('Screening Passed');
            selectedStatusListOptions.push('Enrollment Success');
            selectedStatusListOptions.push('Eligibility Passed');
            selectedStatusListOptions.push('Ready to Screen');
            selectedStatusListOptions.push('Randomization Success');
        }else if(event.detail.selectedStatus == 'All Inactive Statuses'){
            selectedStatusListOptions.push('Pre-review Failed');
            selectedStatusListOptions.push('Unable to Reach');
            selectedStatusListOptions.push('Contacted - Not Suitable');
            selectedStatusListOptions.push('Eligibility Failed');
            selectedStatusListOptions.push('Declined Consent');
            selectedStatusListOptions.push('Unable to Screen');
            selectedStatusListOptions.push('Withdrew Consent');
            selectedStatusListOptions.push('Screening Failed');
            selectedStatusListOptions.push('Withdrew Consent After Screening');
            selectedStatusListOptions.push('Enrollment Failed');
            selectedStatusListOptions.push('Randomization Failed');
            selectedStatusListOptions.push('Declined Final Consent');
        }else{
            selectedStatusListOptions.push(event.detail.selectedStatus);
        }
        this.isPPFiltered = false;
        this.selectedStatusList = selectedStatusListOptions;
        this.totalRecordCount = -1;
        this.toggleFilter();
        this.isResetPagination = true;
        this.fetchList();
        const selectEvent = new CustomEvent('resetparent', {
            detail: ''
        });
        this.dispatchEvent(selectEvent);
    }
    resetPagination(){ //reset pagination after fetch list method is finished
        var ttlcount = this.totalRecordCount;
        const selectEvent = new CustomEvent('resetpagination', {
            detail: ttlcount
        });
        this.dispatchEvent(selectEvent);
        this.isResetPagination = false;        
    }
   
}