import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// importing Custom Label
import You_can_also_adjust_these_options_during_the_visit from '@salesforce/label/c.You_can_also_adjust_these_options_during_the_visit';
import You_must_grant_microphone_permission_to_join_televisit from '@salesforce/label/c.You_must_grant_microphone_permission_to_join_televisit';
import Join_Visit from '@salesforce/label/c.Join_Visit';
import Back from '@salesforce/label/c.Back';
import Visit_Preview from '@salesforce/label/c.Visit_Preview';


export default class TelevisitVisitPreviewOnDonotAllow extends NavigationMixin(LightningElement) {
    isModalOpenVisitPreview = true;
    showtelevisitCameraAndMicrophoneAccessPopup = false;
    label = {
        You_can_also_adjust_these_options_during_the_visit,
        You_must_grant_microphone_permission_to_join_televisit,
        Join_Visit,
        Back,
        Visit_Preview
    }

    isRTL = false;
    userId;
    showTelevisitCameraAndMicrophoneAccessPopup = false;
    @api meetingLink;
    
    @api show(userName) {
        this.template.querySelector('.unableToLoginPopup').show();
        this.userId = userName;
    }

    closeModal() {
        this.template.querySelector('.unableToLoginPopup').cancel();
    }

    // Initializes the component
    connectedCallback(event){
        this.isModalOpenVisitPreview = true;
    }

    renderedCallback() { 
        this.template.querySelector('c-web-popup').show();
        this.isModalOpenVisitPreview = true;
    }

    handleBack(){
         this.isModalOpenVisitPreview = false;
         this.showTelevisitCameraAndMicrophoneAccessPopup = true;
    }
   
}