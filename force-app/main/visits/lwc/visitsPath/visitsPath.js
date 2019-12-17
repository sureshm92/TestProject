/**
 * Created by Igor Malyuta on 06.12.2019.
 */

import {LightningElement, track, wire} from 'lwc';
import formFactor from '@salesforce/client/formFactor';

import addLabel from '@salesforce/label/c.Add_Date';
import saveBTNLabel from '@salesforce/label/c.BTN_Save';
import cancelBTNLabel from '@salesforce/label/c.BTN_Cancel';
import selDate from '@salesforce/label/c.Select_Planned_Date';
import planDate from '@salesforce/label/c.Planned_Date';

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
        cancelBTNLabel,
        selDate,
        planDate
    };

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

    renderedCallback() {
        this.spinner = this.template.querySelector('c-web-spinner');

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
        if(this.pathContainer) {
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
    }

    @wire(getCardVisits)
    wireVisits({data, error}) {
        if (data) {
            this.patientVisits = data;
            this.isVisitsEmpty = data.length === 0;
            this.constructPathItems();

            if(this.spinner) this.spinner.hide();
        } else if (error) {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

    constructPathItems() {
        if (this.patientVisits) {
            for (let i = 0; i < this.patientVisits.length; i++) {
                let visitName =
                    this.patientVisits[i].Portal_Name__c ? this.patientVisits[i].Portal_Name__c : this.patientVisits[i].Name;
                let item = {
                    id: this.patientVisits[i].Id,
                    visitName: visitName,
                    isCompleted: this.patientVisits[i].Status__c === 'Completed'
                };

                if (item.isCompleted) {
                    item.complDate = this.patientVisits[i].Completed_Date__c;
                    item.icon = iconSucc;
                } else {
                    item.planDate = this.patientVisits[i].Planned_Date__c ? this.patientVisits[i].Planned_Date__c : null;
                }

                this.pathItems.push(item);
            }

            this.centredIndex = this.pathItems.length - 1;
            for (let i = this.pathItems.length - 1; i >= 0; i--) {
                let current = this.pathItems[i];
                let state;
                if (i > 0) {
                    let prevIndex = i - 1;
                    let prev = this.pathItems[prevIndex];
                    if (current.isCompleted) {
                        state = stateSucc;
                        current.state = stateClass + state;

                        if (!prev.isCompleted) state = stateNeutral;

                        current.left = lineClass + state;
                        prev.right = lineClass + state;
                    } else if (prev.isCompleted) {
                        if (prevIndex - 1 > 1) {
                            if (!this.pathItems[prevIndex - 1].isCompleted) {
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
                    if (i === this.pathItems.length - 1) current.right = lineClass + state;
                } else {
                    current.icon = current.isCompleted ? iconSucc : iconPlanned;
                    state = current.isCompleted ? stateSucc : statePlan;
                    current.state = stateClass + state;
                    current.left = lineClass + state;
                    if (state === statePlan) this.centredIndex = i;
                }

                this.pathItems[i] = current;
            }
            this.centredIndex++;
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

        this.selectedPV.Planned_Date__c = this.planDate;

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
            if ((context.pathContainer.scrollLeft - context.nextScrollLeft) < (context.scrollStep / 2)) {
                context.nextScrollLeft = context.maxScrollValue;
            }
            context.changeArrowsStyle();
        }, 450);
    }

    handleScrollRight() {
        if (this.fromLeftCorner) {
            this.doScrollInto(2);
            this.nextScrollLeft = this.scrollStep;
            this.fromLeftCorner = false;
        } else {
            this.pathContainer.scrollLeft += this.nextScrollRight;
        }

        let context = this;
        setTimeout(function () {
            context.nextScrollRight = context.scrollStep;
            if ((context.maxScrollValue - (context.pathContainer.scrollLeft + context.nextScrollRight)) < (context.scrollStep / 2)) {
                context.nextScrollRight = context.maxScrollValue;
            }
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
            arrRight = 0;
            this.fromRightCorner = true;
        }
        if (this.isLeftScrollEnd()) {
            arrLeft = 0;
            this.fromLeftCorner = true;
        }

        this.template.querySelector('.arrow-left').style.opacity = arrLeft;
        this.template.querySelector('.arrow-right').style.opacity = arrRight;
    }

    doScrollInto(index) {
        this.pathContainer.scrollLeft = (index * this.elementWidth) - (this.elementWidth / 2) - (this.pathContainer.clientWidth / 2);
    }
}