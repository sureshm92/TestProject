import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import getcalls from '@salesforce/apex/FetchCallDispositions.getcalls';
import gettodaydate from '@salesforce/apex/FetchCallDispositions.gettodaydate';
export default class CallDispositions extends LightningElement {
    @track error;
    @track conName;
    @api records = [];
    @api errors;
    @api dateerror;
    @api todaydate;
    @api day;
    @api month;@api siteId;
    @api year;@api callDateTime;@api isCDValitated=false;@api newcallnotes;@api callcategoryvalue;@api interventionreq=false;
    @api defcallbound = 'Inbound';@api count;selected;@track InterventionRequired=false;
    @api rwindx; @api call; @api ViewMode = false; @api Oldcallcategory; @api Oldcallbound; @api newcall = false;
    @api Oldcallintervention; @api Oldcallnotes; @api Oldcalldate; @api limit = 5; @api initloaded = false;@api Refreshed=false;
  /**   @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.conName = data.fields.Name.value;
        }
    }*/
    get callcategorys() {
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
    }
    onCheckboxChange(event) {
        this.InterventionRequired = event.target.checked;
        const value = event.target.checked;
        this.interventionreq=value;
        const valueChangeEvent = new CustomEvent("interventionchange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        console.log('iqvia intervention'+event.target.checked);
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
            console.log('yes'); console.log(data);
            console.log(this.month);
        }
        if (error) {
            this.dateerror = error;
            this.todaydate = undefined;
            console.log('No');
        }
    }
    /**  @wire(getcalls)
        wiredCalls({
            data,error
        }){
            if(data){
                this.records = data;
                this.errors = undefined;
                this.ViewMode=true;
                console.log('testwire'+this.records[0].Call_Category__c);
                this.Oldcallcategory=this.records[0].Call_Category__c;
                this.Oldcallbound=this.records[0].Inbound_Outbound__c;
                this.Oldcallintervention=this.records[0].IQVIA_intervention_required__c;
                this.Oldcallnotes=this.records[0].Notes__c;
                this.Oldcalldate=this.records[0].Call_Date__c;
            }
            if(error){
                this.errors= error;
                this.records= undefined;
            }
        }**/
     @api
    Refresh() {
        getcalls({ limits: this.limit,siteId: this.siteId })
            .then((result) => {
                console.log('records-->');
                this.records = result.lstCDs;
                console.log('records-->'+this.records);
                //this.callDateTime=result.callDateTime;
                this.count=result.count;
                this.errors = undefined;
                console.log('count'+this.count);
                if (this.newcall == false) {
                    this.ViewMode = true;
                    console.log('vmin'+this.ViewMode);
                }
                console.log('testwire' + this.records[0].cd.Call_Category__c);
                console.log(this.initloaded);
                if (this.initloaded == false) {
                    this.Oldcallcategory = this.records[0].cd.Call_Category__c;
                    this.Oldcallbound = this.records[0].cd.Inbound_Outbound__c;
                    this.Oldcallintervention = this.records[0].cd.IQVIA_intervention_required__c;
                    this.Oldcallnotes = this.records[0].cd.Notes__c;
                    this.Oldcalldate = this.records[0].dtcd;
                    this.initloaded = true;
                    console.log('in'+this.initloaded);
                }
                this.Refreshed=true;
                console.log('viewmoderef--->'+ this.ViewMode);
            })
            .catch((error) => {
                this.errors = error;
                console.log(error);
                this.records = undefined;
                this.count=0;
            });
    }
    handleClick(event) {

        console.log('Value = ' + event.currentTarget.dataset.value);
        this.rwindx = event.currentTarget.dataset.value;
        this.call = this.records[this.rwindx];
        console.log(this.call); console.log(this.ViewMode);
        this.ViewMode = true;
        console.log(this.ViewMode);
        console.log(this.call.cd.Call_Category__c);
        this.Oldcallcategory = this.call.cd.Call_Category__c;
        this.Oldcallbound = this.call.cd.Inbound_Outbound__c;
        this.Oldcallintervention = this.call.cd.IQVIA_intervention_required__c;
        this.Oldcallnotes = this.call.cd.Notes__c;
        this.Oldcalldate = this.call.dtcd;
        this.newcall = false;
        //this.template.querySelector('.highlight').classList.add('highlightCSS');
        //event.stopPropagation();
        event.target.classList.add('highlight');
        this.unselect(event.target);
        this.selected = event.target;
        this.template.querySelector('c-call-dispositions-details').unselect(event.target);
        const valueChangeEvent = new CustomEvent("listselection", {
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);
    }
    unselect(target){
        if (this.selected && this.selected !== target) {
            this.selected.classList.remove('highlight');
            this.selected = null;
        }
    }
    
    @api
    newCall() {
        this.initloaded = true;
        if(this.Refreshed==false){
          
            this.Refresh();
    
        }
        this.ViewMode = false;
        this.newcall = true;
        this.template.querySelector('c-call-dispositions-details').unselectNew();
        console.log('newcall');
        this.selected.classList.remove('highlight');
        this.selected = null;
        this.newcallnotes='';
        this.InterventionRequired=false;
        console.log('viewmode--->'+ this.ViewMode);
        
    }
    ViewMore(event){
        this.limit=this.limit+5;
        this.Refresh();
    }
    get showViewMore(){
        if(this.limit >= this.count) return false;
        return true;
    }
    handlenotes(event) {
        const value = event.target.value;
        this.newcallnotes=value;
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
      }
      
      handlecallcategory(event) {
        const value = event.target.value;
        this.callcategoryvalue=value;
        const valueChangeEvent = new CustomEvent("callcategchange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
      }
      handlecallbound(event){
        const value = event.target.value;
        const valueChangeEvent = new CustomEvent("callBoundchange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
      }
}