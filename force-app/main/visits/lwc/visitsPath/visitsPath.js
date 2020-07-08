/**
 * Created by Igor Malyuta on 06.12.2019.
 */

import {LightningElement, track} from 'lwc';
import formFactor from '@salesforce/client/formFactor';

import addLabel from '@salesforce/label/c.Add_Date';
import saveBTNLabel from '@salesforce/label/c.BTN_Save';
import cancelBTNLabel from '@salesforce/label/c.BTN_Cancel';
import planDate from '@salesforce/label/c.VPN_AddDate';
import selDate from '@salesforce/label/c.VPN_Sel_Date';
import visitUnavailable from '@salesforce/label/c.Study_Visit_Unavailable';

import getCardVisits from '@salesforce/apex/ParticipantVisitsRemote.getCardPatientVisits';
import updatePV from '@salesforce/apex/ParticipantVisitsRemote.updatePatientVisit';

const stateClass = 'slds-col width-basis state ';
const lineClass = 'slds-col width-basis line-div ';
const iconCalendar = 'icon-calendar-3';
const iconMissed = 'icon-minus';
const stateNeutral = 'neutral';
const statePlan = 'planned';
const stateMissed = 'missed';
const stateSucc = 'success';

export default class VisitsPath extends LightningElement {

    labels = {
        addLabel,
        saveBTNLabel,
        cancelBTNLabel,
        selDate,
        planDate
    };

    initialized = false;
    spinner;

    @track isVisitsEmpty = false;
    @track patientVisits;
    @track pathItems = [];

    @track selectedPV = {
        Id: null,
        Planned_Date__c: null,
    };
    @track planDate = null;

    pathContainer;
    elementWidth;
    centredIndex;
    maxScrollValue;
    scrollStep;
    nextScrollLeft;
    nextScrollRight;
    fromLeftCorner;
    fromRightCorner;

    connectedCallback() {
        let context = this;
        getCardVisits()
            .then(function (data) {
                context.patientVisits = data;
                context.isVisitsEmpty = data.length === 0;
                context.constructPathItems();
                context.initialized = true;
            })
            .catch(function (error) {
                console.error('Error: ' + JSON.stringify(error));
            });
    }

    renderedCallback() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if(!this.initialized) this.spinner.show();

        switch (formFactor) {
            case 'Medium':
                this.elementWidth = 145;
                break;
            case 'Small':
                this.elementWidth = 250;
                break;
            default:
                this.elementWidth = 125;
        }

        this.pathContainer = this.template.querySelector('.vis-path');
        if (this.pathContainer) {
            this.maxScrollValue = this.pathContainer.scrollWidth - this.pathContainer.clientWidth;
            if (this.pathContainer.scrollWidth > this.pathContainer.clientWidth) this.doScrollInto(this.centredIndex);

            let context = this;
            setTimeout(function () {
                if (context.pathItems.length > 0) {
                    context.calculateWidth();

                    window.addEventListener('touchmove', function () {
                        context.changeArrowsStyle();
                    });
                    window.addEventListener('resize', function () {
                        context.calculateWidth();
                    });
                }
            }, 150);
        }

        if(this.initialized) this.spinner.hide();
    }

    constructPathItems() {
        if (this.patientVisits) {
            let firstPending;
            this.centredIndex = 1;
            for (let i = 0; i < this.patientVisits.length; i++) {
                let isCompleted = this.patientVisits[i].Status__c === 'Completed';
                let isMissed = this.patientVisits[i].Status__c === 'Missed';
                let item = {
                    id: this.patientVisits[i].Id,
                    visitName: this.patientVisits[i].Portal_Name__c ? this.patientVisits[i].Portal_Name__c : this.patientVisits[i].Name,
                    isPending: !isCompleted && !isMissed,
                    icon: isMissed ? iconMissed : iconCalendar,
                    complDate: isCompleted ? this.patientVisits[i].Completed_Date__c : null,
                    planDate: (!isMissed && !isCompleted && this.patientVisits[i].Planned_Date__c) ? this.patientVisits[i].Planned_Date__c : null,
                    stateStatus: isCompleted ? stateSucc : stateNeutral
                };
                if (isMissed) {
                    item.stateStatus = stateMissed;
                    item.complDate = visitUnavailable;
                }

                this.pathItems.push(item);
                if (!firstPending && !isCompleted && !isMissed) {
                    firstPending = item;
                    this.centredIndex = i;
                }
            }
            if (firstPending) {
                firstPending.stateStatus = statePlan;
            }

            for (let i = 0; i < this.pathItems.length; i++) {
                let item = this.pathItems[i];
                item.right = i < this.pathItems.length - 1 ? lineClass + this.pathItems[i + 1].stateStatus : lineClass + item.stateStatus;
                item.left = lineClass + item.stateStatus;
                item.state = stateClass + item.stateStatus;
            }

            console.log('VISIT_ITEMS: ' + JSON.stringify(this.pathItems));
        }
    }

    //Planned Date Logic:-----------------------------------------------------------------------------------------------
    handleOpenDialog(event) {
        let eventItemId = event.currentTarget.dataset.id;

        this.pathItems.forEach(item => {
            if (item.id === eventItemId) {
                this.selectedPV.Id = item.id;
                this.planDate = item.Planned_Date__c;
                this.template.querySelector('c-web-popup').show();
            }
        });
    }

    handleHideDialog() {
        this.template.querySelector('c-web-popup').hide();
    }

    handleDateChange(event) {
        this.planDate = event.target.value;
    }

    savePlannedDate() {
        this.handleHideDialog();
        let spinner = this.template.querySelector('c-web-spinner');
        spinner.show();

        if(this.planDate) this.selectedPV.Planned_Date__c = this.planDate;
        else this.selectedPV.Planned_Date__c = null;

        let context = this;
        updatePV({visit: JSON.stringify(this.selectedPV)})
            .then(() => {
                let tmpItems = [];
                context.pathItems.forEach(item => {
                    let tmpItem = item;
                    if (item.id === context.selectedPV.Id) tmpItem.planDate = context.planDate;

                    tmpItems.push(tmpItem);
                });
                context.pathItems = tmpItems;
                spinner.hide();
            })
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            });
    }

    //Scroll Arrows handlers:-------------------------------------------------------------------------------------------
    handleScrollLeft() {
        if (this.fromRightCorner) {
            this.doScrollInto(this.pathItems.length - (formFactor === 'Small' ? 1 : 2));
            this.nextScrollRight = this.scrollStep;
            this.fromRightCorner = false;
        } else {
            this.pathContainer.scrollLeft -= this.nextScrollLeft;
        }

        let context = this;
        setTimeout(function () {
            context.nextScrollLeft = context.scrollStep;
            context.checkCloserIsNeeded(context);
            context.changeArrowsStyle();
        }, 450);
    }

    handleScrollRight() {
        if (this.fromLeftCorner) {
            this.doScrollInto((formFactor === 'Large' ? 4 : 2));
            this.nextScrollLeft = this.scrollStep;
            this.fromLeftCorner = false;
        } else {
            this.pathContainer.scrollLeft += this.nextScrollRight;
        }

        let context = this;
        setTimeout(function () {
            context.nextScrollRight = context.scrollStep;
            context.checkCloserIsNeeded(context);
            context.changeArrowsStyle();
        }, 450);
    }

    //Scroll logic:-----------------------------------------------------------------------------------------------------
    calculateWidth() {
        this.scrollStep = this.elementWidth;
        this.nextScrollLeft = this.scrollStep;
        this.nextScrollRight = this.scrollStep;

        if (this.pathContainer.scrollWidth > this.pathContainer.clientWidth) this.changeArrowsStyle();
    }

    isLeftScrollEnd() {
        return this.pathContainer.scrollLeft === 0;
    }

    isRightScrollEnd() {
        return (this.maxScrollValue <= (Math.ceil(this.pathContainer.scrollLeft)));
    }

    changeArrowsStyle() {
        let arrLeft = 1;
        let arrRight = 1;

        if (this.isRightScrollEnd()) {
            arrRight = 0.3;
            this.fromRightCorner = true;
        }
        if (this.isLeftScrollEnd()) {
            arrLeft = 0.3;
            this.fromLeftCorner = true;
        }

        this.template.querySelector('.arrow-left').style.opacity = arrLeft;
        this.template.querySelector('.arrow-right').style.opacity = arrRight;
    }

    checkCloserIsNeeded(context) {
        if ((context.maxScrollValue - (context.pathContainer.scrollLeft + context.nextScrollRight)) < (context.scrollStep / 2)) {
            context.nextScrollRight = context.maxScrollValue;
        }
        if ((context.pathContainer.scrollLeft - context.nextScrollLeft) < (context.scrollStep / 2)) {
            context.nextScrollLeft = context.maxScrollValue;
        }
    }

    doScrollInto(index) {
        this.pathContainer.scrollLeft = (index * this.elementWidth) - (this.elementWidth / 2) - (this.pathContainer.clientWidth / 2);
    }
}