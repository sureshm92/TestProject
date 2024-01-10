import { LightningElement, api } from 'lwc';
import getParticipantData from '@salesforce/apex/HomePageParticipantRemote.getInitData';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import contact_support_icons from '@salesforce/resourceUrl/contact_support_icons';

import desktopTemplate from './desktopTemplate.html';
import mobileTemplate from './mobileTemplate.html';
import DEVICE from '@salesforce/client/formFactor';
// importing Custom Label
import PPOVERVIEW from '@salesforce/label/c.PP_Overview';
import PPOBJECTIVE from '@salesforce/label/c.PP_Objective';
import PPPROGRAMOVERVIEW from '@salesforce/label/c.PP_Program_Overview';
import PPPARTICIPATIONCRITERIA from '@salesforce/label/c.PP_Participation_Criteria';
import PPELIGIBLECRITERIA from '@salesforce/label/c.PP_Participant_Eligible_Criteria';
import PPINCLUSIONCRITERIA from '@salesforce/label/c.PP_Inclusion_Criteria';
import PPEXCLUSIONCRITERIA from '@salesforce/label/c.PP_Exclusion_Criteria';
import PI_Post_Fix from '@salesforce/label/c.PP_PI_Post_Fix';
import NOT_AVAILABLE from '@salesforce/label/c.Not_Available';

export default class ProgramOverviewDetails extends LightningElement {
    label = {
        PPOVERVIEW,
        PPOBJECTIVE,
        PPPROGRAMOVERVIEW,
        PPPARTICIPATIONCRITERIA,
        PPELIGIBLECRITERIA,
        PPINCLUSIONCRITERIA,
        PPEXCLUSIONCRITERIA,
        PI_Post_Fix,
        NOT_AVAILABLE
    };

    programname;
    participantState;
    clinicaltrailrecrd;
    activeTab = 'overview';
    homeSvg = rr_community_icons + '/' + 'icons.svg' + '#' + 'icon-home-pplite-new';
    ctpAccordionData;
    phone_Icon = contact_support_icons+'/phone_Icon.svg';
    pi_Icon = contact_support_icons+'/PI_icon.svg';
    address_Icon = contact_support_icons+'/pin_Icon.svg';

    piName;
    studySitePhone;
    siteName;
    siteAddress;
    phoneNotAvailable;

    desktop = true;
    tabContent = true;
    overviewCss = 'po-tab-menu active';
    pcCss = 'po-tab-menu pt';

    isRTL = false;
    showSpinner = true;

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    get breadCrum() {
        return '';
    }

    get programName() {
        return this.isRTL ? 'po-mr-36' : '';
    }

    get breadCrumMobile() {
        return this.isRTL ? 'po-mt-20 po-mr-10' : 'po-mt-20';
    }

    get programNameMobile() {
        return this.isRTL ? 'po-mr-26' : '';
    }

    get parCriterionMRight() {
        return this.isRTL ? 'po-pb-10 po-mr-16plus' : 'po-pb-10 po-ml-3';
    }

    get parCriterionMRightDesktop() {
        return this.isRTL ? 'po-pb-10 po-mr-16' : 'po-pb-10 po-ml-3';
    }

    get accordianMargin() {
        return this.isRTL ? 'po-mr-16' : 'po-mr-20minus';
    }

    get accordianMarginDesktop() {
        return this.isRTL ? 'po-mr-16plus' : '';
    }

    connectedCallback() {
        DEVICE == 'Large' ? (this.desktop = true) : (this.desktop = false);

        let ctpaccordionDatalist = [];
        //code
        getParticipantData()
            .then((result) => {
                if (result) {
                    this.participantState = JSON.parse(result);
                    if (this.participantState.pe) {
                        if (this.participantState.pe.Clinical_Trial_Profile__r) {
                            this.clinicaltrailrecrd =
                                this.participantState.pe.Clinical_Trial_Profile__r;
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
                                } else {
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
                                } else {
                                    ctpaccordionDatalist.push({
                                        id: 1,
                                        label: this.label.PPEXCLUSIONCRITERIA,
                                        body: ''
                                    });
                                }
                                this.ctpAccordionData = ctpaccordionDatalist;
                            }
                        }
                        this.showSpinner = false;
                        if(this.participantState.pe.Study_Site__r){
                            this.piName = this.participantState.pe.Study_Site__r.Principal_Investigator__r.Name;
                            console.log('piName--->'+this.piName);
                            this.studySitePhone = this.participantState.pe.Study_Site__r.Study_Site_Phone__c;
                            this.phoneNotAvailable = this.participantState.pe.Study_Site__r
                                .Study_Site_Phone__c
                                ? false
                                : true;
                            console.log('studySitePhone--->'+this.studySitePhone);
                            this.siteName = this.participantState.pe.Study_Site__r.Site__r.Name;
                            console.log('siteName--->'+this.siteName);
                            this.siteAddress = this.participantState.pe.Study_Site__r.Site__r.BillingStreet + 
                                            ', ' + this.participantState.pe.Study_Site__r.Site__r.BillingCity +
                                            ', ' + this.participantState.pe.Study_Site__r.Site__r.BillingState +
                                            ', ' + this.participantState.pe.Study_Site__r.Site__r.BillingCountryCode +
                                            ' ' + this.participantState.pe.Study_Site__r.Site__r.BillingPostalCode;
                            console.log('siteAddress--->'+this.siteAddress);
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