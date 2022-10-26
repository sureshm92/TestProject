import { LightningElement, track, api, wire } from 'lwc';
import Clear_All from '@salesforce/label/c.RPR_Clear_All';
import Select_All_PI from '@salesforce/label/c.Select_All_PI';
import More from '@salesforce/label/c.PIR_more';
import PG_MS_L_Studies_up from '@salesforce/label/c.PG_MS_L_Studies_up';
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
        PG_MS_L_Studies_up
    };
    /* @api*/ picklistValues = [];
    @api selectedStudy = [];
    @api studyListStr = '';
    subscription = null;
    //resetAll;
    totalNoOfStudis;

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
        //If we recieve Piclist Value from Parent component.
        if (message.piclistValues) {
            this.picklistValues = message.piclistValues;
            this.totalNoOfStudis = this.picklistValues.length;
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
        this.template.querySelector('.eBoxOpen').classList.add('slds-is-open');
    }
    closeStudy() {
        this.template.querySelector('.eBoxOpen').classList.remove('slds-is-open');
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
            if (this.selectedStudy.length > 1) {
                //return "+" + (this.selectedStudy.length-1)+" more" ;
                return '+' + (this.selectedStudy.length - 1) + ' ' + this.label.More;
            }
        }
        return '';
    }

    //Show Select All if all the studies are selected.
    get showSelectAll() {
        const totalSelectedStudies = this.selectedStudy.length;
        return totalSelectedStudies != 0 && totalSelectedStudies != this.totalNoOfStudis
            ? true
            : false;
    }
    //Show clear All if at least one sutudy is not selected.
    get showClearAll() {
        const totalSelectedStudies = this.selectedStudy.length;
        return totalSelectedStudies != 0 && totalSelectedStudies == this.totalNoOfStudis
            ? true
            : false;
    }
    divSetStudy(event) {
        event.currentTarget.getElementsByTagName('input')[0].checked =
            !event.currentTarget.getElementsByTagName('input')[0].checked;
        this.setStudyList();
    }
    setStudyList() {
        let tempList = [];
        let studyElement = this.template.querySelector('[data-id="studyBox"]');
        let opts = studyElement.getElementsByTagName('input');
        let studyOpts = [];
        for (var i = 0; i < opts.length; i++) {
            if (opts[i].checked) {
                tempList.push({ label: opts[i].name, value: opts[i].value });
                studyOpts.push(opts[i].value);
            }
        }
        this.studyListStr = studyOpts.join(';');
        this.selectedStudy = [];
        this.selectedStudy = this.selectedStudy.concat(tempList);
        this.template.querySelector('.eBox').focus();
        this.sendFilterUpdates();
    }
    //Send Data to Parent coponent by LMS.
    sendFilterUpdates() {
        const payLoad = {
            selectedListOfStudies: this.selectedStudy
        };
        publish(this.messageContext, messageChannel, payLoad);
        //this.removeAll();
        // this.isAnythingChangedForReset = false;
    }
}
