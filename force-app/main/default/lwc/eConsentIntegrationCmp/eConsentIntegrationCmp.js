import { LightningElement,api,track,wire} from 'lwc';
import geteconsentvendorrecorddetails from '@salesforce/apex/EConsentIntegrationController.getinitData';
import updateSiteConsentVendor from '@salesforce/apex/EConsentIntegrationController.updateSiteConsentVendor';
import selectallstudysite from '@salesforce/apex/EConsentIntegrationController.selectallstudysites';
import deselectallstudysite from '@salesforce/apex/EConsentIntegrationController.deselectallstudysites';
import createconsentvendor from '@salesforce/apex/EConsentIntegrationController.createconsentvendor';

import deletevendordetails from '@salesforce/apex/EConsentIntegrationController.deleteVendor';

import saveLabel from '@salesforce/label/c.Save';
import cancelLabel from '@salesforce/label/c.Cancel';
import selectcountryLabel from '@salesforce/label/c.RH_RP_Select_Country';
import selecteconsentvendorLabel from '@salesforce/label/c.Select_E_Consent_Vendor';
import studysiteLabel from '@salesforce/label/c.TS_Select_Study_Site';
import addconsentvendorLabel from '@salesforce/label/c.Add_Consent_Vendor';
import consentrecvendorLabel from '@salesforce/label/c.E_Consent_Record_Vendor_Name';
import consentrecvendorURL from '@salesforce/label/c.E_Consent_Record_Vendor_URL';

import countryLabel from '@salesforce/label/c.RH_RP_Country';
import studysitLabel from '@salesforce/label/c.Study_Site';
import studysitNumbrLabel from '@salesforce/label/c.TS_Study_Site_Number';

import selectallLabel from '@salesforce/label/c.Select_All_PI';
import clearallLabel from '@salesforce/label/c.RPR_Clear_All';
import permissionLabel from '@salesforce/label/c.E_Consent_Permission';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe,
    unsubscribe,
    MessageContext
  } from "lightning/messageService";
import REFRESH_CHANNEL from "@salesforce/messageChannel/rhrefresheconsent__c";

export default class EConsentIntegrationCmp extends LightningElement {
    
    @wire(MessageContext)
     messageContext;

    receivedMessage;
    subscription = null;

    label = {
        saveLabel,
        cancelLabel,
        selectcountryLabel,
        selecteconsentvendorLabel,
        studysiteLabel,
        addconsentvendorLabel,
        consentrecvendorLabel,
        consentrecvendorURL,
        countryLabel,
        studysitLabel,
        studysitNumbrLabel,
        selectallLabel,
        clearallLabel,
        permissionLabel

    };
    @api recordId;   
    venders; 
    eConsentdetails = [];
    totalstudysitelist = [];
    isModalOpen = false;
    vendername;
    vendorURL;
    venderdescription;
    countryArray = [];
    countryArraySet = [];
    vendorArray = [];
    studysiteArray = [];
    vendorArrayupdate = false;
    vendoriddescmap = new Map();
    showCountryLookup = false;
    showVendorLookup = false;
    showStudySiteLookup = false;
    selectedVendors;
    selectedStudysite;
    selectedcountrylist;
    selectedcountry = [];
    selectedvendorArray = [];
    selectedsiteArray = [];
    rowNumberOffset;
    consentLength;
    uparrow = true;
    downarrow = false;
    sortingorder = 'ASC';
    toupsertcheck = false;
    vendorId;
    //picklistoptions =[];
    showpagenation = false;
    vendercreationcheck = true;
    showConsentScreen = true;
    permissioncheck = true;
    fixedsiteset = [];
    fixedcountryset = [];
    fixedvendorarray = [];
    isSpinner = false;
    isSpinnerCheck = false;
    sortingType = 'StudySite';
    sortingShow = true;
    show_E_Consentscreen = true;
    @api isreadonly = false;
    connectedCallback() {
        this.isSpinnerCheck = true;
        this.getEConsentDetails(this.recordId);
        this.handleSubscribe();

    }
    get isDisabled(){
        return this.isreadonly;
    }
    renderedCallback() {
        const style = document.createElement('style'); 
        style.innerText = ".consentVendorBtn button.slds-button{width:80px;text-align: left;overflow:hidden; text-overflow:ellipsis; white-space:nowrap;display:inline-block}";  
        const selector =  this.template.querySelector('.consentVendorBtn');
        if(selector != null){
            this.template.querySelector('.consentVendorBtn').appendChild(style);
        }                  
    }

    handleSubscribe() {
        console.log("in handle subscribe");
        if (this.subscription) {
            return;
        }

        //4. Subscribing to the message channel
        this.subscription = subscribe(
            this.messageContext,
            REFRESH_CHANNEL,
            (message) => {
                console.log('LMS Message'+message);
            this.handleMessage(message);
            }
        );
    }

    handleMessage(message) {
        this.show_E_Consentscreen = !this.show_E_Consentscreen;
        console.log('LMS Message'+message);
        this.receivedMessage = message
        ? JSON.stringify(message, null, "\t")
        : "no message";
    }

    handleUnsubscribe() {
    
        unsubscribe(this.subscription);
        this.subscription = null;
    }
   
    getEConsentDetails(itemId) {
        this.eConsentdetails = [];
        this.totalstudysitelist = [];
        this.showpagenation = false;

        geteconsentvendorrecorddetails({ 
            ctpId:itemId,
            countryList:this.selectedcountry,
            vendorList:this.selectedvendorArray,
            studyList:this.selectedsiteArray,
            sortingOrder:this.sortingorder,
            stringType:this.sortingType 
        }).then((result) => {
            this.venders = result.eConsentVendors;
            for(let i=0; i< result.eConsentVendors.length;i++){
                this.vendoriddescmap.set(result.eConsentVendors[i].Id, result.eConsentVendors[i].Vendor_URL__c);
            }
            this.eConsentdetails = result.ResponeWrapperList;
            this.totalstudysitelist = result.ResponeWrapperList;
            this.consentLength = this.eConsentdetails.length;
            if(this.consentLength > 0){
                this.showpagenation = true;
            }

            this.showCountryLookup = true;
            if(!this.vendorArrayupdate){ 
               this.vendorArray = [];
                for(let i=0; i<result.eConsentVendors.length; i++){
                   let obj = {id: result.eConsentVendors[i].Id, value: result.eConsentVendors[i].Name, icon:'standard:job_position'};
                   this.vendorArray.push(obj);
                }
                this.fixedvendorarray = this.vendorArray;
           }
            this.showVendorLookup = true;
            this.showStudySiteLookup = true;
            //if(this.permissioncheck){
                for(let i=0; i<result.studysiteList.length; i++){
                    if(result.studysiteList[i].Site__r.BillingCountry != '' && result.studysiteList[i].Site__r.BillingCountry != undefined &&
                    !this.countryArraySet.includes(result.studysiteList[i].Site__r.BillingCountry)){
                        let obj = {id: result.studysiteList[i].Site__r.BillingCountry, value: result.studysiteList[i].Site__r.BillingCountry, icon:'standard:task2'};
                        this.countryArray.push(obj);
                        this.fixedcountryset.push(obj);
                        this.countryArraySet.push(result.studysiteList[i].Site__r.BillingCountry);
                    }
                }
                for(let i=0; i<result.studysiteList.length; i++){
                    let obj = {id: result.studysiteList[i].Id, value: result.studysiteList[i].Name, icon:'standard:task2'};
                    this.studysiteArray.push(obj);
                }
                this.fixedsiteset = this.studysiteArray;
                this.show_E_Consentscreen = result.econsentpermissioncheck;console.log('show_E_Consentscreen'+this.show_E_Consentscreen);
                this.permissioncheck = false;
            //}
            this.isSpinnerCheck = false;
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
            this.isSpinnerCheck = false;
        });
    }

    createvendor(){
        this.vendorId = '';
        this.vendername = '';
        this.isModalOpen = true;
        this.vendorURL = '';

    }
    closeModal() {
        this.vendorId = '';
        this.vendername = '';
        this.isModalOpen = false;
        this.vendorURL = '';
    }
    submitDetails(){

        createconsentvendor({ 
            name: this.vendername,
            vendorURL: this.vendorURL,
            vendorId:this.vendorId
        }).then((result) => {

            console.log('result-->'+result);
            this.vendercreationcheck = true;
            if(result != '' && result != undefined ){
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: result,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isModalOpen = true;
            } else {
                this.isModalOpen = false;
                this.vendorArrayupdate = false;
                //this.selectedvendorArray=[];
                this.getEConsentDetails(this.recordId);
            }
        })
        .catch((error) => {
            this.vendercreationcheck = true;
            console.log(JSON.stringify(error));
        });

        
    } 
    updatevendername(event){
        this.vendername = event.target.value;
        if(this.vendername != '' && this.vendername != undefined && this.vendername.trim() != '' ){
            this.vendercreationcheck = false;
        } else {
            this.vendercreationcheck = true;
        }
    }
    updateVendorDetails(event){
        this.vendername = this.template.querySelector('[data-name="vendorName"]').value;
        this.vendorURL =  this.template.querySelector('[data-name="vendorURL"]').value;
        if(this.vendername != '' && 
            this.vendername != undefined && 
            this.vendername.trim() != '' &&
            this.vendorURL.trim() != '' && 
            this.vendorURL != undefined &&
            this.template.querySelector('[data-name="vendorURL"]').checkValidity()){
            
            this.vendercreationcheck = false;
        } else {
            this.vendercreationcheck = true;
        }

    }

    handleCountryChange(event){
        this.isSpinnerCheck = true;
        let opps = event.detail;
        this.selectedcountrylist = '';
        
        opps.forEach(opp => {
            this.selectedcountrylist += opp.id+';';
        });
        let splt = this.selectedcountrylist.split(';');
        this.selectedcountry=[];
        for(let i=0; i<splt.length; i++){
            if(splt[i] != '' && splt[i] != undefined){
                this.selectedcountry.push(splt[i]);
            }
        }
        if(this.selectedcountry.length > 0){
            var showrec = [];
            this.countryArray = [];
            for(let i=0;i<this.fixedcountryset.length;i++){
                if(!this.selectedcountry.includes(this.fixedcountryset[i].id)){
                    let obj = {id: this.fixedcountryset[i].id, value:this.fixedcountryset[i].value, icon:'standard:task2'};
                    showrec.push(obj);
                }
    
            }
            this.countryArray = showrec;
        }else{
            var showrec = [];
            this.countryArray = this.fixedcountryset;
        }

        this.getEConsentDetails(this.recordId);

    }

    handleVendorChange(event){
        this.isSpinnerCheck = true;
        let opps = event.detail;
        this.selectedVendors = '';
        opps.forEach(opp => {
            this.selectedVendors += opp.id+';';
            
        });
        let splt = this.selectedVendors.split(';');
        this.selectedvendorArray=[];
        for(let i=0; i<splt.length; i++){
            if(splt[i] != '' && splt[i] != undefined){
                this.selectedvendorArray.push(splt[i]);
            }
        }

        if(this.selectedvendorArray.length > 0){
            this.vendorArrayupdate = true; 
        }else{
            this.vendorArrayupdate = false; 
        }

        if(this.selectedvendorArray.length > 0){
            var showrec = [];
            this.vendorArray = [];
            for(let i=0;i<this.fixedvendorarray.length;i++){
                if(!this.selectedvendorArray.includes(this.fixedvendorarray[i].id)){
                    let obj = {id: this.fixedvendorarray[i].id, value:this.fixedvendorarray[i].value, icon:'standard:job_position'};
                    showrec.push(obj);
                }
    
            }
            this.vendorArray = showrec;
        }else{
            var showrec = [];
            this.vendorArray = this.fixedvendorarray;
        }
        
        this.getEConsentDetails(this.recordId);
    }

    handleStudySiteChange(event){
        this.isSpinnerCheck = true;
        let opps = event.detail;
        this.selectedStudysite = '';
        opps.forEach(opp => {
            this.selectedStudysite += opp.id+';';
        });
        let splt = this.selectedStudysite.split(';');
        this.selectedsiteArray=[];
        for(let i=0; i<splt.length; i++){
            if(splt[i] != '' && splt[i] != undefined){
                this.selectedsiteArray.push(splt[i]);
            }
        }
        if(this.selectedsiteArray.length > 0){
            var showrec = [];
            this.studysiteArray = [];
            for(let i=0;i<this.fixedsiteset.length;i++){
                if(!this.selectedsiteArray.includes(this.fixedsiteset[i].id)){
                    let obj = {id: this.fixedsiteset[i].id, value:this.fixedsiteset[i].value, icon:'standard:task2'};
                    showrec.push(obj);
                }
    
            }
            this.studysiteArray = showrec;
        }else{
            var showrec = [];
            this.studysiteArray = this.fixedsiteset;
        }
        
        this.getEConsentDetails(this.recordId);
    }

    handleClick(event) {
        this.isSpinner = true;
        let targetId = event.target.dataset.targetId;
        let studyId = event.currentTarget.dataset.id;
        var totalRecords = [];
        let iseventTrue = event.target.checked;
        console.log('Target checked'+event.target.checked +'..'+iseventTrue);
        updateSiteConsentVendor({ 
            studyId:studyId,
            vendorId:iseventTrue ? targetId:null
        }).then((result) => {
            console.log('result-->'+result);
            for(var i in this.totalstudysitelist) {
                let row = Object.assign({}, this.totalstudysitelist[i]);
                for(var j in row.vendorrapperlist){
                    let vendorRow = Object.assign({},  row.vendorrapperlist[j]);

                    if(studyId ==  this.totalstudysitelist[i].studysiteid) {

                        if(targetId == vendorRow.vendorId && iseventTrue) {
                            
                            vendorRow.isEnable = true;
                            
                            row.vendorrapperlist[j] = vendorRow;
                            
                        } else {
                            vendorRow.isEnable = false;
                            row.vendorrapperlist[j] = vendorRow;
                        }
                    }
                }
                totalRecords.push(row);
            }
            this.totalstudysitelist = [];
            this.totalstudysitelist = totalRecords;
            this.isSpinner = false;
        }).catch((error) => {
            console.log(JSON.stringify(error));
            this.isSpinner = false;
        });

        
   
    }

    //Select all records
    selectallstudysites(event){
        this.isSpinner =true;
        //var vendorexist = false;
        let vendorRecId = event.currentTarget.dataset.id;
        
        //if(!vendorexist){
        console.log(vendorRecId);
        selectallstudysite({ 
            vendorId: vendorRecId,
            ctpId: this.recordId,
            respwrapper: JSON.stringify(this.totalstudysitelist)
        }).then((result) => {
            
            var totalRecords = [];
            for(var i in this.totalstudysitelist) {
                let row = Object.assign({}, this.totalstudysitelist[i]);
                for(var j in row.vendorrapperlist){
                    let vendorRow = Object.assign({},  row.vendorrapperlist[j]);
                    vendorRow.isEnable = vendorRecId == vendorRow.vendorId;
                    row.vendorrapperlist[j] = vendorRow;
                }
                totalRecords.push(row);
            }
            this.totalstudysitelist = [];
            this.totalstudysitelist = totalRecords;
            console.log('result-->'+result);
            this.isSpinner =false;
        }).catch((error) => {

            console.log(JSON.stringify(error));
            this.isSpinner =false;
        });
        
    }

    deselectallstudysites(event){
        this.isSpinner =true;
        let vendorRecId = event.currentTarget.dataset.id;
        deselectallstudysite({ 
            vendorId:vendorRecId, 
            ctpId:this.recordId, 
            respwrapper:JSON.stringify(this.totalstudysitelist)
        }).then((result) => {

            var totalRecords = [];
            for(var i in this.totalstudysitelist) {
                let row = Object.assign({}, this.totalstudysitelist[i]);
                for(var j in row.vendorrapperlist){
                    let vendorRow = Object.assign({},  row.vendorrapperlist[j]);
                    if(vendorRecId === vendorRow.vendorId){
                        vendorRow.isEnable = false;
                    }
                    row.vendorrapperlist[j] = vendorRow;
                }
                totalRecords.push(row);
            }
            this.totalstudysitelist = [];
            this.totalstudysitelist = totalRecords;

            console.log('result-->'+result);
            this.isSpinner =false;
            //  this.eConsentdetails = result;
            // this.getEConsentDetails(this.recordId);
        }).catch((error) => {
            console.log(JSON.stringify(error));
            this.isSpinner =false;
        });
    }

    handleOnselect(event){       
        var selectedVal = event.detail.value;
        let vendorId = event.currentTarget.dataset.id;
        let vendorName = event.target.dataset.targetId;
        this.vendername = '';
        this.vendorURL = '';
        this.toupsertcheck = false;
        this.vendercreationcheck = true;
        if(selectedVal == 'Clone'){
            this.vendorId = '';
            this.vendername = vendorName + selectedVal;
            this.vendorURL = this.vendoriddescmap.get(vendorId);
            this.isModalOpen = true;
            this.vendercreationcheck = false;
        }else if(selectedVal == 'Remove'){
            deletevendordetails({ vendorId:vendorId})
            .then((result) => {
                console.log('result-->'+result);
                this.getEConsentDetails(this.recordId);
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
        }
        else if(selectedVal == 'Edit'){
            this.vendername = vendorName; 
            this.isModalOpen = true;
            this.toupsertcheck = true;
            this.vendorId = vendorId;
            this.vendorURL = this.vendoriddescmap.get(vendorId); 
            this.vendercreationcheck = true;
        }      
    }
    
    
    sortRecs(event){
        this.isSpinnerCheck = true;
        this.sortingType = event.currentTarget.dataset.id;
        if(this.sortingType != 'StudySite'){
            this.sortingShow = false;
        }else{
            this.sortingShow = true;
        }
        if(this.uparrow){
            this.downarrow = true;
            this.uparrow = false;
            this.sortingorder = 'DESC';
            this.getEConsentDetails(this.recordId);
        }else{
            this.downarrow = false;
            this.uparrow = true;
            this.sortingorder = 'ASC';
            this.getEConsentDetails(this.recordId);
        }
    }
    
    handlePaginatorChanges(event) {
        this.eConsentdetails = event.detail;
        this.rowNumberOffset = this.eConsentdetails[0].rowNumber - 1;
    }
    
    handleClear() {
        this.receivedMessage = null;
    }
    
}