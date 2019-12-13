/**
 * Created by Igor Malyuta on 06.12.2019.
 */

import {LightningElement, track, wire} from 'lwc';
import formFactor from '@salesforce/client/formFactor';

import addLabel from '@salesforce/label/c.Add_Date';
import saveBTNLabel from '@salesforce/label/c.BTN_Save';
import cancelBTNLabel from '@salesforce/label/c.BTN_Cancel';

import getCardVisits from '@salesforce/apex/ParticipantVisitsRemote.getCardPatientVisits';
import updatePV from '@salesforce/apex/ParticipantVisitsRemote.updatePatientVisit';

const stateClass = 'slds-col width-basis state ';
const lineClass = 'slds-col width-basis line-div ';
const iconNeutral = 'icon-none';
const iconPlanned = 'icon-minus';
const iconSucc = 'icon-check';
const stateNeutral = 'neutral';
const statePlan = 'planned';
const stateSucc = 'success';

export default class VisitsPath extends LightningElement {

    labels = {
        addLabel,
        saveBTNLabel,
        cancelBTNLabel
    };

    @track patientVisits;
    @track cardItems = [];

    @track selectedPV = {
        Id: null,
        Planned_Date__c: null,
    };
    @track planDate = null;

    pathContainer;
    centredIndex;
    maxScrollValue;
    scrollStep;
    nextScrollLeft;
    nextScrollRight;

    renderedCallback() {
        this.pathContainer = this.template.querySelector('.vis-path');
        let context = this;
        setTimeout(function () {
            if (context.cardItems.length > 0) {
                context.calculateWidth();
                context.doScrollInto();

                window.addEventListener('touchmove', function () {
                    context.changeArrowsStyle();
                });
                window.addEventListener('resize', function () {
                    context.calculateWidth();
                });
            }
        }, 150);
    }

    @wire(getCardVisits)
    wireVisits({data, error}) {
        if (data) {
            this.patientVisits = data;
            this.constructPathItems();
        } else if (error) {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

    constructPathItems() {
        if (this.patientVisits) {
            for (let i = 0; i < this.patientVisits.length; i++) {
                let item = {
                    id: this.patientVisits[i].Id,
                    visitName: this.patientVisits[i].Portal_Name__c,
                    isCompleted: this.patientVisits[i].Status__c === 'Completed'
                };

                if (item.isCompleted) {
                    item.complDate = this.patientVisits[i].Completed_Date__c;
                    item.icon = iconSucc;
                } else {
                    item.planDate = this.patientVisits[i].Planned_Date__c ? this.patientVisits[i].Planned_Date__c : null;
                }

                this.cardItems.push(item);
            }

            this.centredIndex = this.cardItems.length - 1;
            for (let i = this.cardItems.length - 1; i >= 0; i--) {
                let current = this.cardItems[i];
                let state;
                if (i > 0) {
                    let prevIndex = i - 1;
                    let prev = this.cardItems[prevIndex];
                    if (current.isCompleted) {
                        state = stateSucc;
                        current.state = stateClass + state;

                        if (!prev.isCompleted) state = stateNeutral;

                        current.left = lineClass + state;
                        prev.right = lineClass + state;
                    } else if (prev.isCompleted) {
                        if (prevIndex - 1 > 1) {
                            if (!this.cardItems[prevIndex - 1].isCompleted) {
                                state = stateNeutral;
                                current.icon = iconNeutral;
                                current.state = stateClass + state;
                                current.left = lineClass + state;
                                prev.right = lineClass + state;
                            }
                        } else {
                            state = statePlan;
                            this.centredIndex = i;
                            current.icon = iconPlanned;
                            current.state = stateClass + state;
                            current.left = lineClass + state;
                            prev.right = lineClass + state;
                        }
                    } else {
                        state = stateNeutral;
                        current.icon = iconNeutral;
                        current.state = stateClass + state;
                        current.left = lineClass + state;
                        prev.right = lineClass + state;
                    }
                    if (i === this.cardItems.length - 1) current.right = lineClass + state;
                } else {
                    current.icon = current.isCompleted ? iconSucc : iconPlanned;
                    state = current.isCompleted ? stateSucc : statePlan;
                    current.state = stateClass + state;
                    current.left = lineClass + state;
                    if (state === statePlan) this.centredIndex = i;
                }

                this.cardItems[i] = current;
            }
        }
    }

    //Planned Date Logic:-----------------------------------------------------------------------------------------------
    handleOpenDialog(event) {
        let eventItemId = event.currentTarget.dataset.id;

        this.cardItems.forEach(item => {
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

        this.selectedPV.Planned_Date__c = this.planDate;

        let context = this;
        updatePV({visit: JSON.stringify(this.selectedPV)})
            .then(() => {
                let tmpItems = [];
                context.cardItems.forEach(item => {
                    let tmpItem = item;
                    if (item.id === context.selectedPV.Id) tmpItem.planDate = context.planDate;

                    tmpItems.push(tmpItem);
                });
                context.cardItems = tmpItems;

                spinner.hide();
            })
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            });
    }

    //Scroll Arrows handlers:-------------------------------------------------------------------------------------------
    handleScrollLeft() {
        this.pathContainer.scrollLeft -= this.nextScrollLeft;

        let context = this;
        setTimeout(function () {
            context.nextScrollLeft = context.scrollStep;
            if((context.pathContainer.scrollLeft - context.nextScrollLeft) < context.scrollStep) {
                context.nextScrollLeft = context.maxScrollValue;
                context.nextScrollRight = context.scrollStep;
            }
            context.changeArrowsStyle();
        },450);
    }

    handleScrollRight() {
        this.pathContainer.scrollLeft += this.nextScrollRight;

        let context = this;
        setTimeout(function () {
            context.nextScrollRight = context.scrollStep;
            if((context.maxScrollValue - (context.pathContainer.scrollLeft + context.nextScrollRight)) < context.nextScrollRight) {
                context.nextScrollRight = context.maxScrollValue;
                context.nextScrollLeft = context.scrollStep;
            }
            context.changeArrowsStyle();
        },450);
    }

    //Scroll logic:-----------------------------------------------------------------------------------------------------
    calculateWidth() {
        this.maxScrollValue = this.pathContainer.scrollWidth - this.pathContainer.clientWidth;
        this.scrollStep = Math.floor(this.maxScrollValue / (formFactor === 'Small' ? 3 : 2));
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

        if (this.isRightScrollEnd()) arrRight = 0;
        if (this.isLeftScrollEnd()) arrLeft = 0;

        this.template.querySelector('.arrow-left').style.opacity = arrLeft;
        this.template.querySelector('.arrow-right').style.opacity = arrRight;
    }

    doScrollInto() {
        this.pathContainer.scrollLeft = this.maxScrollValue / this.centredIndex;
    }
}