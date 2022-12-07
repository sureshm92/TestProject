import { LightningElement, api } from 'lwc';
import getParticipantData from '@salesforce/apex/HomePageParticipantRemote.getInitData';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';

import desktopTemplate from './desktopTemplate.html';
import mobileTemplate from './mobileTemplate.html';
import DEVICE from '@salesforce/client/formFactor';
// importing Custom Label
import PPOVERVIEW from '@salesforce/label/c.PP_Overview';
import PPOBJECTIVE from '@salesforce/label/c.PP_Objective';
import PPSTUDYOVERVIEW from '@salesforce/label/c.PP_Study_Overview';
import PPPARTICIPATIONCRITERIA from '@salesforce/label/c.PP_Participation_Criteria';
import PPSTUDYELIGIBLECRITERIA from '@salesforce/label/c.PP_Participant_Study_Eligible_Criteria';
import PPINCLUSIONCRITERIA from '@salesforce/label/c.PP_Inclusion_Criteria';
import PPEXCLUSIONCRITERIA from '@salesforce/label/c.PP_Exclusion_Criteria';


export default class ProgramOverviewDetails extends LightningElement {
    label = {
        PPOVERVIEW,
        PPOBJECTIVE,
        PPSTUDYOVERVIEW,
        PPPARTICIPATIONCRITERIA,
        PPSTUDYELIGIBLECRITERIA,
        PPINCLUSIONCRITERIA,
        PPEXCLUSIONCRITERIA
    };
    
    programname;
    participantState;
    clinicaltrailrecrd;
    activeTab = 'overview';
    homeSvg = rr_community_icons + '/' + 'icons.svg' + '#' + 'icon-home-pplite-new';
    ctpAccordionData;

    desktop = true;
    tabContent = true;
    overviewCss = 'po-tab-menu active';
    pcCss = 'po-tab-menu pt';

    isRTL = false;

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    get breadCrum(){
        return this.isRTL ? 'po-mt-20 po-mr-25' : 'po-mt-20';
    }

    get programName(){
        return this.isRTL ? 'po-mr-36' : '';
    }

    get breadCrumMobile(){
        return this.isRTL ? 'po-mt-20 po-mr-10' : 'po-mt-20';
    }

    get programNameMobile(){
        return this.isRTL ? 'po-mr-26' : '';
    }

    get parCriterionMRight(){
        return this.isRTL ? 'po-pb-10 po-mr-16plus' : 'po-pb-10 po-ml-3 po-mr-6';
    }

    get parCriterionMRightDesktop(){
        return this.isRTL ? 'po-pb-10 po-mr-16' : 'po-pb-10 po-ml-3 po-mr-6';
    }

    get accordianMargin(){
        return this.isRTL ? 'po-mr-16' : 'po-mr-20minus';
    }

    get accordianMarginDesktop(){
        return this.isRTL ? 'po-mr-16plus' : '';
    }

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);

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
                                        label: this.label.PPINCLUSIONCRITERIA,
                                        body: this.clinicaltrailrecrd.Override_Inclusion_Criteria__c
                                    });
                                }
                                else{
                                    ctpaccordionDatalist.push({
                                        id: 0,
                                        label: this.label.PPINCLUSIONCRITERIA,
                                        body: ''
                                    });
                                }
                                if (this.clinicaltrailrecrd.Override_Exclusion_Criteria__c) {
                                    ctpaccordionDatalist.push({
                                        id: 1,
                                        label: this.label.PPEXCLUSIONCRITERIA,
                                        body: this.clinicaltrailrecrd.Override_Exclusion_Criteria__c
                                    });
                                }
                                else{
                                    ctpaccordionDatalist.push({
                                        id: 1,
                                        label: this.label.PPEXCLUSIONCRITERIA,
                                        body: ''
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

            getisRTL()
                .then((data) => {
                    this.isRTL = data;
                })
                .catch(function (error) {
                    console.error('Error RTL: ' + JSON.stringify(error));
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
        this.pcCss = 'po-tab-menu pt';
    }

    participationHandler() {
        this.tabContent = false;
        this.overviewCss = 'po-tab-menu';
        this.pcCss = 'po-tab-menu pt active';
    }
}