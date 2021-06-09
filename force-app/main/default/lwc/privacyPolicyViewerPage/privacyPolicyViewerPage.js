/**
 * Created by Ranjit Ravindranath 5/20/2021
 */
import { LightningElement, track, api, wire } from 'lwc';
import lwcStyleResource from '@salesforce/resourceUrl/lwcCss';
import { loadStyle } from 'lightning/platformResourceLoader';
import downloadPdf from '@salesforce/label/c.Download_PDF_pp';
import lastUpdatedText from '@salesforce/label/c.Last_Updated_pp_text';
import ppHeaderLabel from '@salesforce/label/c.Email_Footer_Privacy_Policy';//Email_Footer_Privacy_Policy
import ppLabel from '@salesforce/label/c.Footer_Link_Privacy_Policy';
import headerLabel from '@salesforce/label/c.Privacypolicy_pdf_headers';
import getPrivacyPolicy from '@salesforce/apex/TermsAndConditionsRemote.getTC';
import generatePDF from '@salesforce/apex/TermsAndConditionsRemote.generatePDF';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';


export default class PrivacyPolicyViewer extends LightningElement {
    @track selectedItem = 'reports_recent';
    @track currentContent = 'reports_recent';
    @api isModalOpen;
    @api testing;
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
    //ppDataAvailable = false;
    labels = {
        ppLabel,
        ppHeaderLabel,
        lastUpdatedText,
        downloadPdf
        };
    
    /*@wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('name: '+currentPageReference.attributes.name);
            if(currentPageReference.attributes.name == 'Privacy_Policy__c'){
                this.closePrivacyPolicyTab = true;
            }
        }
    }*/
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        console.log('CloseModal: '+this.closePrivacyPolicyTab);
        this.isModalOpen = false;
    }
    navigateToHomePage(event) {
        console.log('Scroll: '+event.currentTarget.dataset.value);
        var needle = event.currentTarget.dataset.value;
        console.log('needle: '+needle);

        var newValue = this.ppRichText.replace(needle, needle+'<a data-id="imhere"></a>');
        this.template.querySelector('[data-id="text"]').innerHTML = newValue;

        var myElement = this.template.querySelector('[data-id="imhere"]');
        console.log('newVal'+myElement.offsetTop);
        myElement.scrollIntoView({behavior: "smooth", block: "center"});
        /*var topos = myElement.offsetTop;
        console.log('tester: '+this.template.querySelector('[data-id="tester"]'));
        this.template.querySelector('[data-id="tester"]').scrollTop = topos;*/
        //myElement.scrollIntoView({behavior: "smooth"});
        //window.scrollTo(0, myElement.offsetTop);
        //$('html, body').animate({ scrollTop: $('#imhere').offset().top }, 'slow');
    }


    saveAsPdf(){
        console.log('id:  '+this.tcId);
        generatePDF({
            ppId : this.tcId
        })
        .then((result) => {
            console.log('contId'+result);
            //this.dwnldUrl = window.location.href + '/sfc/servlet.shepherd/document/download/'+ result + '?operationContext=S1';
            //console.log('url: '+this.dwnldUrl);
            location.href = result;
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
        });
    }
    scrollToPoint(){
        var topDiv = document.getElementById("modal-content-id-1");
        //const topDiv = this.template.querySelector('[id="modal-content-id-1"]');
        topDiv.scrollTo({top: 100, behavior: 'smooth'});
        //topDiv.scrollIntoView();
       // topDiv.scrollBy(0, 100);
    }
    handleSelect(event) {
        
        console.log('label: ');
        //let targetId = event.target.dataset.targetId;
        //const selected = event.detail.name;
        let target = this.template.querySelector('[data-id="scrollHere"]');
        target.scrollIntoView();

        this.currentContent = selected;

    }
    renderedCallback() {
        
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner.show();
            if(this.ppRichText){
                this.spinner.hide();
            }
            console.log('isModalOpen: ');
            var myElement = this.template.querySelector('[data-id="text"]');
            console.log('innerHtml'+myElement);
            myElement.innerHTML = this.ppRichText;
    }

    handleClick() {
        console.log('handleClick');
        const editor  = this.template.querySelector('lightning-formatted-rich-text');
        const textToInsert = 'Journey to Salesforce'
        editor.setRangeText(textToInsert, undefined, undefined, 'select')
        editor.setFormat({bold: true, size:24, color: 'green', align: 'center',});
    }

    connectedCallback() {
        /*var lists = headerLabel.split(",");
        //var paragraphList ;
        
        for(let key in lists) {
            //console.log('key: '+lists[key]);
            if (lists.hasOwnProperty(key)) { // Filtering the data in the loop
                this.listOfHeaders.push({value:lists[key], key:key});
            }
        }*/
       let ppGetter = getPrivacyPolicy({
            code:'PrivacyPolicy',
            languageCode: communityService.getUrlParameter('language'),
            useDefaultCommunity: communityService.getHasIQVIAStudiesPI() && userDefalutTC //this.defaultCommunityBoolean
        })
        .then((result) => {
            let tcData = JSON.parse(result);
            this.tcId = tcData.tc.Id;
            this.ppRichText = tcData.tc.T_C_Text__c;
            this.lastUpdated = tcData.tc.Last_Updated_on__c;
            var lists = tcData.tc.Policy_Headers__c.split("\r\n");
            var psrsList;
            var psrsList1;

            this.empNames = lists;
            console.log('empNames: '+this.empNames);
            this.listOfHeaders = this.empNames.map((name, index) => {
                return { name, sno: index + 1 };
            });
           /* var myElement = this.template.querySelector('[data-id="text"]');
            console.log('innerHtml'+myElement);
            myElement.innerHTML = tcData.tc.T_C_Text__c;*/

            
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
        });
            
        
        
    }
}