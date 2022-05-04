import { LightningElement, api, wire } from 'lwc';
import getListViewData from '@salesforce/apex/PIR_HomepageController.getListViewData';
import getAvailableStatuses from '@salesforce/apex/PIR_HomepageController.getAvailableStatuses';
import updateParticipantStatus from '@salesforce/apex/PIR_HomepageController.updateParticipantStatus';
import updateParticipantData from '@salesforce/apex/PIR_BulkActionController.updateParticipantData';
import createUserForPatientProtal from '@salesforce/apex/PIR_BulkActionController.createUserForPatientProtal';
import exportSelected from '@salesforce/apex/PIR_BulkActionController.exportSelected';
import exportAll from '@salesforce/apex/PIR_BulkActionController.exportAll';
import pirResources from '@salesforce/resourceUrl/pirResources';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import RH_RP_No_Item_To_Display from '@salesforce/label/c.RH_RP_No_Item_To_Display';
import Send_to_DCT from '@salesforce/label/c.Send_to_DCT';
import Invite_to_Patient_Portal from '@salesforce/label/c.Invite_to_Patient_Portal';
import Records_sent_to_SH from '@salesforce/label/c.Records_sent_to_SH';
import ParticipantLimit from '@salesforce/label/c.ParticipantLimit';
import ListView_ChangeStatus from '@salesforce/label/c.ListView_ChangeStatus';
import Disclaimer_Text from '@salesforce/label/c.Disclaimer_Text';
import BTN_Export from '@salesforce/label/c.BTN_Export';
import RH_PP_Add_New_Participant from '@salesforce/label/c.RH_PP_Add_New_Participant';
import Change_Participant_Status from '@salesforce/label/c.Change_Participant_Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPEData from '@salesforce/apex/PIR_HomepageController.getPEData';
import fetchPreset from '@salesforce/apex/PIR_HomepageController.fetchPreset';
import getStudyStudySiteDetails from "@salesforce/apex/PIR_HomepageController.getStudyStudySiteDetails";
import setselectedFilterasDefault from "@salesforce/apex/PIR_HomepageController.setselectedFilterasDefault";
import Janssen_Community_Template_Name from '@salesforce/label/c.Janssen_Community_Template_Name';
import Records_all_invited from '@salesforce/label/c.Records_all_invited';
import pir_Search_Participants from '@salesforce/label/c.pir_Search_Participants';
import pir_Filter from '@salesforce/label/c.pir_Filter';
import pir_Presets from '@salesforce/label/c.pir_Presets';
import pir_Sort_By from '@salesforce/label/c.pir_Sort_By';
import Select from '@salesforce/label/c.Select';
import PG_MRZ_L_Last_Added from '@salesforce/label/c.PG_MRZ_L_Last_Added';
import PG_MRZ_L_Last_Modified from '@salesforce/label/c.PG_MRZ_L_Last_Modified';
import pir_Initial_Visit_Scheduled_Date_upcoming from '@salesforce/label/c.pir_Initial_Visit_Scheduled_Date_upcoming';
import pir_Initial_Visit_Scheduled_Date_past from '@salesforce/label/c.pir_Initial_Visit_Scheduled_Date_past';
import pir_No_Preset from '@salesforce/label/c.pir_No_Preset';
import RPR_Actions from '@salesforce/label/c.RPR_Actions';
import pir_Please_wait_as_your_page_loads from '@salesforce/label/c.pir_Please_wait_as_your_page_loads';
import Action_Required from '@salesforce/label/c.Action_Required';
import High_Priority from '@salesforce/label/c.High_Priority';
import High_Risk from '@salesforce/label/c.High_Risk';

export default class Pir_participantList extends LightningElement {    
    filterIcon = pirResources+'/pirResources/icons/filter.svg';
    editIcon = pirResources+'/pirResources/icons/pencil.svg';
    currentPageReference = null; 
    urlStateParameters = null;
    @api noRecords = false;
    @api cancelCheck;
    dropDownChange=false;
    valueChecked=false;
   
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
    @api showStatus=false;
    selectedStatusList;
    selectedStatusValue = 'Received';isPPFiltered = false;
    statusChangeList;statusSelected='';
    sortInitialVisit = false;
    disabledFilter = false;
    hideActiononSearch=false
    enteredSearchString = '';
    filterWrapper= {};
    @api maindivcls;
    @api get fetch(){
        return true;
    }
    set fetch(val){
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
        }).then(() => {
            //this.fetchList(); 
            this.fetchAllPreset(); 
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
        Records_all_invited,
        Send_to_DCT,
        Invite_to_Patient_Portal,
        Change_Participant_Status,
        ListView_ChangeStatus,
        BTN_Export,
        RH_PP_Add_New_Participant,
        Disclaimer_Text,
        pir_Search_Participants,
        pir_Filter,
        pir_Presets,
        pir_Sort_By,
        Select,
        PG_MRZ_L_Last_Added,
        PG_MRZ_L_Last_Modified,
        pir_Initial_Visit_Scheduled_Date_upcoming,
        pir_Initial_Visit_Scheduled_Date_past,
        pir_No_Preset,
        RPR_Actions,
        pir_Please_wait_as_your_page_loads,
        Action_Required,
        High_Priority,
        High_Risk
    }; 
    @api dropDownLabel=this.label.RPR_Actions;
    @api isCheckboxhidden=false;
    activeCheckboxesCount=0;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
    @api showAddParticipant = false;
    @wire(getStudyStudySiteDetails)
    participantAccess({ error, data }) {
      if (data){
            var siteAccessLevels = data.siteAccessLevels;
            var ctpListNoAccess = [];
            var studySiteMap = data;
            var studylist;
            var studyToStudySite;
            ctpListNoAccess = data.ctpNoAccess;
            var k = 0;var a = 0;
            var accesslevels = Object.keys(siteAccessLevels).length;
            if (studySiteMap.ctpMap) {
                var conts = studySiteMap.ctpMap;
                let options = [];
                var sites = studySiteMap.studySiteMap; 
                for (var key in conts) {
                    if(!ctpListNoAccess.includes(conts[key])){ 
                        var temp = sites[conts[key]];
                        let z = 0;
                        for (var j in temp) {
                             if(accesslevels == 0){
                                z=z+1;
                                a=a+1;
                             }else{
                                var level = siteAccessLevels[temp[j].Id];
                                if(level != 'Level 3' && level != 'Level 2'){
                                    z=z+1;
                                    a=a+1;
                                }
                             }
                        }
                        if(z != 0){
                            options.push({ label: key, value: conts[key] });
                            k=k+1;
                        }
                    }
                }
                studylist = options;
                if (studySiteMap.studySiteMap) {
                    studyToStudySite = studySiteMap.studySiteMap;
                }
            }
            if(k != 0 && a != 0){
                    this.showAddParticipant = true;
                    const selectedEvent = new CustomEvent("updatestudylist", {
                        detail: {
                            studylist: studylist,
                            siteAccessLevels: siteAccessLevels,
                            studyToStudySite: studyToStudySite
                        }
                      });
                    this.dispatchEvent(selectedEvent);
            }else{
                this.showAddParticipant = false;
            }
      } else if (error) {
          this.error = error;
      }
    }
    @api hideCheckbox(){
        this.isCheckboxhidden=false;
        this.selectedCheckboxes=[];
        this.dropDownLabel=this.label.RPR_Actions;
        this.dropDownChange=false;
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.remove("slds-p-bottom--x-small");
        });
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.add("slds-p-bottom--x-large");
        });
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.remove("participantStatus");
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
       if(this.urlStudyId != null && this.urlSiteId != null){
        this.filterWrapper.siteList = [];
        this.filterWrapper.studyList = [];
        this.filterWrapper.siteList.push(this.urlSiteId);
        this.filterWrapper.studyList.push(this.urlStudyId);
       }
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
       if(this.urlStudyId !== null && this.urlSiteId !== null){
        this.studyIdlist = [];
        this.studyIdlist.push(this.urlStudyId);
        this.siteIdlist = [];
        this.siteIdlist.push(this.urlSiteId);   
       }
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
    searchCounter =0;
    @api
    handleParticipantsearch(event){
        this.searchCounter++ ;
        this.enteredSearchString = '';
        this.disabledFilter = false;
        this.hideActiononSearch=false;
        if(event.target.value.length != 0)
        {
          this.template.querySelector('[data-id="filterdiv"]').classList.add('disablefilter');
            this.disabledFilter = true;
            this.hideActiononSearch=true;
            if(event.target.value.length <= 2 )
                return;
        } 
        else{
          
          this.template.querySelector('[data-id="filterdiv"]').classList.remove('disablefilter');
        }
        if(event.target.value && event.target.value.length > 2 )
        { 
            this.enteredSearchString = event.target.value;
        }
        //call the method with search string
        console.log('>>>searchCounter>>'+this.searchCounter);
        if(this.totalRecordCount > 0){        
            this.totalRecordCount = -1;
            this.isResetPagination = true;
            const selectEvent = new CustomEvent('resetparent', {
                detail: ''
            });
            this.dispatchEvent(selectEvent);
        }
        else{
            this.totalRecordCount = -1;
            this.fetchList();
        }
        

       
        
    }
    @api studyIDList;
    @api fetchList(){
        var searchCount = this.searchCounter;
        this.selectall = false;
        var selectCount=0;
        var enableCount=0;
        this.participantList=null;
        this.sortInitialVisit = false;        
        this.showFilter =true; 
        console.log('filter:'+JSON.stringify(this.filterWrapper));
        getListViewData({pageNumber : this.pageNumber, totalCount : this.totalRecordCount, 
            sponsorName  : this.communityTemplate, filterWrapper : JSON.stringify(this.filterWrapper),
             isPPFiltered: this.isPPFiltered, sortOn : this.sortOn, searchString :  this.enteredSearchString, sortType : this.sortType })
        .then(result => {
            if(searchCount == this.searchCounter){
                this.sortInitialVisit = result.sortInitialVisit;
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
            
                console.log('result value:'+JSON.stringify(result));
                console.log('studyIdList--->'+result.studyIdlist.length);
                console.log('result.filterWrapper--->'+result.filterWrapper);
                console.log('StatusList--->'+result.filterWrapper.status);
                this.studyIDList = result.studyIdlist;
                if((result.filterWrapper.status == undefined || result.filterWrapper.status.length == 1) && result.studyIdlist.length == 1 && result.filterWrapper.status != 'Eligibility Passed' && result.filterWrapper.status != 'Eligibility Failed'){
                    this.showStatus=true;
                    console.log('showstatus'+this.showStatus);
                }
                else{
                    this.showStatus=false;
                    console.log('dontshowstatus'+this.showStatus); 
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
                if(!(Object.keys(this.filterWrapper).length === 0)){
                    if(this.filterWrapper.studyList.length != 1){
                        this.showDCT=false;
                        this.showPP=false;
                        console.log('showstatus'+  this.showDCT);
                    }
                }
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
            }
        })
        .catch(error => {
            this.saving = false;
            console.log('Error : '+error.stack);
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
            // var ttlcount = this.totalRecordCount;
            // const selectEvent = new CustomEvent('resetpagination', {
            //     detail: ttlcount
            // });
            // this.dispatchEvent(selectEvent);
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
            //this.fetchList();
            // var ttlcount = this.totalRecordCount;
            // const selectEvent = new CustomEvent('resetpagination', {
            //     detail: ttlcount
            // });
            // this.dispatchEvent(selectEvent);
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
    @api additionalNoteValue; @api finalConsentvalue; @api selectedreasonvalue; @api consentValue;
    @api signedDateValue;

    @api updateBulkStatusChange(){   
        // let study = this.filterWrapper.studyList.toString();
        // let status = this.filterWrapper.status.toString();
        let study = this.studyIDList.toString();
	    let status;
        if(this.filterWrapper.status == undefined){
        status='Received'
        }else{
        status = this.filterWrapper.status.toString();
        }
        updateParticipantStatus({peIdList : this.selectedCheckboxes, 
            StatusToUpdate: this.newstatus,
            Notes: this.additionalNoteValue,
            reason: this.selectedreasonvalue,
            studyId: study,
            oParticipantStatus: status,
            finalconsent: this.finalConsentvalue,
            consentSigned: this.consentValue,
            signedDate:this.signedDateValue
        })
        .then(result => {
            this.saving = true;
            //this.showSuccessToast(this.selectedCheckboxes.length+' '+this.label.Records_all_invited);
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
    @api newstatus;
    handleChangeOfStatus(event) {
        this.enableStatus=false;
        let study = this.filterWrapper.studyList.toString();
        let status = this.filterWrapper.status.toString();
        const selectedEvent = new CustomEvent("statusvaluechange", {
            detail: {
                newStatusSelected: event.detail.value,
                oParticipantStatus: status,
                studyId: study
            }
          });
        this.dispatchEvent(selectedEvent);
        this.newstatus = event.detail.value;
    }
    get checknewStatus(){
        if(this.newstatus == 'Enrollment Success' || this.newstatus == 'Randomization Success'){
            return true;
        }else{
            return false;
        }
    }
  
    changeStatus = false;
    handlenewOnSelect(event){
        console.log('change status0');
        var selectedVal=event.target.dataset.id;
        this.dropDownLabel=selectedVal;
        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.remove("slds-is-open");
        });
        if( this.dropDownLabel != 'Change Status'){
            console.log('changestatus');
            this.template.querySelectorAll(".dropsize").forEach(function (L) {
                L.classList.remove("slds-p-bottom--x-large");
            });
            this.template.querySelectorAll(".dropsize").forEach(function (L) {
                L.classList.add("slds-p-bottom--x-small");
            });
            this.template.querySelectorAll(".dropsize").forEach(function (L) {
                L.classList.remove("participantStatus");
            });
       }
       else{
        this.template.querySelectorAll(".dropsize").forEach(function (L) {
            L.classList.add("participantStatus");
        });
       }
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
            this.fetchList();
        }
        if( this.dropDownLabel=='Change Status'){
            console.log('change status');
            const selectedEvent = new CustomEvent("getstatus");
            this.dispatchEvent(selectedEvent);
            this.changeStatus=true;
            this.enableStatus=true;
            this.statusChangeList = '';this.statusSelected='';
            console.log('filterstudylen:'+''+ this.studyIDList);
            console.log('filterstatus:'+''+this.filterWrapper.status);
            let study =  this.studyIDList.toString();
            let status;
            if(this.filterWrapper.status == undefined){
                status='Received'
            }else{
                status = this.filterWrapper.status.toString();
            }
           
            getAvailableStatuses({ status: status, StudyId: study })
            .then(result => {
                this.statusChangeList = result;
                this.statusSelected = 'null';
                const selectedEvent = new CustomEvent("getstatus");
                this.dispatchEvent(selectedEvent);
            })
            .catch(error => {
               console.log(error);
               this.showErrorToast(error);
               const selectedEvent = new CustomEvent("getstatus");
               this.dispatchEvent(selectedEvent);
            });
            
        }
        else{
            this.changeStatus = false;
            this.enableStatus=false;
        }

        if( this.dropDownLabel=='Send to DCT'){
            this.dctCheck=true; 
            console.log('DCT LABEL');
            //this.saving = true;
            // this.totalRecordCount = -1;
            // this.isResetPagination = true;
            // this.fetchList(); 
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
    exportData;
    @api handleExport(){
        this.saving=true;
        exportSelected({peIdList : this.selectedCheckboxes})
        .then(result => {
            this.exportData = result;
        if (this.exportData == null || this.exportData.length<0) {
            return null;
        }
        if(result.partList.length>0){
            this.downloadCSV(result.partList);
        }
        
       
        })
        .catch(error => {
            this.saving=false;
            this.err = error;
            console.log('Error new: '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
        });
        
    }
    exportAllDatatemp;
    studyAll=[];
    siteAll=[];
    startPos=0;
    endPos=45000;
    totalCount=45000;
    counterLimit=45000;
    isFirstTime=true;
    csvList=[];
    
    @api getExportAll(){ //resetexportall
        this.csvList=[];
        this.startPos=0;
        this.endPos=45000;
        this.totalCount=45000;
        this.counterLimit=45000;
        this.isFirstTime=true;
        this.handleExportall();
    }

    handleExportall(){
        this.saving=true;
        exportAll({studies : this.studyAll, studySites: this.siteAll,startPos: this.startPos,endPos: this.endPos,sponsorName: this.communityTemplate})
        .then(result => {
            this.exportAllDatatemp = result;
            this.totalCount=this.exportAllDatatemp.totalCount;
            var csvFinalList = this.exportAllDatatemp.partList; 
                
                if (this.isFirstTime==false) {
                    this.csvList = [].concat(this.csvList,csvFinalList);
                } else {
                    this.csvList = csvFinalList;
                    this.isFirstTime=false;
                }

                var currentCount = this.csvList.length;
                var counterLimit = this.counterLimit;
                var finaltotalCount = this.totalCount;
                if (finaltotalCount > 100000) {
                    finaltotalCount = 100000;
                }
                if (currentCount < finaltotalCount) {
                    counterLimit = counterLimit + 45000;
                    this.counterLimit= counterLimit;
                }
                if (this.exportAllDatatemp.endPos < counterLimit && currentCount < finaltotalCount) {
                    this.startPos = this.endPos + 1;
                    this.endPos = this.endPos + 45000;
                    this.startPos= this.startPos;
                    this.endPos= this.endPos;
                    this.handleExportall();
                } else {
                    this.downloadCSV(this.csvList);
                }
        })
        .catch(error => {
            this.saving=false;
            this.err = error;
            console.log('Error new: '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
        });
    }
    dowloadList;
    downloadCSV(partList){
        
        this.saving=false;
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        columnDivider = ',';
        lineDivider = '\n';
         var disclaimer =  '"' +this.label.Disclaimer_Text + '"';
         disclaimer = disclaimer + columnDivider + lineDivider;
         var headerWithDis = [
                    'Participant Profile Name',
                    'MRN Id',
                    'Patient ID',
                    'Source ID',
                    'Received Date',
                    'Study Code Name',
                    'First Name',
                    'Last Name',
                    'Email',
                    'Phone',
                    'Phone Type',
                    'Alternate Phone Number',
                    'Alternate Phone Type',
                    'Sex',
                    'Age',
                    'Ethnicity',
                    'Comorbidities',
                    'BMI',
                    'High Risk Occupation',
                    'High Priority',
                    'Protocol ID',
                    'Study Site Name',
                    'Investigator Name',
                    'Participant Status',
                    'Status Change Reason',
                    'Participant Status Last Changed Date',
                    'Last Status Changed Notes',
                    'Pre-screening 1 Status',
                    'Pre-screening 1 Completed by',
                    'Pre-screening Date',
                    'Referral Source'
                ];
                headerWithDis =  disclaimer+ headerWithDis;
                csvStringResult = '';
                csvStringResult += headerWithDis + columnDivider;
            
             
            csvStringResult += lineDivider;
            for (var i = 0; i < partList.length; i++) {
                if (
                    partList[i]['Name'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Name'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['MRN_Id__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['MRN_Id__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Patient_ID__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Patient_ID__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (partList[i]['Referral_Source__c'] == 'PI') {
                    if (partList[i]['MRN_Id__c'] != undefined) {
                        csvStringResult += '"' + partList[i]['MRN_Id__c'] + '"' + ',';
                    } else {
                        csvStringResult += '" "' + ',';
                    }
                } else if (partList[i]['Referral_Source__c'] == 'HCP') {
                    if (partList[i]['Patient_ID__c'] != undefined) {
                        csvStringResult += '"' + partList[i]['Patient_ID__c'] + '"' + ',';
                    } else {
                        csvStringResult += '" "' + ',';
                    }
                } else {
                    if (csvStringResult += '"' + partList[i]['Patient_ID__c'] !== undefined) {
                        csvStringResult += '"' + partList[i]['Patient_ID__c'] + '"' + ',';
                    } else {
                        csvStringResult += '" "' + ',';
                    }
                }
                if (
                    partList[i]['Referred_Date__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Referred_Date__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Clinical_Trial_Profile__r']['Study_Code_Name__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Clinical_Trial_Profile__r']['Study_Code_Name__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
        
         
             //code for when PII inclusion is true start
            if(partList[i]['Study_Site__r']['Include_PII_on_Export__c'] == true){	
                
                if (partList[i]['Participant__r'] !== undefined && partList[i]['Participant__r']['First_Name__c'] !== undefined) {
                    csvStringResult +=
                        '"' + partList[i]['Participant__r']['First_Name__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (partList[i]['Participant__r'] !== undefined && partList[i]['Participant__r']['Last_Name__c'] !== undefined) {
                    csvStringResult +=
                        '"' + partList[i]['Participant__r']['Last_Name__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (partList[i]['Participant__r'] !== undefined && partList[i]['Participant__r']['Email__c'] !== undefined) {
                    csvStringResult +=
                        '"' + partList[i]['Participant__r']['Email__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (partList[i] ['Participant__r'] !== undefined && partList[i] ['Participant__r']['Phone__c'] !== undefined) {
                    csvStringResult +=
                        '"' + partList[i] ['Participant__r']['Phone__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (partList[i] ['Participant__r'] !== undefined && partList[i] ['Participant__r']['Phone_Type__c'] !== undefined) {
                    csvStringResult +=
                        '"' + partList[i] ['Participant__r']['Phone_Type__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i] ['Participant__r'] !== undefined && partList[i] ['Participant__r']['Alternative_Phone_Number__c'] !==
                    undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i] ['Participant__r']['Alternative_Phone_Number__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i] ['Participant__r'] !== undefined && partList[i] ['Participant__r']['Alternative_Phone_Type__c'] !== undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i] ['Participant__r']['Alternative_Phone_Type__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
    
                if (partList[i] ['Participant__r'] !== undefined && partList[i] ['Participant__r']['Gender_Technical__c'] !== undefined) {
                    csvStringResult +=
                        '"' +
                        partList[i] ['Participant__r']['Gender_Technical__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
    
                if (partList[i] ['Participant__r'] !== undefined && partList[i] ['Participant__r']['Present_Age__c'] !== undefined) {
                    csvStringResult +=
                        '"' + partList[i] ['Participant__r']['Present_Age__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
    
                if (partList[i] ['Participant__r'] !== undefined && partList[i] ['Participant__r']['Ethnicity__c'] !== undefined) {
                    var val = partList[i] ['Participant__r']['Ethnicity__c'];
                    var arr = val.split(';');
                    csvStringResult += '"' + arr.join() + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
    
                if (partList[i] ['Comorbidities__c'] !== undefined) {
                    csvStringResult += '"' + partList[i] ['Comorbidities__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
    
                if (partList[i] ['Participant__r'] !== undefined && partList[i] ['Participant__r']['BMI__c'] !== undefined) {
                    csvStringResult +=
                        '"' + partList[i] ['Participant__r']['BMI__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
    
                if (partList[i] ['HighRisk_Indicator__c'] !== undefined) {
                    csvStringResult +=
                        '"' + partList[i] ['HighRisk_Indicator__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
    
                if (partList[i]['High_Priority__c'] !== undefined) {
                    if (partList[i]['High_Priority__c'] == true)  {
                        csvStringResult += '"' + 'Yes'+ '"' + ',';
                    }
                    else{
                        csvStringResult +=  '"' + 'No'+ '"' + ',';
                    }
                } else {
                    csvStringResult += '" "' + ',';
                }
            }
            //code for PII inclusion is true end
            //code for when PII inclusion is false start
            if(partList[i]['Study_Site__r']['Include_PII_on_Export__c'] == false){	
                
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
            
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
            
                csvStringResult +=
                    '"' +'Restricted' + '"' + ',';
            
               csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
            
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
           
            
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
            
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
            
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
           
               csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
           
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
            
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
            
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
           
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
            
                csvStringResult +=
                    '"' + 'Restricted' + '"' + ',';
           
            }
            //code for when PII inclusion is false end
        
        
                if (
                    partList[i]['Clinical_Trial_Profile__r']['Protocol_ID__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Clinical_Trial_Profile__r']['Protocol_ID__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Study_Site__r']['Name'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Study_Site__r']['Name'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['PI_Contact__r']['Full_Name__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['PI_Contact__r']['Full_Name__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (partList[i]['Participant_Status__c'] !== undefined) {
                    if(partList[i]['Participant_Status__c']=='Eligibility Passed' 
                       && (partList[i]['Clinical_Trial_Profile__r']['Initial_Visit_Required__c'] == true 
                           || partList[i]['Clinical_Trial_Profile__r']['Promote_to_SH__c'] == true)){
                        partList[i]['Participant_Status__c'] = 'Sent to Study Hub';
                    }
                    csvStringResult +=
                        '"' + partList[i]['Participant_Status__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Non_Enrollment_Reason__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Non_Enrollment_Reason__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Participant_Status_Last_Changed_Date__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Participant_Status_Last_Changed_Date__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
    
                if (
                    partList[i]['Last_Status_Changed_Notes__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Last_Status_Changed_Notes__c']+'nned masking' +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Medical_Record_Review_Status__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Medical_Record_Review_Status__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Medical_Record_Review_Completedby_Name__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Medical_Record_Review_Completedby_Name__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Medical_Record_Review_Completed_Date__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Medical_Record_Review_Completed_Date__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                if (
                    partList[i]['Referral_Source__c'] != undefined
                ) {
                    csvStringResult +=
                        '"' +
                        partList[i]['Referral_Source__c'] +
                        '"' +
                        ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
                csvStringResult += lineDivider;
            }

        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csvStringResult);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'ExportData.csv'; // CSV file Name* you can change it.[only name not .csv]
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click();  // using click() js function to download csv file
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
                if(this.checknewStatus){
                    if(this.participantList[i].screeningId){
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
                }else{
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
    toggleFilter(){
        this.template.querySelectorAll(".filter-relative").forEach(function (L) {
            L.classList.toggle("slds-hide");
        });
    }
    isResetPagination = false;
    handleFilterEvent(event){
        this.presetSel="no preset";
        this.filterWrapper = event.detail;
        // this.studyIdlist = event.detail.selectedStudy;
        // this.siteIdlist = event.detail.selectedSite;
        // this.urlStudyId = event.detail.selectedStudy;
        // this.urlSiteId = event.detail.selectedSite;
        // this.selectedStatusValue = event.detail.selectedStatus;
        // var selectedStatusListOptions = [];
        // if(event.detail.selectedStatus == 'All Active Statuses'){
        //     selectedStatusListOptions.push('Received');
        //     selectedStatusListOptions.push('Pre-review Passed');
        //     selectedStatusListOptions.push('Contact Attempted');
        //     selectedStatusListOptions.push('Successfully Contacted');
        //     selectedStatusListOptions.push('Screening In Progress');
        //     selectedStatusListOptions.push('Screening In Progress - Wash Out Period');
        //     selectedStatusListOptions.push('Screening Passed');
        //     selectedStatusListOptions.push('Enrollment Success');
        //     selectedStatusListOptions.push('Eligibility Passed');
        //     selectedStatusListOptions.push('Ready to Screen');
        //     selectedStatusListOptions.push('Randomization Success');
        // }else if(event.detail.selectedStatus == 'All Inactive Statuses'){
        //     selectedStatusListOptions.push('Pre-review Failed');
        //     selectedStatusListOptions.push('Unable to Reach');
        //     selectedStatusListOptions.push('Contacted - Not Suitable');
        //     selectedStatusListOptions.push('Eligibility Failed');
        //     selectedStatusListOptions.push('Declined Consent');
        //     selectedStatusListOptions.push('Unable to Screen');
        //     selectedStatusListOptions.push('Withdrew Consent');
        //     selectedStatusListOptions.push('Screening Failed');
        //     selectedStatusListOptions.push('Withdrew Consent After Screening');
        //     selectedStatusListOptions.push('Enrollment Failed');
        //     selectedStatusListOptions.push('Randomization Failed');
        //     selectedStatusListOptions.push('Declined Final Consent');
        // }else{
        //     selectedStatusListOptions.push(event.detail.selectedStatus);
        // }
        this.isPPFiltered = false;
        // this.selectedStatusList = selectedStatusListOptions;
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
    //sort
    sortValue =  ' ORDER BY PerCounter__c DESC ';
    sortOn = ' ORDER BY PerCounter__c DESC ';
    sortType = 0;
    get sortOptions() {
       var opts =  [
            { label: this.label.PG_MRZ_L_Last_Added, value: ' ORDER BY PerCounter__c DESC ' },
            { label: this.label.PG_MRZ_L_Last_Modified, value: ' ORDER BY LastModifiedDate DESC,PerCounter__c DESC ' },   
            // { label: 'Alphabetical (A-Z)', value: 'asc' },
            // { label: 'Alphabetical (Z-A)', value: 'desc' }       
        ];
        if(this.sortInitialVisit){
            opts.push({ label: this.label.pir_Initial_Visit_Scheduled_Date_upcoming, value: ' AND (Initial_visit_scheduled_date__c >= today or Initial_visit_scheduled_date__c =null) order by Initial_visit_scheduled_date__c  NULLS LAST,PerCounter__c ' });
            opts.push({ label: this.label.pir_Initial_Visit_Scheduled_Date_past, value: ' AND (Initial_visit_scheduled_date__c < today or Initial_visit_scheduled_date__c =null) order by Initial_visit_scheduled_date__c DESC NULLS LAST,PerCounter__c DESC ' });
        }      
        return opts;
    }
    handleSortChange(event) {
        var orderby = event.detail.value;
        this.sortValue = orderby;
        if(orderby!='asc' && orderby!='desc'){
            this.sortOn = orderby;
            this.sortType = 0;
        }else{
            this.sortOn = '';
            this.sortType = 1;
            if(orderby=='desc'){                
                this.sortType = -1;
            }
        }
        this.totalRecordCount = -1;
        this.isResetPagination = true;
        const selectEvent = new CustomEvent('resetparent', {
            detail: ''
        });
        this.dispatchEvent(selectEvent);
    }
    //PRESET
    presetOpts;
    sysPresets = [];
    selectedPreset = {};
    presetSel;
    showEditPreset =false;
    showFilter =false;
    disablePreset = true;
    fetchAllPreset(){
        var presets = [];
        presets.push({label:this.label.pir_No_Preset,value:"no preset"});
        this.presetSel="no preset";
        fetchPreset()
        .then(data => {
            this.sysPresets = data;
            for(var i = 0; i<data.length ; i++){
                this.disablePreset = false;
                if(data[i].isDefault){
                    if((Object.keys(this.filterWrapper).length === 0)){
                        this.filterWrapper= data[i];                    
                        this.presetSel=data[i].presetId;
                    }
                }
                presets.push({ label: data[i].presetName, value: data[i].presetId });
            }
            this.presetOpts = presets;
            this.fetchList();
        })
        .catch(error => {
            this.error = error;
            console.log("Error: "+error.message);
        });
    }
    refreshAllPreset(){
        var presets = [];
        presets.push({label:this.label.pir_No_Preset,value:"no preset"});
        fetchPreset()
        .then(data => {
            this.sysPresets = data;
            this.disablePreset = true;
            for(var i = 0; i<data.length ; i++){
                this.disablePreset = false;
                presets.push({ label: data[i].presetName, value: data[i].presetId });
            }
            this.presetOpts = presets;
        })
        .catch(error => {
            this.error = error;
            console.log("Error: "+error.message);
        });
    }
    editPreset(){
        if(!this.disablePreset){
            this.showEditPreset = true;
        }
    }
    closepresetmodel(event){console.log("D::"+JSON.stringify(event.detail));

        if(event.detail.upd){
            if(event.detail.delList.includes(this.presetSel)){
                this.presetSel = "no preset";
                this.template.querySelector("c-pir_filter").resetFilter(event);
                this.template.querySelector("c-pir_filter").applyFilter();
                this.toggleFilter();
                this.refreshAllPreset();
                
            }
            else if(event.detail.upList.includes(this.presetSel)){
                var presets = [];
                presets.push({label:this.label.pir_No_Preset,value:"no preset"});
                fetchPreset()
                .then(data => {
                    this.sysPresets = data;
                    this.disablePreset = true;
                    for(var i = 0; i<data.length ; i++){
                        this.disablePreset = false;
                        presets.push({ label: data[i].presetName, value: data[i].presetId });
                    }
                    this.presetOpts = presets;
                    for(var i=0;i<this.sysPresets.length;i++){
                        if(this.presetSel==this.sysPresets[i].presetId){
                            this.filterWrapper = this.sysPresets[i];
                            this.presetSel=this.sysPresets[i].presetId;
                            this.isPPFiltered = false;
                            this.totalRecordCount = -1;
                            this.isResetPagination = true;
                            this.fetchList();
                            const selectEvent = new CustomEvent('resetparent', {
                                detail: ''
                            });
                            this.dispatchEvent(selectEvent);
                            this.template.querySelector("c-pir_filter").presetWrapperSet(this.sysPresets[i]); 
                            setselectedFilterasDefault ({selectedPresetId :this.presetSel })
                            .then((result) => {
                
                            })
                            .catch((error) => {
                                console.error("Error:", error);
                            });
                            break;
                        }
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log("Error: "+error.message);
                });
            }
            else{
                this.refreshAllPreset();
            }
        }
        this.showEditPreset = false;
    }
    handlePresetChange(event){
        if(event.detail.value=="no preset"){
            this.template.querySelector("c-pir_filter").resetFilter(event);
            this.template.querySelector("c-pir_filter").applyFilter();
            this.toggleFilter();
        }
        else{
            for(var i=0;i<this.sysPresets.length;i++){
                if(event.detail.value==this.sysPresets[i].presetId){
                    this.filterWrapper = this.sysPresets[i];
                    this.presetSel=this.sysPresets[i].presetId;
                    this.isPPFiltered = false;
                    this.totalRecordCount = -1;
                    this.isResetPagination = true;
                    this.fetchList();
                    const selectEvent = new CustomEvent('resetparent', {
                        detail: ''
                    });
                    this.dispatchEvent(selectEvent);
                    this.template.querySelector("c-pir_filter").presetWrapperSet(this.sysPresets[i]);                     
                    break;
                }                
            }
        }
        setselectedFilterasDefault ({selectedPresetId :event.detail.value })
        .then((result) => {

        })
        .catch((error) => {
            console.error("Error:", error);
        });
    }
    setDefaultFilter(event){
        this.filterWrapper= event.detail;
    }
    get filterCount(){
        if(!(Object.keys(this.filterWrapper).length === 0)){
            var count = 10;
            if(this.filterWrapper.ethnicityList){
                if(this.filterWrapper.ethnicityList.length>0){
                    count++;
                }
            }
            if((this.filterWrapper.ageFrom && this.filterWrapper.ageFrom!="") || (this.filterWrapper.ageTo && this.filterWrapper.ageTo!="")){
                count++;
            }
            
            return "("+count+")";
        }
        return "";
    }
}