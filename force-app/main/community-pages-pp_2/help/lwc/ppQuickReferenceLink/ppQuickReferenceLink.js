import { LightningElement, api, track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import pdfjs_dist from '@salesforce/resourceUrl/pdfjs_dist';
import Quick_Refernce from '@salesforce/label/c.Quick_Refernce';
import getInitData from '@salesforce/apex/ApplicationHelpRemote.getInitData';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import { NavigationMixin } from 'lightning/navigation';
import quickRefernceCard from '@salesforce/label/c.Quick_Reference_Card';
import getResourceURL from '@salesforce/apex/HelpController.getResourceURL';
import Quick_Reference_Guide from '@salesforce/label/c.PG_AH_H_Quick_Reference_Guide';

export default class PpQuickReferenceLink extends NavigationMixin(LightningElement) {
    videoLink;
    @api userMode;
    @api isDelegate;
    userManual;
    quickReference;
    yearOfBirthPicklistvalues;
    usrName;
    currentYOB;
    currentContactEmail;
    isDuplicate;
    showUserMatch;
    @api showGetSupport;

    label = {
        Quick_Reference_Guide,
        Quick_Refernce
    }

    renderedCallback() {}
    connectedCallback() {
        this.initializeData();
    }
    initializeData() {
        getInitData({ userMode: this.userMode })
            .then((result) => {
                var initData = JSON.parse(result);
                this.videoLink = initData.videoLink;
                this.userManual = initData.userManual;
                this.quickReference = initData.quickReference;
                this.yearOfBirthPicklistvalues = initData.yearOfBirth;
                this.usrName = initData.usrName;
                this.currentYOB = initData.currentYearOfBirth;
                this.currentContactEmail = initData.usrEmail;
                this.isDuplicate = initData.isDuplicate;
                this.showUserMatch = initData.showUserEmailMatch;
            })
            .catch((error) => {
                console.log('error', error);
            });
    }

    openQuickReference() {
        var webViewer = pdfjs_dist + '/web/viewer.html';
        console.log('webViewer', webViewer);
        getResourceURL({ resourceName: this.quickReference }).then((result) => {
            if (communityService.isMobileSDK()) {
                window.open('../..'+result);
            }
            else{
            setTimeout(() => {
                window.open(
                    webViewer + '?file=' + result + '&fileName=' + quickRefernceCard,
                    '_blank'
                );
            });
        }
        });
    
    }
}