import { LightningElement, api } from 'lwc';
import DEVICE from '@salesforce/client/formFactor';
import IQVIA_Logo from '@salesforce/resourceUrl/IQVIA_Logo';
import GSK_Logo from '@salesforce/resourceUrl/GSK_Logos';
import contact_support_icons from '@salesforce/resourceUrl/contact_support_icons';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
// importing Custom Label
import PPLEARNMOREMBLELabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Mobile';
import PPLEARNMOREDESKTOPLabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Desktop';
import When_a_program_is_active_you_will_find_a_brief_overview_about_it_here from '@salesforce/label/c.When_a_program_is_active_you_will_find_a_brief_overview_about_it_here';
import You_are_not_enrolled_in_any_program_at_the_moment from '@salesforce/label/c.You_are_not_enrolled_in_any_program_at_the_moment';
import No_active_program from '@salesforce/label/c.No_active_program';
import PI_Post_Fix from '@salesforce/label/c.PP_PI_Post_Fix';

export default class ProgramOverview extends LightningElement {
    label = {
        PPLEARNMOREMBLELabel,
        PPLEARNMOREDESKTOPLabel,
        When_a_program_is_active_you_will_find_a_brief_overview_about_it_here,
        You_are_not_enrolled_in_any_program_at_the_moment,
        No_active_program,
        PI_Post_Fix
    };

    iqviaLogoUrl = IQVIA_Logo + '/IQVIALogo.png';
    gskLogoUrl = GSK_Logo + '/gsk-full.png';
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
    get noProgramOverviewAvailable() {
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
        this.alumniParticipant =
            participantData.value == 'ALUMNI' && !participantData.hasPatientDelegates
                ? true
                : false;
        this.delegateSelfView =
            participantData.value == 'ALUMNI' && participantData.hasPatientDelegates ? true : false;
        this.communityName = participantData.communityName;
    }

    handleclick() {
        communityService.navigateToPage('overview');
    }
}