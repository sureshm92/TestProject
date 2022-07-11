import { LightningElement, api } from 'lwc';
import getParticipantData from '@salesforce/apex/HomePageParticipantRemote.getInitData';
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';

import desktopTemplate from './desktopTemplate.html';
import mobileTemplate from './mobileTemplate.html';
import DEVICE from '@salesforce/client/formFactor';

export default class ProgramOverviewDetails extends LightningElement {
    programname;
    participantState;
    clinicaltrailrecrd;
    activeTab = 'overview';
    homeSvg = rr_community_icons + '/' + 'icons.svg' + '#' + 'icon-home-pplite-new';
    ctpAccordionData;

    desktop = true;
    tabContent = true;
    overviewCss = 'po-tab-menu active';
    pcCss = 'po-tab-menu';

    connectedCallback() {
        DEVICE == 'Small' ? (this.desktop = true) : (this.desktop = false);

        let ctpaccordionDatalist = [];
        //code
        getParticipantData()
            .then((result) => {
                if (result) {
                    this.participantState = JSON.parse(result);
                    if (this.participantState.pe) {
                        if (this.participantState.pe.Clinical_Trial_Profile__r) {
                            this.clinicaltrailrecrd = this.participantState.pe.Clinical_Trial_Profile__r;
                            if (this.clinicaltrailrecrd) {
                                if (this.clinicaltrailrecrd.Study_Code_Name__c) {
                                    this.programname =
                                        'About ' + this.clinicaltrailrecrd.Study_Code_Name__c;
                                }
                                if (this.clinicaltrailrecrd.Override_Inclusion_Criteria__c) {
                                    ctpaccordionDatalist.push({
                                        id: 0,
                                        label: 'Inclusion Criteria',
                                        body: this.clinicaltrailrecrd.Override_Inclusion_Criteria__c
                                    });
                                }
                                if (this.clinicaltrailrecrd.Override_Exclusion_Criteria__c) {
                                    ctpaccordionDatalist.push({
                                        id: 1,
                                        label: 'Exclusion Criteria',
                                        body: this.clinicaltrailrecrd.Override_Exclusion_Criteria__c
                                    });
                                }
                                this.ctpAccordionData = ctpaccordionDatalist;
                            }
                        }
                    }
                }
            })
            .catch((error) => {
                console.log('error::' + error);
                this.error = error;
            });
    }

    render() {
        return this.desktop ? desktopTemplate : mobileTemplate;
    }

    handleHomePage() {
        communityService.navigateToPage('');
    }
    // JS functions start
    handleActive(event) {
        this.activeTab = event.target.value;
    }

    get handleDynamicCSS() {
        if (this.activeTab) {
            if (this.activeTab == 'overview') {
                return 'font-size: 50px;';
            } else if (this.activeTab == 'parcrt') {
                return 'font-size: 50px;';
            }
        }
    }

    overViewHandler() {
        this.tabContent = true;
        this.overviewCss = 'po-tab-menu active';
        this.pcCss = 'po-tab-menu';
    }

    participationHandler() {
        this.tabContent = false;
        this.overviewCss = 'po-tab-menu';
        this.pcCss = 'po-tab-menu active';
    }
}
