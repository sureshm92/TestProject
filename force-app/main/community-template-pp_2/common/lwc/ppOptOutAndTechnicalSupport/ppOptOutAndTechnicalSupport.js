import { LightningElement ,track, wire} from 'lwc';

import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import formFactor from '@salesforce/client/formFactor';
import ppOptoutchannel from '@salesforce/messageChannel/ppOptout__c';
import { subscribe, publish, MessageContext } from 'lightning/messageService';

import getInitData from '@salesforce/apex/OptOutAndTechnicalSupportRemote.getInitData';
import createSupportCases from '@salesforce/apex/OptOutAndTechnicalSupportRemote.createSupportCases';
import PPOPTOUTCOMMUNICATIONPREF from '@salesforce/label/c.PP_Opt_Out_Update_Communication_Pref';
import PPOPTOUTCOMMUNICATIONPREFHELP from '@salesforce/label/c.PP_Communication_Email_Text';
import PPCPSUBMITBTN from '@salesforce/label/c.CP_Submit_Button';
import PPOPTOUTSUCCESSMSG from '@salesforce/label/c.PP_Opt_Out_Success_Message';
import PPOptOutCloseWindow from '@salesforce/label/c.PP_Opt_Out_Close_window';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';

export default class PpOptOutAndTechnicalSupport extends LightningElement {

    optOutTranslatedTitle;
    @track optOutSubCategoryList =[];
    techSupportTranslatedTitle;
    @track techSupportSubCategoryList=[];
    @track selectedOptOutSubCategory=[];
    @track selectedTechSupportSubCategory=[];
    disabled = false;
    showSuccessMessage=false;
    showSpinner = false;
    AndroidTablet;
    ipad;

    loaded = false;
    label = {
        PPOPTOUTCOMMUNICATIONPREF,
        PPOPTOUTCOMMUNICATIONPREFHELP,
        PPCPSUBMITBTN,
        PPOPTOUTSUCCESSMSG,
        PPOptOutCloseWindow
    };
    isMobile = false;

    @wire(MessageContext)
    messageContext;


    get displayLabel(){
        if(this.showSuccessMessage){
            return 'slds-hide';
        }
        else{
            if(this.ipad){
                return 'slds-show main-content-div-ipad';
            }
            else if(!this.isMobile && !this.ipad && !this.AndroidTablet){
                return 'slds-show main-content-div-desk';
            }
            else{
                return 'slds-show main-content-div';
            }
        }
    }
    get displayLabelMobile(){
        if(this.showSuccessMessage){
            return 'slds-hide';
        }
        else{
          return 'slds-show main-content-div-mobile';
        }
    }
    get buttonDisplay(){
        if(this.showSuccessMessage){
            return 'slds-hide ml-24';
        }
        else{
            if(this.ipad){
                 return 'slds-show submit-button-div-ipad';
            }
            else if(this.isMobile || this.AndroidTablet){
                return 'slds-show ml-24';
            }
            else if(!this.isMobile){
                return 'slds-show';
            }
        }
    }
    get displayLogo(){
        if(this.showSuccessMessage){

            if(this.AndroidTablet || this.isMobile){
                return 'slds-show success-message-text';
            }
            else if(this.ipad){
                return 'slds-show success-message-text-ipad';
            }
            else{
                return 'slds-show success-message-text-desk';
            }
        }
        else{
            return 'slds-hide';
        }

    }

    get successMargin(){
        if(this.AndroidTablet){
            return 'apollo-btn primary submit-mobile mb-112';
        }
        else{
            return 'apollo-btn primary submit-mobile mb-30';
        }
    }
    connectedCallback(){
        this.disabled = true;
		this.showSpinner = true;

        if (formFactor === 'Small' ||formFactor === 'Medium' ) {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }

        if (!this.loaded) {
            Promise.all([
                loadScript(this, rrCommunity),
                loadStyle(this, communityPPTheme),
                ])
                .then(() => {
                    if (communityService.isAndroidTablet()) {
                        this.AndroidTablet = true;
                    }
                    else if (communityService.isIpad()) {
                        this.ipad = true;
                    }
                })
                .catch((error) => {
                    console.log(error.body.message);
                });
        } 

        let language = '';
            let sParam = 'language';
            let sPageURL = document.location.search.substring(1),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                if (sParameterName[0] === sParam) {
                    language = sParameterName[1] === undefined ? '' : sParameterName[1];
                }
            }

        //let language = communityService.getUrlParameter('language');
        if (!language || language === '') {
            language = 'en_US';
        }

        getInitData({ strLanguage: language })
        .then((data) => {
            for (let item of data) {
                if (item.strCategoryValue === 'Opt Out of communication') {
                    this.optOutTranslatedTitle = item.strTranslatedCategoryValue;
                    this.optOutSubCategoryList = item.labelValueItemList;
                } else if (item.strCategoryValue === 'Get Technical Support') {
                    this.techSupportTranslatedTitle = item.strTranslatedCategoryValue;
                    this.techSupportSubCategoryList = item.labelValueItemList;
                }
            }
			 this.showSpinner = false;
           })
        .catch(function (error) {
            console.error(JSON.stringify(error));
			this.showSpinner = false;

        });
    }
    handleChange(event) {
        var selectedOptOutSubCategory;
        var selectedTechSupportSubCategory;
        if(event.currentTarget.dataset.id == 'checkbox1'){
            selectedOptOutSubCategory = event.detail.value;
        }
        else if(event.currentTarget.dataset.id == 'checkbox2'){
            selectedTechSupportSubCategory = event.detail.value;
        }
         selectedOptOutSubCategory = event.detail.value;
        console.log('selectedOptOutSubCategory::'+selectedOptOutSubCategory);
         selectedTechSupportSubCategory = event.detail.value;
        console.log('selectedTechSupportSubCategory::'+selectedTechSupportSubCategory);

        if (
            (selectedOptOutSubCategory && selectedOptOutSubCategory.length > 0) ||
            (selectedTechSupportSubCategory && selectedTechSupportSubCategory.length > 0)
        ) {
            this.disabled = false;
        } else {
            this.disabled = true;
        }
    }
    handleSubmit(event) {
        var recipientId = communityService.getUrlParameter('recipientId');
        this.showSpinner = true;
        createSupportCases({                 
            optOutValueList: this.selectedOptOutSubCategory,
            techSupportValueList: this.selectedTechSupportSubCategory,
            strContactId: recipientId
        })
        .then((data) => {
            this.showSpinner =  false;
            this.showSuccessMessage =  true;
            //message service
                const message = { SuccessMessage: this.showSuccessMessage };
                publish(this.messageContext, ppOptoutchannel, message);
        })
        .catch(function (error) {
            console.error(JSON.stringify(error));
        });

        // console.log('dataToSend 1');
        //     //passing value to aura
        //     let dataToSend = true;
        //     console.log('dataToSend 2');
        //     const sendDataEvent = new CustomEvent('senddata', {
        //         detail: {dataToSend},
        //     });
        //     console.log('dataToSend 3');
        //     this.dispatchEvent(sendDataEvent);
        //     console.log('dataToSend 4');
        
    }

    closeWindow(){
//window.top.close();
        window.close();
       
    }


}