import { LightningElement, api, track } from 'lwc';
import getStudyStaff from '@salesforce/apex/HomePageParticipantRemote.getStudyStaff';
import getPIDetails from '@salesforce/apex/HomePageParticipantRemote.getPIDetails';
import contact_support_icons from '@salesforce/resourceUrl/contact_support_icons';
import DEVICE from '@salesforce/client/formFactor';
import Contact_Support from '@salesforce/label/c.PP_Contact_Support';
import Studies_Program from '@salesforce/label/c.PP_Studies_Program';
import For_Question_Abt_Participant from '@salesforce/label/c.PP_For_Question_Abt_Participant';
import Phone_In_Caps from '@salesforce/label/c.PP_Phone_In_Caps';
import Site_And_Location_Caps from '@salesforce/label/c.PP_Site_And_Location_Caps';
import Care_Team_Caps from '@salesforce/label/c.PP_Care_Team_Caps';
import PI_Post_Fix from '@salesforce/label/c.PP_PI_Post_Fix';
import Site_Staff_Post_Fix from '@salesforce/label/c.PP_Site_Staff_Post_Fix';
import Need_Tech_Support from '@salesforce/label/c.PP_Need_Tech_Support';
import If_You_Exp_Issue from '@salesforce/label/c.PP_If_You_Exp_Issue';
import supportEmail from '@salesforce/label/c.PG_Unable_To_Login_L6';
import PIR_more from '@salesforce/label/c.PIR_more';
import Not_Available from '@salesforce/label/c.PP_Visit_Result_Value_Not_Available';
import PP_Contact_Support_Show_More from '@salesforce/label/c.PP_Contact_Support_Show_More';
import PP_Contact_Support_Show_Less from '@salesforce/label/c.PP_Contact_Support_Show_Less';

import DesktopTemplate from './ppFooterContactSupportDesktop.html';
import MobileTemplate from './ppFooterContactSupportMobile.html';
import MS_Show_More from '@salesforce/label/c.MS_Show_More';

export default class PpFooterContactSupport extends LightningElement {
    label = {
        Contact_Support,
        Studies_Program,
        For_Question_Abt_Participant,
        Phone_In_Caps,
        Site_And_Location_Caps,
        Care_Team_Caps,
        PI_Post_Fix,
        Site_Staff_Post_Fix,
        Need_Tech_Support,
        If_You_Exp_Issue,
        supportEmail,
        PIR_more,
        Not_Available,
        PP_Contact_Support_Show_More,
        PP_Contact_Support_Show_Less
    };

    phone_Icon = contact_support_icons + '/phone_Icon.svg';
    pi_Icon = contact_support_icons + '/PI_icon.svg';
    address_Icon = contact_support_icons + '/pin_Icon.svg';
    site_Icon = contact_support_icons + '/site_Icon.svg';
    copy_Icon = contact_support_icons + '/copy_Icon.svg';
    copied = contact_support_icons + '/copied.svg';
    copy_hover = contact_support_icons + '/copy-hover.svg';

    @api tittext;
    @api contact;
    @api usermode;
    @api isDelegate = false;
    @api studysite;
    @api isRTL;

    desktop = true;
    piName;
    piSalutation;
    studySitePhone;
    phoneNotAvailable;
    siteName;
    siteAddress;
    siteStaffParticipantList;
    @track siteStaffParticipantListTooltip = [];
    pluscount;
    displaypluscount;
    leftHeight;

    customHeightMatch = 0;
    customHeightStyle = '';
    customHeightMatchForSiteStaff = '';
    showMoreLableState = true;

    showmodal = false;

    phoneNumberValueEle = '';
    addressNumberValueEle = '';
    siteStaffContainerEle = '';
    careTeamContainerEle = '';
    adjustHeight = '';
    phoneContainerEle = '';
    addressContainerEle = '';

    addressCopied = false;
    addressCopyHoverd = false;
    addressTitle = 'Copy';
    phoneCopied = false;
    phoneCopyHoverd = false;
    phoneTitle = 'Copy';
    customHeightRendered = false;

    siteStaffTooltip;

    get copyIconStyle() {
        return this.isRTL ? 'copyIconRTL' : 'copyIcon';
    }

    get pinIconPaddingStyle() {
        return this.isRTL ? 'paddingRight-16' : 'paddingLeft-16';
    }

    get getShowLabel() {
        return this.showMoreLableState ? this.label.PP_Contact_Support_Show_More : this.label.PP_Contact_Support_Show_Less;
    }

    get getShowIcon() {
        return this.showMoreLableState ? 'utility:chevrondown' : 'utility:chevronup';
    }

    renderedCallback() {
        if (this.desktop) {
            //this.setHeight();
            this.careTeamContainerEle = this.template.querySelectorAll('.careTeamContainer');
            this.phoneContainerEle = this.template.querySelectorAll('.phoneContainer');
            this.addressContainerEle = this.template.querySelectorAll('.addressContainer');
            this.resetContainerHeight();
        }
        this.phoneNumberValueEle = this.template.querySelectorAll('.phone-value-ele');
        this.addressNumberValueEle = this.template.querySelectorAll('.address-value-ele');
        this.siteStaffTooltip = this.template.querySelectorAll('.siteStaffTooltip');
        this.siteStaffContainerEle = this.template.querySelectorAll('.site-staff-container');
    }

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        this.showmodal = true;

        //this.piSalutation = this.studysite.Principal_Investigator__r.Salutation;
        //this.piName = this.studysite.Principal_Investigator__r.Name;
        this.phoneNotAvailable = this.studysite.Study_Site_Phone__c ? false : true;
        this.studySitePhone = this.studysite.Study_Site_Phone__c;
        this.siteName = this.studysite.Site__r.Name;
        this.siteAddress =
            this.studysite.Site__r.BillingStreet +
            ', ' +
            this.studysite.Site__r.BillingCity +
            ', ' +
            this.studysite.Site__r.BillingState +
            ', ' +
            this.studysite.Site__r.BillingCountryCode +
            ' ' +
            this.studysite.Site__r.BillingPostalCode;

        getStudyStaff({
            studySiteId: this.studysite.Id
        })
            .then((result) => {
                if (result) {
                    let res = JSON.parse(result);
                    let length = res.length;
                    this.pluscount = length > 3 ? length - 3 : 0;
                    this.displaypluscount = this.pluscount > 0 ? true : false;
                    this.siteStaffParticipantList = res;
                    this.siteStaffParticipantListTooltip = res;
                    this.customHeightStyle = 'height: auto;';
                }
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error', '5000', 'dismissable');
                this.spinner ? this.spinner.hide() : '';
            });

        getPIDetails({
            studySiteId: this.studysite.Id
        })
            .then((result) => {
                if (result) {
                    let res = JSON.parse(result);
                    this.piSalutation = res.Salutation;
                    this.piName = res.Name;
                    this.customHeightStyle = 'height: auto;';
                }
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error', '5000', 'dismissable');
                this.spinner ? this.spinner.hide() : '';
            });
    }

    resetContainerHeight(){
        //  START: Init Logic
            let leftColumnHeight =
                this.phoneContainerEle[0].offsetHeight +
                this.addressContainerEle[0].offsetHeight +
                8;
            let rightColumnHeight = this.careTeamContainerEle[0].offsetHeight;
            //if (this.customHeightRendered == false) {
                if (leftColumnHeight > rightColumnHeight) {
                    //Adjust the height of the right column.
                    this.customHeightStyle = 'height:' + leftColumnHeight + 'px';
                    this.customHeightRendered = true;
                } else {
                    //Adjust the height of the left column.
                    this.adjustHeight =
                        'height:' +
                        (rightColumnHeight - (this.phoneContainerEle[0].offsetHeight + 8)) +
                        'px';
                    this.customHeightRendered = true;
                }
            //}

            // END: Init Logic
    }
    render() {
        return this.desktop ? DesktopTemplate : MobileTemplate;
    }

    handleModalClose() {
        const selectedEvent = new CustomEvent('modalclose', {
            detail: false
        });
        this.dispatchEvent(selectedEvent);
    }

    copyPhoneToClipboard() {
        this.phoneNumberValueEle[0]?.select();
        document.queryCommandSupported('copy');
        document.execCommand('copy');
        this.phoneCopied = true;
        this.phoneCopyHoverd = false;
        this.phoneTitle = 'Copied';

        setTimeout(() => {
            this.onPhonehoverOut();
        }, 2000);
    }

    copyAddressToClipboard() {
        this.addressNumberValueEle[0]?.select();
        document.queryCommandSupported('copy');
        document.execCommand('copy');
        this.addressCopied = true;
        this.addressCopyHoverd = false;
        this.addressTitle = 'Copied';

        setTimeout(() => {
            this.onAddresshoverOut();
        }, 2000);
    }

    addressHoverHandler() {
        this.addressCopyHoverd = true;
    }

    onAddresshoverOut() {
        this.addressCopyHoverd = false;
        this.addressCopied = false;
        this.addressTitle = 'Copy';
    }

    onAddressMouseOut() {
        this.addressCopyHoverd = false;
        this.addressTitle = 'Copy';
    }

    phoneHoverHandler() {
        this.phoneCopyHoverd = true;
    }
    onPhonehoverOut() {
        this.phoneCopyHoverd = false;
        this.phoneCopied = false;
        this.phoneTitle = 'Copy';
    }

    onPhoneMouseOut() {
        this.phoneCopyHoverd = false;
        this.phoneTitle = 'Copy';
    }

    showMoreSiteStaff() {
        this.siteStaffTooltip[0].classList.toggle('slds-hide');
    }

    hideMoreSiteStaff() {
        this.siteStaffTooltip[0].classList.toggle('slds-hide');
    }

    showHideSiteStaff() {
        this.customHeightRendered = false;
        this.customHeightStyle = 'height: auto';
        this.adjustHeight = 'height: auto';
        this.siteStaffContainerEle[0].classList.toggle('toggle-height');
        this.showMoreLableState = !this.showMoreLableState;
    }
}