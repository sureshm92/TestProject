import { LightningElement, track, api, wire } from 'lwc';
import Clear_All from '@salesforce/label/c.RPR_Clear_All';
import Select_All_PI from '@salesforce/label/c.Select_All_PI';
import More from '@salesforce/label/c.PIR_more';
import PG_MS_L_Studies_up from '@salesforce/label/c.PG_MS_L_Studies_up';
import Select from '@salesforce/label/c.Select';
import messageChannel from '@salesforce/messageChannel/ppLightningMessageService__c';
import {
    publish, 
    subscribe,
    unsubscribe,
    MessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService'; 
export default class Pp_multiPicklistLWC extends LightningElement {
    label = {
        Select_All_PI,
        Clear_All,
        More,
        PG_MS_L_Studies_up,
        Select
    };
    @api picklistValues = [];
    @api selectedStudy = [];
    @api studyListStr = '';
    @api totalNoOfStudies;
    @api isDesktop;
    @api addNewDelegate;

    @track firstThreeselectedStudyies = [];
    subscription = null;
    //resetAll;
    openStudyList=false;
   

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel(); 
    }
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    //Subscribe the message channel to read the message published.
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                messageChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    //Handler for message received by Aura component
    handleMessage(message) {
        //If we revieve reset all from parent component.
        if (message.ResetAll) {
            this.removeAll();
        }
        //If we recieved isDisabled flag from Parent component.
        if (message.isDisabled == true) {
            this.template.querySelector('.disable-dropdown').classList.add('std-multipicklist-disabled');
            this.template.querySelector('.disable-select-all').classList.add('std-disable-select-all');
        }
        if (message.isDisabled == false) {
            this.template.querySelector('.disable-dropdown').classList.remove('std-multipicklist-disabled');
            this.template.querySelector('.disable-select-all').classList.remove('std-disable-select-all');
        }
    }
    //Subscribe the message channel
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    //Reselt all the multipliclist valies selected.
    removeAll() {
        let studyElement = this.template.querySelector('[data-id="studyBox"]');
        let opts = studyElement.getElementsByTagName('input');
        for (var i = 0; i < opts.length; i++) {
            opts[i].checked = false;
        }
        this.selectedStudy = [];
        this.studyListStr = '';
        this.setStudyList();
        this.template.querySelector('.eBox').blur();
    }
    //Select all the multipiclist values avaible in dropdown.
    selectAll() {
        let studyElement = this.template.querySelector('[data-id="studyBox"]');
        let opts = studyElement.getElementsByTagName('input');
        for (var i = 0; i < opts.length; i++) {
            opts[i].checked = true;
        }
        this.setStudyList();
        //this.template.querySelector('.eBox').blur();
    }
    openStudy() {
        if(!this.openStudyList){
            this.template.querySelector('.eBoxOpen').classList.add('slds-is-open');
            this.openStudyList=true;
        }else{
            this.template.querySelector('.eBoxOpen').classList.remove('slds-is-open');
            this.openStudyList=false;
        }
        
    }
    closeStudy() {
        this.template.querySelector('.eBoxOpen').classList.remove('slds-is-open');
        this.openStudyList=false;
    }
    get getFirstSelecedStudy() {
        if (this.selectedStudy) {
            if (this.selectedStudy.length > 0) {
                return this.selectedStudy[0].label;
            }
        }
        return null;
    }

    get studyCount() {
        if (this.selectedStudy) {
            if(this.isDesktop){
                if (this.selectedStudy.length > 3) {
                    return ' + ' + (this.selectedStudy.length - 3) + ' ' + this.label.More;
                }
            }else{
                if (this.selectedStudy.length > 1) {
                    return ' + ' + (this.selectedStudy.length - 1) + ' ' + this.label.More;
                }
            }
            
        }
        return ' ';
    }

    //Return if no Study selected.
    get isNoStudySelected(){
        return this.selectedStudy.length==0 ? true: false;
    }
    //Show Select All if all the studies are selected.
    get showSelectAll() {
        const totalSelectedStudies = this.selectedStudy.length;
        console.log('Show All totalSelectedStudies: ',totalSelectedStudies);
        console.log('Show All totalNoOfStudies: ',this.totalNoOfStudies);
        return totalSelectedStudies != this.totalNoOfStudies
            ? true
            : false;
    }

    get getSelectLable(){
        return this.label.Select;
    }
    //Show clear All if at least one sutudy is not selected.
    get showClearAll() {
        const totalSelectedStudies = this.selectedStudy.length;
        console.log('clear All totalSelectedStudies: ',totalSelectedStudies);
        console.log('Clear All totalNoOfStudies: ',this.totalNoOfStudies);
        return totalSelectedStudies != 0 && totalSelectedStudies == this.totalNoOfStudies
            ? true
            : false;
    }
    get studyMoreClass(){
        return this.addNewDelegate ? 'study-thmore-add-newdel' : 'study-thmore-add-assignment';
        // if(this.addNewDelegate){
        //     return 'study-thmore-add-newdel';
        //   }else{
        //     return 'study-thmore-add-assignment';
        //   }
    }
    divSetStudy(event) {
        event.currentTarget.getElementsByTagName('input')[0].checked =
            !event.currentTarget.getElementsByTagName('input')[0].checked;
        this.setStudyList();
    }
    setStudyList() {
        let tempList = [];
        let tempFirstThreeList = [];
        let studyElement = this.template.querySelector('[data-id="studyBox"]');
        let opts = studyElement.getElementsByTagName('input');
        let studyOpts = [];
        let checkedCount = 0;
        for (var i = 0; i < opts.length; i++) {
            if (opts[i].checked) {
                tempList.push({ label: opts[i].name, value: opts[i].value });
                studyOpts.push(opts[i].value);
                //Store First Three selected Studies in separate List.
                if(tempFirstThreeList.length<=2){
                    tempFirstThreeList.push({ label: opts[i].name, value: opts[i].value });
                }
            }
            
        }
        this.studyListStr = studyOpts.join(';');
        this.selectedStudy = [];
        this.selectedStudy = this.selectedStudy.concat(tempList);
        this.firstThreeselectedStudyies = [];
        this.firstThreeselectedStudyies = this.firstThreeselectedStudyies.concat(tempFirstThreeList);
        this.template.querySelector('.eBox').focus();
        this.sendFilterUpdates();
    }
    //Send Data to Parent component by LMS.
    sendFilterUpdates() {
        const payLoad = {
            selectedListOfStudies: this.selectedStudy
        };
        publish(this.messageContext, messageChannel, payLoad);
        //this.removeAll();
        // this.isAnythingChangedForReset = false;
    }
}