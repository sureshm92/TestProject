import { LightningElement ,track} from 'lwc';

import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import formFactor from '@salesforce/client/formFactor';

import getInitData from '@salesforce/apex/OptOutAndTechnicalSupportRemote.getInitData';
import createSupportCases from '@salesforce/apex/OptOutAndTechnicalSupportRemote.createSupportCases';
import PPOPTOUTCOMMUNICATIONPREF from '@salesforce/label/c.PP_Opt_Out_Update_Communication_Pref';
import PPOPTOUTCOMMUNICATIONPREFHELP from '@salesforce/label/c.PP_Opt_Out_Update_Communication_Pref_Help';
import PPCPSUBMITBTN from '@salesforce/label/c.CP_Submit_Button';
import PPOPTOUTSUCCESSMSG from '@salesforce/label/c.PP_Opt_Out_Success_Message';
import PPOptOutCloseWindow from '@salesforce/label/c.PP_Opt_Out_Close_window';

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
    label = {
        PPOPTOUTCOMMUNICATIONPREF,
        PPOPTOUTCOMMUNICATIONPREFHELP,
        PPCPSUBMITBTN,
        PPOPTOUTSUCCESSMSG,
        PPOptOutCloseWindow
    };

    isMobile = false;


    get displayLabel(){
        if(this.showSuccessMessage){
            return 'slds-hide';
        }
        else{
          return 'slds-show main-content-div';
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
            return 'slds-show submit-button-div ml-24';
        }
    }
    get displayLogo(){
        if(this.showSuccessMessage){
            return 'slds-show success-message-text';
        }
        else{
            return 'slds-hide';
        }
    }
    connectedCallback(){
        this.disabled = true;
		this.showSpinner = true;

        if (formFactor === 'Small') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }

        let language = communityService.getUrlParameter('language');
        if (!language || language === '') {
            language = 'en_US';
        }

        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            Promise.all([loadStyle(this, communityPPTheme)])
                .then(() => {

                })
                .catch((error) => {
                    console.log(error.body.message);
                });
        })
        .catch((error) => {
            communityService.showToast('', 'error', error.message, 100);
        });  

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
    handleSubmit() {
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
        })
        .catch(function (error) {
            console.error(JSON.stringify(error));
        });
    }

    closeWindow(){
        window.close();
    }


}