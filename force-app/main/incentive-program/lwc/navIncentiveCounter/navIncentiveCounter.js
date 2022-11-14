/**
 * Created by Andrii Kryvolap.
 */

import { LightningElement, track, api } from 'lwc';
import getPoints from '@salesforce/apex/IncentiveProgramRemote.getCurrentPoints';
import getisRTL from '@salesforce/apex/ParticipantVisitsRemote.getIsRTL';

export default class NavIncentiveCounter extends LightningElement {
    @track totalPoints = null;
    @track lastPoints = null;
    @track isRTL = null;
    @track parOfIncentiveProgram = false;
    @track showDropDown;
    _currentPage;
    @api
    set currentPage(pageName) {
        this._currentPage = pageName;
        this.updateSelected();
    }
    get currentPage() {
        return this._currentPage;
    }

    lastDatastamp;

    connectedCallback() {
        this.showDropDown = false;
        this.lastDatastamp = new Date();
        getisRTL()
        .then((data) => {
            this.isRTL = data;
        })
        .catch(function(error) {
            console.error('Error: ' + JSON.stringify(error));
        });
        let fetchPoints = () => {
            getPoints({
                timeStamp: this.lastDatastamp.toISOString()
            })
                .then((data) => {
                    this.totalPoints = data.totalPoints;
                    this.lastPoints = data.lastPoints;
                    this.parOfIncentiveProgram = this.totalPoints > 0 || data.hasEnabledTasks;
                    this.updateSelected();
                    const notifyIsPartOfIncentiveProgram = new CustomEvent('notifypartofincentive', {
                        detail: {
                            parOfIncentiveProgram: this.parOfIncentiveProgram
                        }
                    });
                   
                    this.dispatchEvent(notifyIsPartOfIncentiveProgram);
                })
                .catch((error) => {
                    console.error('Error in getPointsCounter():' + JSON.stringify(error));
                });
        };
        fetchPoints();
        setInterval(fetchPoints, 5000);
    }

    doToggleDropDown() {
        if (this.showDropDown) {
            this.lastDatastamp = new Date();
        }
        this.showDropDown = !this.showDropDown;
        this.updateSelected();
    }
    doCloseDropDown() {
        this.showDropDown = false;
        this.lastDatastamp = new Date();
        this.updateSelected();
    }
    doEvent() {
        this.doCloseDropDown();
        const navigateToIncentivesEvent = new CustomEvent('navigatetoincentives', {
            detail: {
                page: 'incentives'
            }
        });
        this.dispatchEvent(navigateToIncentivesEvent);
    }

    updateSelected() {
        if (this.parOfIncentiveProgram) {
            if (this._currentPage == 'incentives') {
                this.template.querySelector('.nic-button').classList.add('current-page');
            } else {
                if (this.showDropDown) {
                    this.template.querySelector('.nic-button').classList.add('current-page');
                } else {
                    this.template.querySelector('.nic-button').classList.remove('current-page');
                }
            }
        }
        
    }
}