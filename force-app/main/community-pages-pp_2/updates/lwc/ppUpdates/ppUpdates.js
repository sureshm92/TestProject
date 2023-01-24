import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInitDataNew from '@salesforce/apex/RelevantLinksRemote.getInitDataNew';
import getUpdateResources from '@salesforce/apex/ResourceRemote.getUpdateResources';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import DEVICE from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import updatesLabel from '@salesforce/label/c.Updates_Label';
import viewAllResource from '@salesforce/label/c.View_All_Resource';
import caughtup from '@salesforce/label/c.Caught_up';
export default class PpUpdates extends NavigationMixin(LightningElement) {
    @api desktop;
    @api showvisitsection;
    linksWrappers = [];
    resourcedData = [];
    resourcePresent = false;
    desktop = true;
    isInitialized = false;
    counter;
    displayCounter = false;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'empty_updates.PNG';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    isRendered = false;
    label = {
        updatesLabel,
        viewAllResource,
        caughtup
    };

    renderedCallback() {
        if (!this.isRendered) {
            this.isRendered = true;
            this.initializeData();
        }
    }

    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        getInitDataNew()
            .then((returnValue) => {
                this.isInitialized = true;
                let initData = JSON.parse(JSON.stringify(returnValue));
                let therapeuticAssignmentsList = [];
                let therapeuticAssignments = {
                    resource: '',
                    id: '',
                    therapeuticArea: ''
                };

                initData.resources.forEach((resObj) => {
                    resObj.resource.Therapeutic_Area_Assignments__r?.forEach((therapeuticArea) => {
                        therapeuticAssignments.resource = therapeuticArea.Resource__c;
                        therapeuticAssignments.id = therapeuticArea.Id;
                        therapeuticAssignments.therapeuticArea =
                            therapeuticArea.Therapeutic_Area__c;
                        therapeuticAssignmentsList.push(therapeuticAssignments);
                    });

                    resObj.therapeuticAssignments = therapeuticAssignmentsList;
                    therapeuticAssignmentsList = [];
                    delete resObj.resource.Therapeutic_Area_Assignments__r;
                });
                this.getUpdates(JSON.stringify(initData));
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                this.spinner.hide();
            });
    }

    openLink(event) {
        window.open(event.currentTarget.dataset.link, '_blank');
    }

    async getUpdates(returnValue) {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner ? this.spinner.show() : '';
        let state;
        if (communityService.isInitialized()) {
            state = communityService.getCurrentCommunityMode().participantState;
            this.pData = communityService.getParticipantData();
            let data = JSON.stringify(this.pData);

            await getUpdateResources({ linkWrapperText: returnValue, participantData: data })
                .then((result) => {
                    var counterForLoop = 0;
                    let data = JSON.parse(JSON.stringify(result));
                    this.counter = data.counter;
                    if (this.counter > 0 && state != 'ALUMNI') {
                        this.displayCounter = true;
                        const counterUpdateEvent = new CustomEvent('counterupdate', {
                            detail: {
                                counter: this.counter,
                                displayCounter: this.displayCounter
                            }
                        });
                        this.dispatchEvent(counterUpdateEvent);
                    }
                    data.resources.every((resObj) => {
                        ++counterForLoop;
                        this.resourcedData.push(resObj);
                        if (counterForLoop >= 4) {
                            return false;
                        }
                        return true;
                    });
                    if (counterForLoop > 0) {
                        this.resourcePresent = true;
                    }
                    this.resourcedData.forEach((resObj) => {
                        if (
                            resObj.resource.Content_Type__c == 'Article' ||
                            resObj.resource.Content_Type__c == 'Video'
                        ) {
                            resObj.isExplore = true;
                        } else if (resObj.resource.Content_Type__c == 'Study_Document') {
                            resObj.isDoc = true;
                        } else if (resObj.resource.Content_Type__c == 'Multimedia') {
                            resObj.isMultimedia = true;
                        } else {
                            resObj.isLink = true;
                        }
                    });
                    this.spinner.hide();
                })
                .catch((error) => {
                    this.showErrorToast('Error occured', error.message, 'error');
                });
        }
    }

    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }

    navigateResources() {
        let subDomain = communityService.getSubDomain();
        let detailLink = window.location.origin + subDomain + '/s/resources';

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            sessionStorage.setItem('Cookies', 'Accepted');
            window.open(url, '_self');
        });
    }
}
