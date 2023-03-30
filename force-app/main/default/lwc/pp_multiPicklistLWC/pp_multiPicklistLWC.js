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
    @api picklistLabel;

    @track firstThreeselectedStudyies = [];
    subscription = null;
    //resetAll;
    openStudyList = false;

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
            this.template
                .querySelector('.disable-dropdown')
                .classList.add('std-multipicklist-disabled');
            this.template
                .querySelector('.disable-select-all')
                .classList.add('std-disable-select-all');
        }
        if (message.isDisabled == false) {
            this.template.querySelector('.disable-dropdown').classList.forEach((cls) => {
                if (cls === 'std-multipicklist-disabled') {
                    this.template
                        .querySelector('.disable-dropdown')
                        .classList.remove('std-multipicklist-disabled');
                }
            });
            if (
                this.template.querySelector('.disable-select-all') != null ||
                this.template.querySelector('.disable-select-all') != undefined
            ) {
                this.template.querySelector('.disable-select-all').classList.forEach((cls) => {
                    if (cls === 'std-disable-select-all') {
                        this.template
                            .querySelector('.disable-select-all')
                            .classList.remove('std-disable-select-all');
                    }
                });
            }
        }
    }
    //Subscribe the message channel
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    //Reselt all the multipliclist valies selected.
    removeAll(event) {
        let studyElement = this.template.querySelector('[data-id="studyBox"]');
        let opts = studyElement.getElementsByTagName('lightning-input');
        for (var i = 0; i < opts.length; i++) {
            opts[i].checked = false;
        }
        this.selectedStudy = [];
        this.studyListStr = '';
        this.setStudyList(event, true);
        this.template.querySelector('.eBox').blur();
        //Unbold all the selected study labels.
        let checkboxes = this.template.querySelectorAll('[data-clsid="check-box-label"]');
        for (var i = 0; i < checkboxes.length; ++i) {
            checkboxes[i].classList.remove('text-checked-bold');
        }
    }
    //Select all the multipiclist values avaible in dropdown.
    selectAll(event) {
        let studyElement = this.template.querySelector('[data-id="studyBox"]');
        let opts = studyElement.getElementsByTagName('lightning-input');
        for (var i = 0; i < opts.length; i++) {
            opts[i].checked = true;
        }
        this.setStudyList(event, true);
        //this.template.querySelector('.eBox').blur();
        //Bold all the selected study labels.
        let checkboxes = this.template.querySelectorAll('[data-clsid="check-box-label"]');
        for (var i = 0; i < checkboxes.length; ++i) {
            checkboxes[i].classList.add('text-checked-bold');
        }
    }
    openStudy() {
        if (!this.openStudyList) {
            this.template.querySelector('.eBoxOpen').classList.add('slds-is-open');
            this.openStudyList = true;
        } else {
            this.template.querySelector('.eBoxOpen').classList.remove('slds-is-open');
            this.openStudyList = false;
        }
    }
    closeStudy() {
        this.template.querySelector('.eBoxOpen').classList.remove('slds-is-open');
        this.openStudyList = false;
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
            if (this.isDesktop) {
                if (this.selectedStudy.length > 3) {
                    return ' + ' + (this.selectedStudy.length - 3) + ' ' + this.label.More;
                }
            } else {
                if (this.selectedStudy.length > 1) {
                    return ' + ' + (this.selectedStudy.length - 1) + ' ' + this.label.More;
                }
            }
        }
        return ' ';
    }

    //Return if no Study selected.
    get isNoStudySelected() {
        return this.selectedStudy.length == 0 ? true : false;
    }
    //Show Select All if all the studies are selected.
    get showSelectAll() {
        const totalSelectedStudies = this.selectedStudy.length;
        console.log('Show All totalSelectedStudies: ', totalSelectedStudies);
        console.log('Show All totalNoOfStudies: ', this.totalNoOfStudies);
        return totalSelectedStudies != this.totalNoOfStudies ? true : false;
    }

    get getSelectLable() {
        return this.label.Select;
    }
    //Show clear All if at least one sutudy is not selected.
    get showClearAll() {
        const totalSelectedStudies = this.selectedStudy.length;
        console.log('clear All totalSelectedStudies: ', totalSelectedStudies);
        console.log('Clear All totalNoOfStudies: ', this.totalNoOfStudies);
        return totalSelectedStudies != 0 && totalSelectedStudies == this.totalNoOfStudies
            ? true
            : false;
    }
    get studyMoreClass() {
        return this.addNewDelegate ? 'study-thmore-add-newdel' : 'study-thmore-add-assignment';
        // if(this.addNewDelegate){
        //     return 'study-thmore-add-newdel';
        //   }else{
        //     return 'study-thmore-add-assignment';
        //   }
    }
    divSetStudy(event) {
        event.currentTarget.getElementsByTagName('lightning-input')[0].checked =
            !event.currentTarget.getElementsByTagName('lightning-input')[0].checked;
        this.setStudyList(event, false);
    }
    setStudyList(event, selectAllRemoveAll) {
        let tempList = [];
        let tempFirstThreeList = [];
        let studyElement = this.template.querySelector('[data-id="studyBox"]');
        let opts = studyElement.getElementsByTagName('lightning-input');
        let studyOpts = [];
        let checkedCount = 0;
        for (var i = 0; i < opts.length; i++) {
            if (opts[i].checked) {
                tempList.push({ label: opts[i].name, value: opts[i].value });
                studyOpts.push(opts[i].value);
                //Store First Three selected Studies in separate List.
                if (tempFirstThreeList.length <= 2) {
                    tempFirstThreeList.push({ label: opts[i].name, value: opts[i].value });
                }
            }
        }
        //When this is not called from SelectAll/RemoveAll fucntion.
        if (!selectAllRemoveAll) {
            let datalebelid = event.target.dataset.id;
            let checked = event.target.checked;
            let query = '[data-labelid="' + datalebelid + '"]';
            let studylebelElement = this.template.querySelector(query);
            //make the Study lable bold/unbold.
            if (checked) {
                studylebelElement.classList.add('text-checked-bold');
            } else if (studylebelElement.classList.contains('text-checked-bold')) {
                studylebelElement.classList.remove('text-checked-bold');
            }
        }

        this.studyListStr = studyOpts.join(';');
        this.selectedStudy = [];
        this.selectedStudy = this.selectedStudy.concat(tempList);
        this.firstThreeselectedStudyies = [];
        this.firstThreeselectedStudyies =
            this.firstThreeselectedStudyies.concat(tempFirstThreeList);
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
