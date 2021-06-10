/**
 * Created by Ranjit Ravindranath 5/20/2021
 */
import { LightningElement, track, api, wire } from 'lwc';
import lwcStyleResource from '@salesforce/resourceUrl/lwcCss';
import downloadPdf from '@salesforce/label/c.Download_PDF_pp';
import lastUpdatedText from '@salesforce/label/c.Last_Updated_pp_text';
import okBtn from '@salesforce/label/c.BTN_OK';//BTN_OK
import ppHeaderLabel from '@salesforce/label/c.Email_Footer_Privacy_Policy';
import ppLabel from '@salesforce/label/c.Lofi_Login_Footer_Policies';
import headerLabel from '@salesforce/label/c.Privacypolicy_pdf_headers';
import getPrivacyPolicy from '@salesforce/apex/TermsAndConditionsRemote.getTC';
import generatePDF from '@salesforce/apex/TermsAndConditionsRemote.generatePDF';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';//Lofi_Login_Icons newIqviaLogo


export default class PrivacyPolicyViewer extends LightningElement {
    @api isModalOpen;
    @api isCommunityFooter;
    @track ppRichText;
    @track listOfHeaders = [];
    @track paraList = [];
    @api defaultCommunityBoolean;
    @track pdfId;
    @track dwnldUrl;
    @track headerLogo;
    @track lastUpdated;
    @track empNames = [];
    currentPageReference = null; 
    closePrivacyPolicyTab = false;
   defaultCommunityBoolean = true;
   tcId;
   attachment;

   headerLogo = LOFI_LOGIN_ICONS + '/favicon_darkblue_64.svg';
    labels = {
        ppLabel,
        ppHeaderLabel,
        okBtn,
        lastUpdatedText,
        downloadPdf
        };
    
    
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    navigateToHomePage(event) {
        var needle = event.currentTarget.dataset.value;
        console.log('needle: '+needle);
        var newValue = this.ppRichText.replace(needle, '<p class="imhere" data-id="imhere"></p>'+needle);
        this.template.querySelector('[data-id="text"]').innerHTML = newValue;
        let myElement = this.template.querySelector('[data-id="imhere"]');
        var headerOffset = 75;
        var elementPosition = myElement.offsetTop;//getBoundingClientRect().top;
        var offsetPosition = elementPosition - headerOffset;
        this.template.querySelector('[data-id="scroller"]').scrollTop = offsetPosition;
    }

    saveAsPdf(){
        console.log('this.tcId: '+this.tcId);
        this.spinner.show();
        generatePDF({
            ppId : this.tcId
        })
        .then((result) => {
            console.log('dwnld: '+result);
            this.spinner.hide();
            location.href = result;
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
        });
    }
    handleSelect(event) {
        console.log('label: ');
    }
    renderedCallback() {
        
        if(this.isModalOpen){
            this.spinner = this.template.querySelector('c-web-spinner');
            var myElement = this.template.querySelector('[data-id="text"]');
            myElement.innerHTML = this.ppRichText;
        }
    }
   
    connectedCallback() {
        
        let userDefalutTC = communityService.getUrlParameter('default') ? true : false;
        let HasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI() ? true : false;
        console.log('userDefalutTC: '+userDefalutTC);
        console.log('HasIQVIAStudiesPI: '+HasIQVIAStudiesPI);
       let ppGetter = getPrivacyPolicy({
            code:'PrivacyPolicy',
            languageCode: communityService.getUrlParameter('language') ? communityService.getUrlParameter('language') : null,
            useDefaultCommunity: HasIQVIAStudiesPI && userDefalutTC //this.defaultCommunityBoolean
        })
        .then((result) => {
            let tcData = JSON.parse(result);
            this.tcId = tcData.tc.Id;
            this.ppRichText = tcData.tc.T_C_Text__c;
            console.log('Last_Updated_on__c: '+tcData.tc.Last_Updated_on__c);
            this.lastUpdated = tcData.tc.Last_Updated_on__c;
            var lists = tcData.tc.Policy_Headers__c.split("\r\n");
            var psrsList;
            var psrsList1;

            this.empNames = lists;
            this.listOfHeaders = this.empNames.map((name, index) => {
                return { name, sno: index + 1 };
            });
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
        });
            
        
        
    }
}