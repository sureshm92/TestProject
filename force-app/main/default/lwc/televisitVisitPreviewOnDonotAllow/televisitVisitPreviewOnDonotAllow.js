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
        console.log('inside sho ssss w');
        this.template.querySelector('.unableToLoginPopup').show();
        this.userId = userName;
    }

    closeModal() {
        this.template.querySelector('.unableToLoginPopup').cancel();
    }
    

    // Initializes the component
    connectedCallback(event){
        console.log('connectedCallback-2-->'+this.meetingLink);
       
        this.isModalOpenVisitPreview = true;
    }

    renderedCallback() { 
        console.log('iside renderedCallback');
        this.template.querySelector('c-web-popup').show();
        this.isModalOpenVisitPreview = true;
    }

    handleBack(){
        /*var compDefinition = {
            componentDef: "c:televisitCameraAndMicrophoneAccessPopup",
            attributes: {
                //propertyValue: "500"
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });*/
         this.isModalOpenVisitPreview = false;
         this.showTelevisitCameraAndMicrophoneAccessPopup = true;
    }
   
    
}