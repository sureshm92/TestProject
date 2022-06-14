import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// importing Custom Label
import Email_Title_PH from '@salesforce/label/c.Email_Title_PH';
import Permissions from '@salesforce/label/c.Permissions';
import IQVIA_Patient_Portal_would_like_to_access_the_microphone_and_camera from '@salesforce/label/c.IQVIA_Patient_Portal_would_like_to_access_the_microphone_and_camera';
import Don_t_allow from '@salesforce/label/c.Don_t_allow';
import Allow_access from '@salesforce/label/c.Allow_access';

export default class CameraAndMicrophoneAccessPopup extends NavigationMixin(LightningElement)  {

    @api meetingUrl;
    isModalOpenAccessPopup = true;
    label = {
        Email_Title_PH,
        Permissions,
        IQVIA_Patient_Portal_would_like_to_access_the_microphone_and_camera,
        Don_t_allow,
        Allow_access
    }
    showTelevisitVisitPreviewOnDonotAllow = false;

    @api isRTLLanguage = false;
    userId;
    @api show(userName) {
        console.log('inside sho ssss w');
        this.template.querySelector('.televisitVisitPreviewOnDonotAllowPopup').show();
        this.userId = userName;
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

    // Initializes the component
    connectedCallback(event){
        console.log('inside connectedCallback--->'+this.meetingUrl);
        this.isModalOpenAccessPopup = true;
    }

    renderedCallback() { 
        console.log('iside renderedCallback');
        this.template.querySelector('c-web-popup').show();
        this.isModalOpenAccessPopup = true;
    }

    handleAllowAccess(event){
        console.log('handleAllowAccess---->'+this.meetingUrl);
        let url = this.meetingUrl;
        //let url = event.target.dataset.name;
       /* this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
                attributes: {
                    url: url
                }
            },
            true
        ).then(generatedUrl => {
            window.open(generatedUrl, '_blank');
        });*/

        window.open(url, '_blank');
    }

    handleDonotAllow(event){
        this.isModalOpenAccessPopup = false;
        this.showTelevisitVisitPreviewOnDonotAllow = true;
    }

    closeModal(){
        console.log('closeModal');
        this.isModalOpenAccessPopup = false;
    }

}