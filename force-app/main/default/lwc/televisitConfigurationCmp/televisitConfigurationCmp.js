import { LightningElement,api,track,wire} from 'lwc';
import gettelevisitrecorddetails from '@salesforce/apex/televisitConfigurationController.getinitData';
import createtelevisitvendor from '@salesforce/apex/televisitConfigurationController.createtelevisitvendorrecord';
import createorupdatetvs from '@salesforce/apex/televisitConfigurationController.createorupdatetvsrecord';
import selectallstudysite from '@salesforce/apex/televisitConfigurationController.selectallstudysites';
import deselectallstudysite from '@salesforce/apex/televisitConfigurationController.deselectallstudysites';
import deletevendordetails from '@salesforce/apex/televisitConfigurationController.deleteVendor';
import updatestudysitedetails from '@salesforce/apex/televisitConfigurationController.updatestudysite';
import vendoravailabilitycheck from '@salesforce/apex/televisitConfigurationController.vendoravailability';
import updateremindervalues from '@salesforce/apex/televisitConfigurationController.updateremindervalues';
import saveLabel from '@salesforce/label/c.Save';
import cancelLabel from '@salesforce/label/c.Cancel';
import selectcountryLabel from '@salesforce/label/c.RH_RP_Select_Country';
import selecttelevisitvendorLabel from '@salesforce/label/c.Select_Televisit_Vendor';
import studysiteLabel from '@salesforce/label/c.TS_Select_Study_Site';
import addvendorLabel from '@salesforce/label/c.TS_Add_Vendor';
import addtelevisitvendorLabel from '@salesforce/label/c.Add_Televisit_Vendor';
import televisitrecvendorLabel from '@salesforce/label/c.Televisit_Record_Vendor_Name';
import DescriptionLabel from '@salesforce/label/c.Description';
import countryLabel from '@salesforce/label/c.RH_RP_Country';
import studysitLabel from '@salesforce/label/c.Study_Site';
import studysitNumbrLabel from '@salesforce/label/c.TS_Study_Site_Number';
import bannerdisplayLabel from '@salesforce/label/c.Banner_Display_Offset_Time';
import bannerdisposeLabel from '@salesforce/label/c.Banner_dispose';
import offsetTimeLabel from '@salesforce/label/c.offset_time';
import selectallLabel from '@salesforce/label/c.Select_All_PI';
import clearallLabel from '@salesforce/label/c.RPR_Clear_All';
import permissionLabel from '@salesforce/label/c.permissionIssue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe,
    unsubscribe,
    MessageContext
  } from "lightning/messageService";
import REFRESH_CHANNEL from "@salesforce/messageChannel/rhrefresh__c";

export default class TelevisitConfigurationCmp extends LightningElement {
    
    @wire(MessageContext)
     messageContext;

    receivedMessage;
    subscription = null;

    label = {
        saveLabel,
        cancelLabel,
        selectcountryLabel,
        selecttelevisitvendorLabel,
        studysiteLabel,
        addvendorLabel,
        addtelevisitvendorLabel,
        televisitrecvendorLabel,
        DescriptionLabel,
        countryLabel,
        studysitLabel,
        studysitNumbrLabel,
        bannerdisplayLabel,
        bannerdisposeLabel,
        offsetTimeLabel,
        selectallLabel,
        clearallLabel,
        permissionLabel

    };
    @api recordId;   
    venders; 
    televisitdetails = [];
    totalstudysitelist = [];
    isModalOpen = false;
    vendername;
    venderdescription;
    countryArray = [];
    countryArraySet = [];
    vendorArray = [];
    studysiteArray = [];
    vendorArrayupdate = false;
    vendoriddescmap = new Map();;
    showOppLookup1 = false;
    showOppLookup2 = false;
    showOppLookup3 = false;
    selectedVendors;
    selectedStudysite;
    selectedcountrylist;
    selectedcountry = [];
    selectedvendorArray = [];
    selectedsiteArray = [];
    rowNumberOffset;
    telelength;
    uparrow = true;
    downarrow = false;
    sortingorder = 'ASC';
    toupsertcheck = false;
    vendorId;
    picklistoptions =[];
    showpagenation = false;
    vendercreationcheck = true;
    showTelevisitscreen = true;
    permissioncheck = true;
    fixedsiteset = [];
    fixedcountryset = [];
    fixedvendorarray = [];
    isSpinner = false;
    isSpinnerCheck = false;
    sortingType = 'StudySite';
    soritingShow = true;
    connectedCallback() {
        this.isSpinnerCheck = true;
        this.getteledetails(this.recordId);
        this.handleSubscribe();
        //alert('From connect call back');
    }
   
    getteledetails(itemId) {
        this.televisitdetails = [];
        this.totalstudysitelist = [];
        this.showpagenation = false;

        gettelevisitrecorddetails({ ctpId:itemId,countryList:this.selectedcountry,vendorList:this.selectedvendorArray,studyList:this.selectedsiteArray,sortingOrder:this.sortingorder,stringType:this.sortingType })
        .then((result) => {
            this.venders = result.trvList;
            for(let i=0; i< result.trvList.length;i++){
                this.vendoriddescmap.set(result.trvList[i].Id, result.trvList[i].Description__c);
            }
            this.televisitdetails = result.ResponeWrapperList;
            this.totalstudysitelist = result.ResponeWrapperList;
            this.telelength = this.televisitdetails.length;
            if(this.telelength > 0){
                this.showpagenation = true;
            }
            let options = [];
                 
            for (var key in result.picklistvalues) {
                options.push({ label: result.picklistvalues[key], value: result.picklistvalues[key]  });
            }
            this.picklistoptions = options;
            this.showOppLookup1 = true;
            if(!this.vendorArrayupdate){ 
               this.vendorArray = [];
                for(let i=0; i<result.trvList.length; i++){
                   let obj = {id: result.trvList[i].Id, value: result.trvList[i].Name, icon:'standard:job_position'};
                   this.vendorArray.push(obj);
                }
                this.fixedvendorarray = this.vendorArray;
           }
            this.showOppLookup2 = true;
            this.showOppLookup3 = true;
            if(this.permissioncheck){
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
                this.showTelevisitscreen = result.televisitpermissioncheck;
                this.permissioncheck = false;
            }
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
        this.venderdescription = '';

    }
    closeModal() {
        this.vendorId = '';
        this.vendername = '';
        this.isModalOpen = false;
        this.venderdescription = '';
    }
    submitDetails(){
            createtelevisitvendor({ name:this.vendername,description:this.venderdescription,vendorId:this.vendorId})
            .then((result) => {
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
                }else{
                    this.isModalOpen = false;
                    this.vendorArrayupdate = false;
                    //this.selectedvendorArray=[];
                    this.getteledetails(this.recordId);
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
        }else{
            this.vendercreationcheck = true;
        }
    }

    updatevenderdesc(event){
        this.venderdescription = event.target.value;
        if(this.vendorId  || this.vendername ){
            this.vendercreationcheck = false;
        }
    }

    handleOppsChange(event){
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

        this.getteledetails(this.recordId);

    }

    selectedVendor(event){
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
        
        this.getteledetails(this.recordId);
    }

    selectedStusysite(event){
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
        
        this.getteledetails(this.recordId);
    }

    handleClick(event) {
        this.isSpinner = true;
        let targetId = event.target.dataset.targetId;
        let studyId = event.currentTarget.dataset.id;
        let uniquekey = studyId + '-'+targetId;
        var totalRecords = [];
        var check = event.target.checked;
        vendoravailabilitycheck({ studySiteId:studyId})
        .then((result) => {
            console.log('result-->'+result);
            if(result && check){
                this.isSpinner = false;
                this.template.querySelector('[data-uniquekey="'+uniquekey+'"]').checked = false;
                const event = new ShowToastEvent({
                    title: 'Warning!',
                    message: 'Only one televisit provider per Study Site could be selected!',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }else{
                for(var i in this.totalstudysitelist) {
                    let row = Object.assign({}, this.totalstudysitelist[i]);
                    for(var j in row.vendorrapperlist){
                        let vendorRow = Object.assign({},  row.vendorrapperlist[j]);
                        if(targetId == vendorRow.vendorId && studyId ==  this.totalstudysitelist[i].studysiteid){
                            if(check){
                                vendorRow.isEnable = true;
                                row.vendorrapperlist[j] = vendorRow;
                            }
                            else{
                                vendorRow.isEnable = false;
                                row.vendorrapperlist[j] = vendorRow;
                            }
                        }
                    }
                    totalRecords.push(row);
                }
                this.totalstudysitelist = [];
                this.totalstudysitelist = totalRecords;
                createorupdatetvs({ studyId:studyId,vendorId:targetId,isEnable:check})
                    .then((result) => {
                        console.log('result-->'+result);
                        this.isSpinner = false;
                    })
                    .catch((error) => {
                        console.log(JSON.stringify(error));
                        this.isSpinner = false;
                    });
            }
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
            this.isSpinner = false;
        });
   
    }

    //Select all records
    selectallstudysites(event){
        this.isSpinner =true;
        var vendorexist = false;
        let vendorRecId = event.currentTarget.dataset.id;
        for(var i in this.totalstudysitelist) {
            let row = Object.assign({}, this.totalstudysitelist[i]);
            for(var j in row.vendorrapperlist){
                let vendorRow = Object.assign({},  row.vendorrapperlist[j]);
                if(vendorRow.isEnable && vendorRecId != vendorRow.vendorId ){
                    vendorexist = true;
                    break;
                }
            }
        }
        if(!vendorexist){
            console.log(vendorRecId);
            var totalRecords = [];
            for(var i in this.totalstudysitelist) {
                let row = Object.assign({}, this.totalstudysitelist[i]);
                for(var j in row.vendorrapperlist){
                    let vendorRow = Object.assign({},  row.vendorrapperlist[j]);
                    if(vendorRecId == vendorRow.vendorId){
                        vendorRow.isEnable = true;
                    }
                    row.vendorrapperlist[j] = vendorRow;
                }
                totalRecords.push(row);
            }
            this.totalstudysitelist = [];
            this.totalstudysitelist = totalRecords;
    
            selectallstudysite({ vendorId:vendorRecId,ctpId:this.recordId,respwrapper:JSON.stringify(this.totalstudysitelist)})
            .then((result) => {
                console.log('result-->'+result);
                this.isSpinner =false;
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
                this.isSpinner =false;
            });
        }else{
            this.isSpinner =false;
            const event = new ShowToastEvent({
                title: 'Warning!',
                message: 'Only one televisit provider per Study Site could be selected!',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        
    }

    deselectallstudysites(event){
        this.isSpinner =true;
        let vendorRecId = event.currentTarget.dataset.id;
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
        deselectallstudysite({ vendorId:vendorRecId,ctpId:this.recordId,respwrapper:JSON.stringify(this.totalstudysitelist)})
        .then((result) => {
            console.log('result-->'+result);
            this.isSpinner =false;
            //  this.televisitdetails = result;
            // this.getteledetails(this.recordId);
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
            this.isSpinner =false;
        });
    }

    renderedCallback() {
        const style = document.createElement('style'); 
        style.innerText = ".testBtn button.slds-button{width:80px;text-align: left;overflow:hidden; text-overflow:ellipsis; white-space:nowrap;display:inline-block}";  
        const selector =  this.template.querySelector('.testBtn');
        if(selector != null){
            this.template.querySelector('.testBtn').appendChild(style);
        }                  
    }

    handleOnselect(event){       
        var selectedVal = event.detail.value;
        let vendorId = event.currentTarget.dataset.id;
        let vendorName = event.target.dataset.targetId;
        this.vendername = '';
        this.venderdescription = '';
        this.toupsertcheck = false;
        this.vendercreationcheck = true;
        if(selectedVal == 'Clone'){
            this.vendorId = '';
            this.vendername = vendorName + selectedVal;
            this.venderdescription = this.vendoriddescmap.get(vendorId);
            this.isModalOpen = true;
            this.vendercreationcheck = false;
        }else if(selectedVal == 'Remove'){
            deletevendordetails({ vendorId:vendorId})
            .then((result) => {
                console.log('result-->'+result);
                this.getteledetails(this.recordId);
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
            this.venderdescription = this.vendoriddescmap.get(vendorId); 
            this.vendercreationcheck = true;
        }      
    }
    handleTypeChange(event){
        this.isSpinner = true;
        let studysiteid = event.currentTarget.dataset.id;
        let  comboboxname = event.target.dataset.targetId;
        let  selectedValue = event.target.value;
        var totalRecords = [];

        for(var i in this.totalstudysitelist) {
            let row = Object.assign({}, this.totalstudysitelist[i]);
            if(studysiteid ==  this.totalstudysitelist[i].studysiteid && comboboxname == 'displyoffsettime'){
                row.bannerdisplayoffsettime = selectedValue;
            }
            if(studysiteid ==  this.totalstudysitelist[i].studysiteid && comboboxname == 'disposeoffsettime'){
                row.bannerdisposeoffsettime = selectedValue;
            }
            totalRecords.push(row);
        }

        this.totalstudysitelist = [];
        this.totalstudysitelist = totalRecords;

        updatestudysitedetails({ studysiteId:studysiteid,comboboxname:comboboxname,selValue:selectedValue})
        .then((result) => {
            console.log('result-->'+result);
            this.isSpinner = false;
          //  this.getteledetails(this.recordId);
        })
        .catch((error) => {
            this.isSpinner = false;
            console.log(JSON.stringify(error));
        });
        
    }
    
    sortRecs(event){
        this.isSpinnerCheck = true;
        this.sortingType = event.currentTarget.dataset.id;
        if(this.sortingType != 'StudySite'){
            this.soritingShow = false;
        }else{
            this.soritingShow = true;
        }
        if(this.uparrow){
            this.downarrow = true;
            this.uparrow = false;
            this.sortingorder = 'DESC';
            this.getteledetails(this.recordId);
        }else{
            this.downarrow = false;
            this.uparrow = true;
            this.sortingorder = 'ASC';
            this.getteledetails(this.recordId);
        }
    }
    
    handlePaginatorChanges(event) {
        this.televisitdetails = event.detail;
        this.rowNumberOffset = this.televisitdetails[0].rowNumber - 1;
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
        this.showTelevisitscreen = !this.showTelevisitscreen;
        console.log('LMS Message'+message);
        this.receivedMessage = message
        ? JSON.stringify(message, null, "\t")
        : "no message";
    }

    handleUnsubscribe() {
        console.log("in handle unsubscribe");
    
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
    handleClear() {
        this.receivedMessage = null;
    }
    updateremindervalues(event){
        this.isSpinner = true;
        let studysiteid = event.currentTarget.dataset.id;
        let targetId = event.target.dataset.targetId;
        console.log('++++++++++'+studysiteid);
        console.log('++++++++++targetId'+targetId);
        console.log('++++++++++111'+event.target.value);
        updateremindervalues({ studysiteId:studysiteid,remindername:targetId,selValue:event.target.value})
        .then((result) => {
            console.log('result-->'+result);
            this.isSpinner = false;
          //  this.getteledetails(this.recordId);
        })
        .catch((error) => {
            this.isSpinner = false;
            console.log(JSON.stringify(error));
        });
    }    
}