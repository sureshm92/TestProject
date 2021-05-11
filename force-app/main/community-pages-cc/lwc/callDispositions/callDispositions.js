import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import getcalls from '@salesforce/apex/FetchCallDispositions.getcalls';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import gettodaydate from '@salesforce/apex/FetchCallDispositions.gettodaydate';
import CALLDISPOSTION_OBJ from '@salesforce/schema/Call_Dispositions__c';
import CATEGORY_FIELD from '@salesforce/schema/Call_Dispositions__c.Call_Category__c';
import INBOUND_FIELD from '@salesforce/schema/Call_Dispositions__c.Inbound_Outbound__c';
import {refreshApex} from '@salesforce/apex';
import Previous_Call_Dispositions from '@salesforce/label/c.Previous_Call_Dispositions';
import View_More from '@salesforce/label/c.View_More';
import No_records_to_display from '@salesforce/label/c.No_records_to_display';
import New_Call from '@salesforce/label/c.New_Call';
import Call_Category from '@salesforce/label/c.Call_Category';
import Select_Call_Catagory from '@salesforce/label/c.Select_Call_Catagory';
import Caller from '@salesforce/label/c.Caller';
import Inbound_Outbound from '@salesforce/label/c.Inbound_Outbound';
import IQVIA_intervention_required from '@salesforce/label/c.IQVIA_intervention_required';
import IQVIA_intervention_completed from '@salesforce/label/c.IQVIA_intervention_completed';
import Notes from '@salesforce/label/c.Notes';
import Type_in_your_notes from '@salesforce/label/c.Type_in_your_notes';
export default class CallDispositions extends LightningElement {
    @track error;
    @track conName;
    @api records = [];
    @api errors;
    @api dateerror;
    @api todaydate;
    @api day;
    @api month; @api siteId; @api Oldcaller;@api Oldcallinterventioncompleted;
    @api year; @api callDateTime; @api isCDValitated = false; @api newcallnotes; @api callcategoryvalue; @api interventionreq = false;
    @api defcallbound = 'Inbound'; @api count; selected; @track InterventionRequired = false;
    @api rwindx; @api call; @api ViewMode = false; @api Oldcallcategory; @api Oldcallbound; @api newcall = false;
    @api Oldcallintervention; @api Oldcallnotes; @api Oldcalldate; @api limit = 5; @api initloaded = false; @api Refreshed = false;
    
    label = {
        Previous_Call_Dispositions,
        View_More,
        No_records_to_display,
        New_Call,
        Call_Category,
        Select_Call_Catagory,
        Caller,
        Inbound_Outbound,
        IQVIA_intervention_required,
        IQVIA_intervention_completed,
        Notes,
        Type_in_your_notes
    };
    
    @wire(getObjectInfo, { objectApiName: CALLDISPOSTION_OBJ })

    calldispositionObj;

    @wire(getPicklistValues,
        {

            recordTypeId: '$calldispositionObj.data.defaultRecordTypeId',

            fieldApiName: CATEGORY_FIELD

        }

    )

    categoryoptions({ error, data }) {
        if(data)
            this.callcategorys = data.values;
    
    }

    @wire(getPicklistValues,
        {

            recordTypeId: '$calldispositionObj.data.defaultRecordTypeId',

            fieldApiName: INBOUND_FIELD

        }

    )

    boundoptions({ error, data }) {
        if(data)
            this.callboundoptions = data.values;
     
    }
    
   /* get callcategorys() {
        return [
            { label: 'Welcome Call Complete', value: 'Welcome Call Complete' },
            { label: 'First Referral Call Complete', value: 'First Referral Call Complete' },
            { label: 'Aged Referral Call Complete', value: 'Aged Referral Call Complete' },
            { label: 'Left Message', value: 'Left Message' },
            { label: 'No Answer', value: 'No Answer' },
            { label: 'Follow up needed', value: 'Follow up needed' },
            { label: 'Other', value: 'Other' },
        ];
    }
    get callboundoptions() {
        return [
            { label: 'Inbound', value: 'Inbound' },
            { label: 'Outbound', value: 'Outbound' },
        ];
    }  */
    onCheckboxChange(event) {
        this.InterventionRequired = event.target.checked;
        const value = event.target.checked;
        this.interventionreq = value;
        const valueChangeEvent = new CustomEvent("interventionchange", {
            detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }
    @wire(gettodaydate)
    wireddate({
        data, error
    }) {
        if (data) {
            this.day = data.day;
            this.month = data.month;
            this.year = data.year;
            this.conName = data.conName;
            this.dateerror = undefined;
        }
        if (error) {
            this.dateerror = error;
            this.todaydate = undefined;
        }
    }
    @api
    Refresh() {
        getcalls({ limits: this.limit, siteId: this.siteId })
            .then((result) => {
               
                this.records = result.lstCDs;
                this.count = result.count;
                console.log('<---Refresh-->');
                console.log('count-->' + this.count);
                this.errors = undefined;
                if (this.newcall == false) {
                    this.ViewMode = true;
                }
                console.log('ViewMode-->' + this.ViewMode);
                //if (this.initloaded == false) {
                    if(this.count !=0){
                        this.Oldcallcategory = this.records[0].cd.Call_Category__c;
                        this.Oldcallbound = this.records[0].cd.Inbound_Outbound__c;
                        this.Oldcallintervention = this.records[0].cd.IQVIA_intervention_required__c;
                        this.Oldcallinterventioncompleted=this.records[0].cd.IQVIA_intervention_completed__c;
                        this.Oldcallnotes = this.records[0].cd.Notes__c;
                        this.Oldcalldate = this.records[0].dtcd;
                        this.Oldcaller = this.records[0].cd.Caller__r.Name;
                    }else{
                        this.Oldcallcategory = '';
                        this.Oldcallbound = '';
                        this.Oldcallintervention = '';
                        this.Oldcallinterventioncompleted=false;
                        this.Oldcallnotes = '';
                        this.Oldcalldate = '';
                        this.Oldcaller = this.conName;
                    }
                   
                    this.initloaded = true;
                //}
                this.Refreshed = true;
            })
            .catch((error) => {
                this.errors = error;
                console.log(error);
                this.records = undefined;
                this.ViewMode = true;
                this.count = 0;
                this.Oldcallcategory = '';
                this.Oldcallbound = '';
                this.Oldcallintervention = '';
                this.Oldcallinterventioncompleted=false;
                this.Oldcallnotes = '';
                this.Oldcalldate = '';
                this.Oldcaller = this.conName;
            });
    }
    @api
    RefreshSection() {
        getcalls({ limits: this.limit, siteId: this.siteId })
            .then((result) => {
               
                this.records = result.lstCDs;
                this.count = result.count;
                console.log('<---Refresh-->');
                console.log('count-->' + this.count);
                this.errors = undefined;
                //if (this.newcall == false) {
                    this.ViewMode = true;
               // }
                console.log('ViewMode-->' + this.ViewMode);
                //if (this.initloaded == false) {
                    if(this.count !=0){
                        this.Oldcallcategory = this.records[0].cd.Call_Category__c;
                        this.Oldcallbound = this.records[0].cd.Inbound_Outbound__c;
                        this.Oldcallintervention = this.records[0].cd.IQVIA_intervention_required__c;
                        this.Oldcallinterventioncompleted=this.records[0].cd.IQVIA_intervention_completed__c;
                        this.Oldcallnotes = this.records[0].cd.Notes__c;
                        this.Oldcalldate = this.records[0].dtcd;
                        this.Oldcaller = this.records[0].cd.Caller__r.Name;
                    }else{
                        this.Oldcallcategory = '';
                        this.Oldcallbound = '';
                        this.Oldcallintervention = '';
                        this.Oldcallinterventioncompleted=false;
                        this.Oldcallnotes = '';
                        this.Oldcalldate = '';
                        this.Oldcaller = this.conName;
                    }
                   
                    this.initloaded = true;
                //}
                this.Refreshed = true;
            })
            .catch((error) => {
                this.errors = error;
                console.log(error);
                this.records = undefined;
                this.ViewMode = true;
                this.count = 0;
                this.Oldcallcategory = '';
                this.Oldcallbound = '';
                this.Oldcallintervention = '';
                this.Oldcallnotes = '';
                this.Oldcalldate = '';
                this.Oldcaller = this.conName;
            });
    }
    handleClick(event) {
        this.rwindx = event.currentTarget.dataset.value;
        this.call = this.records[this.rwindx];
        this.ViewMode = true;
        this.Oldcallcategory = this.call.cd.Call_Category__c;
        this.Oldcallbound = this.call.cd.Inbound_Outbound__c;
        this.Oldcallintervention = this.call.cd.IQVIA_intervention_required__c;
        this.Oldcallinterventioncompleted=this.call.cd.IQVIA_intervention_completed__c;
        this.Oldcallnotes = this.call.cd.Notes__c;
        this.Oldcalldate = this.call.dtcd;
        this.Oldcaller = this.call.cd.Caller__r.Name;
        this.newcall = false;

        event.target.classList.add('highlight');
        this.unselect(event.target);
        this.selected = event.target;
        this.template.querySelector('c-call-dispositions-details').unselect(event.target);
        const valueChangeEvent = new CustomEvent("listselection", {
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }
    unselect(target) {
        if (this.selected && this.selected !== target) {
            this.selected.classList.remove('highlight');
            this.selected = null;
        }
    }

    @api
    newCall() {
        this.initloaded = true;
        if (this.Refreshed == false) {
            this.Refresh();
        }
        this.ViewMode = false;
        this.newcall = true;
        this.newcallnotes = '';
        this.defcallbound = 'Inbound';
        this.InterventionRequired =false;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.type === 'checkbox' ){
              element.checked = false;
            } 
          });
        this.template.querySelectorAll('[data-id="callbound"]').forEach(each => {
            each.value = 'Inbound';
        });
        this.template.querySelectorAll('[data-id="callcategory"]').forEach(each => {
            each.value = '';
        });
        let callcatgval='';
        const valueChangeEvent1 = new CustomEvent("callcategchange", {
            detail: { callcatgval }
        });
        this.dispatchEvent(valueChangeEvent1);
        let callboundval="Inbound";
        const valueChangeEvent2 = new CustomEvent("callBoundchange", {
            detail: { callboundval }
        });
        this.dispatchEvent(valueChangeEvent2);
        let callinterventionreqval="false";
        const valueChangeEvent3 = new CustomEvent("interventionchange", {
            detail: { callinterventionreqval }
        });
        this.dispatchEvent(valueChangeEvent3);
        let callnotes=" ";
        const valueChangeEvent4 = new CustomEvent("valuechange", {
            detail: { callnotes }
        });
        this.dispatchEvent(valueChangeEvent4);


        console.log('ViewMode-->New call' + this.ViewMode);
        this.template.querySelector('c-call-dispositions-details').unselectNew();
        this.selected.classList.remove('highlight');
        this.selected = null;
        
    }
    ViewMore(event) {
        this.limit = this.limit + 5;
        //this.Refresh();
        getcalls({ limits: this.limit, siteId: this.siteId })
        .then((result) => {
           
            this.records = result.lstCDs;
            this.count = result.count;
            console.log('<---Refresh-->');
            console.log('count-->' + this.count);
            this.errors = undefined;
            if (this.newcall == false) {
                this.ViewMode = true;
            }
            console.log('ViewMode-->' + this.ViewMode);
            //if (this.initloaded == false) {
                this.initloaded = true;
            //}
            this.Refreshed = true;
        })
        .catch((error) => {
            this.errors = error;
            console.log(error);
            this.records = undefined;
            this.ViewMode = true;
            this.count = 0;
            this.Oldcallcategory = '';
            this.Oldcallbound = '';
            this.Oldcallintervention = '';
            this.Oldcallinterventioncompleted=false;
            this.Oldcallnotes = '';
            this.Oldcalldate = '';
            this.Oldcaller = this.conName;
        });
    }
    get showViewMore() {
        if (this.limit >= this.count) return false;
        return true;
    }
    get isRecordExists() {
        if (this.count > 0) return true;
        return false;
    }
    handlenotes(event) {
        const value = event.target.value;
        this.newcallnotes = value;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }

    handlecallcategory(event) {
        const value = event.target.value;
        this.callcategoryvalue = value;
        const valueChangeEvent = new CustomEvent("callcategchange", {
            detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }
    handlecallbound(event) {
        const value = event.target.value;
        const valueChangeEvent = new CustomEvent("callBoundchange", {
            detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }
}