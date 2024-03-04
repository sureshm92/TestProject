import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import DEVICE from '@salesforce/client/formFactor';
import IQVIA_Logo from '@salesforce/resourceUrl/IQVIA_Logo';
import GSK_Logo from '@salesforce/resourceUrl/GSK_Logos';
import openNewTabBlueIcon from '@salesforce/resourceUrl/openNewTabBlueIcon';
import contact_support_icons from '@salesforce/resourceUrl/contact_support_icons';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
import PPLEARNMOREDESKTOPLabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Desktop';
import PPLEARNMOREMBLELabel from '@salesforce/label/c.PP_StudyOverview_LearnMore_Mobile';
import PP_StudyOverview_homePage_shortDecs_DelAlu from '@salesforce/label/c.PP_StudyOverview_homePage_shortDecs_DelAlu';
import PP_Clinical_Research_by_IQVIA from '@salesforce/label/c.PP_Clinical_Research_by_IQVIA';
import PI_Post_Fix from '@salesforce/label/c.PP_PI_Post_Fix';

export default class StudyOverview extends NavigationMixin(LightningElement) {
    label = {
        PPLEARNMOREDESKTOPLabel,
        PPLEARNMOREMBLELabel,
        PP_StudyOverview_homePage_shortDecs_DelAlu,
        PP_Clinical_Research_by_IQVIA,
        PI_Post_Fix
    };

    iqviaLogoUrl = IQVIA_Logo + '/IQVIALogo.png';
    gskLogoUrl = GSK_Logo + '/gsk-full.png';
    open_new_tab = openNewTabBlueIcon;
    phone_Icon = contact_support_icons + '/phone_Icon.svg';
    pi_Icon = contact_support_icons + '/PI_icon.svg';

    @api clinicalrecord;
    shortOverview;
    @api studysite;
    piName;
    piTitle;
    studySitePhone;

    desktop = true;
    isRTL = false;

    alumniParticipant = false;
    delegateSelfView = false;
    communityName;
    userMode;

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }
    get borderPOHome() {
        return this.isRTL ? 'borderLeft' : 'borderRight';
    }
    get paddingPIPhoneAndName() {
        return this.isRTL ? 'pad-Rtl' : 'pad-5';
    }
    get noStudyOverviewAvailable() {
        return this.alumniParticipant || this.delegateSelfView ? true : false;
    }
    get isIqviaLogo() {
        return this.communityName == 'IQVIA Referral Hub' ||
            this.communityName == 'IQVIA Patient Portal'
            ? true
            : false;
    }

    get isGskLogo() {
        return this.communityName == 'GSK Community' ? true : false;
    }


    get piUserIcon(){
        return this.isRTL ? 'piIcon-Rtl' : 'piIcon-NonRtl';
    }

    connectedCallback() {
        DEVICE == 'Large' ? (this.desktop = true) : (this.desktop = false);

        if (this.clinicalrecord) {
            if (this.clinicalrecord.Brief_Summary__c) {
                let briefsummary = this.clinicalrecord.Brief_Summary__c;
                briefsummary = briefsummary.replace(/<[^>]*>?/gm, '');
                if (briefsummary.length > 200) {
                    let firsttext = briefsummary.substring(0, 200);
                    let secondtext = briefsummary.substring(200, 201);
                    if (secondtext == ' ') {
                        this.shortOverview = firsttext;
                    } else {
                        let result = firsttext.substring(
                            0,
                            Math.min(firsttext.length, firsttext.lastIndexOf(' '))
                        );
                        this.shortOverview = result + '...';
                    }
                } else {
                    this.shortOverview = briefsummary;
                }
            }
        }

        if (this.studysite) {
            this.piName = this.studysite.Principal_Investigator__r.Name;
            this.studySitePhone = this.studysite.Study_Site_Phone__c;
            this.piTitle = this.piName + ' ' + this.label.PI_Post_Fix;
        }

        getisRTL()
            .then((data) => {
                this.isRTL = data;
            })
            .catch(function (error) {
                console.error('Error RTL: ' + JSON.stringify(error));
            });

        this.userMode = communityService.getUserMode();

        // check who has logged in if delegate or alumni show no active programs UI
        let participantData = communityService.getParticipantData();
        this.communityName = participantData.communityName;
        this.delegateSelfView =
            participantData.value == 'ALUMNI' && participantData.hasPatientDelegates ? true : false;

        this.alumniParticipant =
            participantData.value == 'ALUMNI' && !participantData.hasPatientDelegates
                ? true
                : false;
    }

    handleclick() {
        communityService.navigateToPage('about-study-and-overview');
    }

    handleclickClinicalResearch() {
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: 'http://ClinicalResearch.com'
            }
        };
        this[NavigationMixin.Navigate](config);
    }
}