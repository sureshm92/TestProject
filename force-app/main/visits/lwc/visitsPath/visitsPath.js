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
    scrollValue = 220;
    isPathScrolled = false;

    renderedCallback() {
        let context = this;
        setTimeout(function () {
            if (context.cardItems.length > 0) {
                context.pathContainer = context.template.querySelector('.path');
                context.calculateWidth();

                window.addEventListener('scroll', function () {
                    if (context.isOnScreen(context.pathContainer)) context.doScrollInto();
                });
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
                    visitName: this.patientVisits[i].Visit__r.Patient_Portal_Name__c,
                    isCompleted: this.patientVisits[i].Status__c === 'Completed'
                };

                if (item.isCompleted) {
                    item.complDate = this.patientVisits[i].Completed_Date__c;
                    item.icon = 'icon-check';
                } else {
                    item.planDate = this.patientVisits[i].Planned_Date__c ? this.patientVisits[i].Planned_Date__c : null;
                }

                this.cardItems.push(item);
            }

            this.centredIndex = this.cardItems.length - 1;
            for (let i = this.cardItems.length - 1; i >= 0; i--) {
                let current = this.cardItems[i];
                if (i > 0) {
                    let prev = this.cardItems[i - 1];

                    let state;
                    if (current.isCompleted) {
                        state = 'success';
                        current.state = stateClass + state;
                        current.left = lineClass + 'success';
                        prev.right = lineClass + 'success';
                    } else if (prev.isCompleted) {
                        state = 'planned';
                        this.centredIndex = i;
                        current.icon = 'icon-minus';
                        current.state = stateClass + state;
                        current.left = lineClass + state;
                        prev.right = lineClass + state;
                    } else {
                        state = 'neutral';
                        current.icon = 'icon-none';
                        current.state = stateClass + state;
                        current.left = lineClass + state;
                        prev.right = lineClass + state;
                    }
                    if (i === this.cardItems.length - 1) current.right = lineClass + state;
                } else {
                    current.icon = current.isCompleted ? 'icon-check' : 'icon-minus';
                    let state = current.isCompleted ? 'success' : 'planned';
                    current.state = stateClass + state;
                    current.left = lineClass + state;
                }

                this.cardItems[i] = current;
            }
        }
    }

    //Event Handlers:---------------------------------------------------------------------------------------------------
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
        if (this.pathContainer) {
            this.pathContainer.scrollLeft -= this.scrollValue;
            this.changeArrowsStyle();
        }
    }

    handleScrollRight() {
        if (this.pathContainer) {
            this.pathContainer.scrollLeft += this.scrollValue;
            this.changeArrowsStyle();
        }
    }

    //Scroll logic:-----------------------------------------------------------------------------------------------------
    calculateWidth() {
        this.scrollValue = Math.round(this.pathContainer.scrollWidth - this.pathContainer.clientWidth);
        if (formFactor === 'Small') this.scrollValue = this.scrollValue / 3;

        if (this.pathContainer.scrollWidth > this.pathContainer.clientWidth) this.changeArrowsStyle();
    }

    isLeftScrollEnd() {
        return this.pathContainer.scrollLeft === 0;
    }

    isRightScrollEnd() {
        if (this.pathContainer) {
            let maxScrollValue = this.pathContainer.scrollWidth - this.pathContainer.clientWidth;
            return (maxScrollValue <= (Math.round(this.pathContainer.scrollLeft)));
        }
        return false;
    }

    changeArrowsStyle() {
        if (this.isRightScrollEnd()) {
            this.template.querySelector('.arrow-right').style.opacity = 0;
            this.template.querySelector('.arrow-left').style.opacity = 1;
        } else if (this.isLeftScrollEnd()) {
            this.template.querySelector('.arrow-left').style.opacity = 0;
            this.template.querySelector('.arrow-right').style.opacity = 1;
        }
    }

    isOnScreen(pathContainer) {
        let scroll = window.scrollY || window.pageYOffset;
        let boundsTop = pathContainer.getBoundingClientRect().top + scroll;

        let viewport = {
            top: scroll,
            bottom: scroll + window.innerHeight,
        };

        let bounds = {
            top: boundsTop,
            bottom: boundsTop + pathContainer.clientHeight,
        };

        return (bounds.bottom >= viewport.top && bounds.bottom <= viewport.bottom)
            || (bounds.top <= viewport.bottom && bounds.top >= viewport.top);
    }

    doScrollInto() {
        if (this.centredIndex && this.cardItems) {
            this.template.querySelectorAll('.state-ico-wrapper')[this.centredIndex].scrollIntoView({
                behavior: 'smooth',
                block: 'center'
            });

            this.isPathScrolled = true;
        }
    }
}