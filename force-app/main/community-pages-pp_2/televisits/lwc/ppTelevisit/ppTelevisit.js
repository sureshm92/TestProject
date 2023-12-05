import { LightningElement, track, api } from 'lwc';
import past from '@salesforce/label/c.Visits_Past';
import upcoming from '@salesforce/label/c.Visits_Upcoming';
import Televisits from '@salesforce/label/c.Televisits';
import No_upcoming_televisits from '@salesforce/label/c.No_upcoming_televisits';
import No_past_televisits from '@salesforce/label/c.No_past_televisits';
import getParticipantDetails from '@salesforce/apex/ParticipantTelevisitRemote.getParticipantTelevisits';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import { NavigationMixin } from 'lightning/navigation';
import DEVICE from '@salesforce/client/formFactor';
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import removeCancelledUpdateNotifications from '@salesforce/apex/PPUpdatesController.removeCancelledUpdateNotifications';
import removeScheduledAndRescheduledUpdateNotifications from '@salesforce/apex/PPUpdatesController.removeScheduledAndRescheduledUpdateNotifications';
import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';

export default class PpTelevisit extends NavigationMixin(LightningElement) {
    @track contentLoaded = false;
    @track upcomingTelevisitslist = [];
    @track pastTelevisitlist = [];
    empty_state = pp_community_icons + '/' + 'empty_visits.png';
    homeSvg = rr_community_icons + '/' + 'icons.svg' + '#' + 'icon-home-pplite-new';
    showupcomingtelevisits = false;
    showuppasttelevisits = false;
    showblankupcomingtelevisits = false;
    showblankpasttelsvisits = false;
    isMobile = false;
    label = {
        past,
        upcoming,
        Televisits,
        No_upcoming_televisits,
        No_past_televisits,
        removeCancelledUpdateNotifications
    };
    past = false;
    timechanges;
    reloadupcomingcomponent = false;
    isdelegate = false;
    alreadyCalledRemovalNotif = false;
    @api isRTL = false;

    get upButtonStyle() {
        if(past){
            return this.isRTL ? 'slds-button slds-button_brand up-button active-button-background border-radius' : 'slds-button slds-button_brand up-button active-button-background border-radius-rtl';
        }else{
            return this.isRTL ? 'slds-button slds-button_neutral up-button inactive-button-background border-radius' : 'slds-button slds-button_neutral up-button inactive-button-background border-radius-rtl';
        }
    }

    get pastButtonStyle() {
        if(!past){
            return this.isRTL ? 'slds-button slds-button_brand past-button active-button-background border-radius-rtl' : 'slds-button slds-button_brand past-button active-button-background border-radius';
        }else{
            return this.isRTL ? 'slds-button slds-button_neutral past-button inactive-button-background border-radius-rtl' : 'slds-button slds-button_neutral past-button inactive-button-background border-radius';
        }
    }

    selectedNavHandler(event) {
        if (event.detail.filter == 'showblankupcomingtelevisits:false') {
            this.upcomingTelevisitslist = event.detail.upcomingdata;
            this.pastTelevisitlist = event.detail.details;
            this.showblankupcomingtelevisits = false;
        }
        if (event.detail.filter == 'showblankupcomingtelevisits:true') {
            this.showblankupcomingtelevisits = true;
            this.pastTelevisitlist = event.detail.details;
            this.upcomingTelevisitslist = event.detail.upcomingdata;
            this.showblankpasttelsvisits = false;
            if (this.past) {
                this.showuppasttelevisits = true;
            }
        }
        if (event.detail.filter == 'datachange') {
            this.pastTelevisitlist = event.detail.details;
            this.upcomingTelevisitslist = event.detail.upcomingdata;
            this.showblankpasttelsvisits = false;
            if (this.past) {
                this.showuppasttelevisits = true;
            }
        }
    }
    onPastClick() {
        this.reloadupcomingcomponent = false;
        this.past = true;
        this.showupcomingtelevisits = false;
        if (!this.showblankpasttelsvisits) {
            this.showuppasttelevisits = true;
            this.removeCancelledUpdateNotifications();
        }
    }
    onUpcomingClick() {
        this.past = false;
        this.reloadupcomingcomponent = true;
        this.showuppasttelevisits = false;
        if (!this.showblankupcomingtelevisits) {
            this.showupcomingtelevisits = true;
            if (!this.alreadyCalledRemovalNotif) {
                this.alreadyCalledRemovalNotif = true;
                this.removeScheduledAndRescheduledUpdateNotifications();
            }
        }
    }

    removeCancelledUpdateNotifications() {
        let participantContactId = communityService.getParticipantData().participant.Contact__c;
        let partEnrollemntId = communityService.getParticipantData()?.pe?.Id;
        let currentParticipant = communityService.getParticipantData().participant.Id;
        removeCancelledUpdateNotifications({
            contactId: participantContactId,
            peId: partEnrollemntId,
            participantId: currentParticipant
        })
            .then((result) => {})
            .catch((error) => {
                this.showToast('', error.message, 'error');
            });
    }

    removeScheduledAndRescheduledUpdateNotifications() {
        let participantContactId = communityService.getParticipantData().participant.Contact__c;
        let partEnrollemntId = communityService.getParticipantData()?.pe?.Id;
        let currentParticipant = communityService.getParticipantData().participant.Id;
        removeScheduledAndRescheduledUpdateNotifications({
            contactId: participantContactId,
            peId: partEnrollemntId,
            participantId: currentParticipant
        })
            .then((result) => {})
            .catch((error) => {
                this.showToast('', error.message, 'error');
            });
    }

    gettelevisitdetails(isPast) {
        getParticipantDetails({ joinbuttonids: null })
            .then((result) => {
                if (
                    result != undefined &&
                    result != '' &&
                    (result.televisitupcomingList.length > 0 || result.televisitpastList.length > 0)
                ) {
                    this.timechanges = result.tz;
                    this.pastTelevisitlist = result.televisitpastList;
                    this.upcomingTelevisitslist = result.televisitupcomingList;
                    if (this.pastTelevisitlist.length == 0) {
                        this.showblankpasttelsvisits = true;
                    }
                    if (this.upcomingTelevisitslist.length == 0) {
                        this.showblankupcomingtelevisits = true;
                    }
                    if (result.showDefault == 'upcoming' && isPast != true) {
                        this.past = false;
                        this.showupcomingtelevisits = true;
                        this.alreadyCalledRemovalNotif = true;
                        this.removeScheduledAndRescheduledUpdateNotifications();
                    } else {
                        this.past = true;
                        this.showuppasttelevisits = true;
                    }
                } else {
                    this.showblankupcomingtelevisits = true;
                    this.showblankpasttelsvisits = true;
                }
                this.isdelegate = result.isdelegate;
                this.contentLoaded = true;
                this.reloadupcomingcomponent = true;
                this.template.querySelector('c-web-spinner').hide();
            })
            .catch((error) => {
                this.template.querySelector('c-web-spinner').hide();
                this.contentLoaded = true;
            });
    }
    connectedCallback() {
        DEVICE != 'Small' ? (this.isMobile = false) : (this.isMobile = true);
        if (communityService.getUrlParameter('ispast') === 'true') {
            this.gettelevisitdetails(true);
        } else {
            this.gettelevisitdetails();
        }
        getisRTL()
            .then((data) => {
                this.isRTL = data;
                console.log('rtl--->'+this.isRTL);
            })
            .catch(function (error) {
                console.error('Error RTL: ' + JSON.stringify(error));
        });
    }
    redircttohomepage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    showToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: '',
                variant: variantType
            })
        );
    }
}