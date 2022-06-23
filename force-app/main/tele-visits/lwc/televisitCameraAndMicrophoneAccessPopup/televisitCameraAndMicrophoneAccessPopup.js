import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Email_Title_PH from '@salesforce/label/c.Email_Title_PH';
import Permissions from '@salesforce/label/c.Permissions';
import IQVIA_Patient_Portal_would_like_to_access_the_microphone_and_camera from '@salesforce/label/c.IQVIA_Patient_Portal_would_like_to_access_the_microphone_and_camera';
import Don_t_allow from '@salesforce/label/c.Don_t_allow';
import Allow_access from '@salesforce/label/c.Allow_access';

export default class CameraAndMicrophoneAccessPopup extends NavigationMixin(LightningElement) {

    @api meetingUrl;
    @api isModalOpenAccessPopup = false;
    label = {
        Email_Title_PH,
        Permissions,
        IQVIA_Patient_Portal_would_like_to_access_the_microphone_and_camera,
        Don_t_allow,
        Allow_access
    }
    showTelevisitVisitPreviewOnDonotAllow = false;

    @api isRTLLanguage = false;

    @api show() {
        this.template.querySelector('.televisitVisitPreviewOnDonotAllowPopup').show();
    }

    closeModal() {
        this.template.querySelector('.televisitVisitPreviewOnDonotAllowPopup').cancel();
    }

    get fontDirectionAndStyle() {
        return this.isRTLLanguage ? 'allFontColor allFontSize rtlText' : 'allFontColor allFontSize';
    }
    get footerDiv() {
        return this.isRTLLanguage ? 'footerRTL' : 'footerLTR';
    }

    renderedCallback() {
        this.template.querySelector('c-web-popup').show();
    }

    handleAllowAccess() {
        let url = this.meetingUrl;
        window.open(url, '_blank');
        this.handleEvent('closeaccesspopup', false);
    }

    handleDonotAllow() {
        this.isModalOpenAccessPopup = false;
        this.showTelevisitVisitPreviewOnDonotAllow = true;
    }

    handleDoNotAllowPopup(event) {
        if (event.detail) {
            this.handleEvent('closeaccesspopup', false);
        } else {
            this.showTelevisitVisitPreviewOnDonotAllow = false;
            this.isModalOpenAccessPopup = true;
        }
    }

    handleCloseModal() {
        this.handleEvent('closeaccesspopup', false);
    }

    handleEvent(eventName, detailProperty) {
        const selectedEvent = new CustomEvent(eventName, {
            detail: detailProperty
        });
        this.dispatchEvent(selectedEvent);
    }

}