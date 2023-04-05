import { LightningElement, api } from 'lwc';
import getStudyStaff from '@salesforce/apex/HomePageParticipantRemote.getStudyStaff';
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

import DesktopTemplate from './DesktopTemplate.html';
import MobileTemplate from './MobileTemplate.html';

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
        supportEmail
    };


    phone_Icon = contact_support_icons+'/phone_Icon.svg';
    pi_Icon = contact_support_icons+'/PI_icon.svg';
    address_Icon = contact_support_icons+'/pin_Icon.svg';
    site_Icon = contact_support_icons+'/site_Icon.svg';
    copy_Icon = contact_support_icons+'/copy_Icon.svg';

    @api tittext;
    @api contact;
    @api usermode;
    @api isDelegate = false;
    @api studysite;

		desktop = true;
    piName;
    studySitePhone;
    siteName;
    siteAddress;
    siteStaffParticipantList;
    leftHeight;

    customHeightMatch = 0;
    customHeightStyle = "";
    customHeightMatchForSiteStaff = "";

    showmodal = false;

    phoneNumberValueEle = "";
    addressNumberValueEle = "";

    renderedCallback(){
        if(this.desktop){
            let phoneContainerHeight = this.template.querySelectorAll('.phoneContainer');
            let addressContainerHeight = this.template.querySelectorAll('.addressContainer');
            this.customHeightMatch = phoneContainerHeight[0].offsetHeight + addressContainerHeight[0].offsetHeight + 8;
            this.customHeightStyle = "height:" + this.customHeightMatch + "px";
            this.customHeightMatchForSiteStaff = "height:" + (this.customHeightMatch - 102) + "px";
        }
        this.phoneNumberValueEle = this.template.querySelectorAll('.phone-value-ele');
        this.addressNumberValueEle = this.template.querySelectorAll('.address-value-ele');
    }

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        this.showmodal = true;

        this.piName = this.studysite.Principal_Investigator__r.Name;
        console.log('piName--->'+this.piName);
        this.studySitePhone = this.studysite.Study_Site_Phone__c;
        console.log('studySitePhone--->'+this.studySitePhone);
        this.siteName = this.studysite.Site__r.Name;
        console.log('siteName--->'+this.siteName);
        this.siteAddress = this.studysite.Site__r.BillingStreet + 
                            ',' + this.studysite.Site__r.BillingCountryCode +
                            ' ' + this.studysite.Site__r.BillingPostalCode;
        console.log('siteAddress--->'+this.siteAddress);

        getStudyStaff({ 
            studySiteId : this.studysite.Id
        })
        .then((result) => {
            if (result) {
                let res = JSON.parse(result);
                console.log(res);
                console.log(JSON.stringify(res));
                this.siteStaffParticipantList = res;
            }
        })
        .catch((error) => {
            this.showErrorToast('Error occured', error.message, 'error', '5000', 'dismissable');
            this.spinner ? this.spinner.hide() : '';
        });   
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

//     openPhoneDialer(event){
//         alert("openphonedialer called;")
//         let mobileNo = event.currentTarget.getAttribute('data-phone');
//         alert(mobileNo);
//         alert(event.currentTarget.dataset.phone);
//       // let mobNo = tel: + value
//        document.location.href = "tel:" + mobileNo;
//    }
   

    // handleCopy() {
    //     let copyMe = this.template.querySelector('.phoneNumber');

    //     copyMe.select();
    //     copyMe.setSelectionRange(start:0, end:999);

    //     document.execCommand(commandId: 'copy');
    // }

     copyPhoneToClipboard(){
         this.phoneNumberValueEle[0].select();
         document.queryCommandSupported('copy');
         document.execCommand('copy');
     }

     copyAddressToClipboard(){
        this.addressNumberValueEle[0].select();
        document.queryCommandSupported('copy');
        document.execCommand('copy');
    }
}