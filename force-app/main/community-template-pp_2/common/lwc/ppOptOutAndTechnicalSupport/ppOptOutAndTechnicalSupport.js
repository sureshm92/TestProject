import { LightningElement ,track} from 'lwc';

import getInitData from '@salesforce/apex/OptOutAndTechnicalSupportRemote.getInitData';
import createSupportCases from '@salesforce/apex/OptOutAndTechnicalSupportRemote.createSupportCases';
import PPOPTOUTCOMMUNICATIONPREF from '@salesforce/label/c.Opt_Out_Update_Communication_Pref';
import PPOPTOUTCOMMUNICATIONPREFHELP from '@salesforce/label/c.Opt_Out_Update_Communication_Pref_Help';
import PPCPSUBMITBTN from '@salesforce/label/c.CP_Submit_Button';
import PPOPTOUTSUCCESSMSG from '@salesforce/label/c.Opt_Out_Success_Message';



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
        PPOPTOUTSUCCESSMSG
    };


    get displayLabel(){
        if(this.showSuccessMessage){
            return 'slds-hide';
        }
        else{
          return 'slds-show main-content-div';
        }
    }
    get buttonDisplay(){
        if(this.showSuccessMessage){
            return 'slds-hide';
        }
        else{
            return 'slds-show submit-button-div';
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
        let language = communityService.getUrlParameter('language');
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


}