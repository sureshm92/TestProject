import { LightningElement, track } from 'lwc';
import resourcesDesktop from './ppResourceDesktopPage.html';
import resourcesMobile from './ppResourceMobilePage.html';
import DEVICE from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import getTrialDetail from '@salesforce/apex/StudyDetailViewController.getTrialDetail';
import getLinksData from '@salesforce/apex/RelevantLinksRemote.getInitData';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import RELEVANT_LINKS from '@salesforce/label/c.Home_Page_RelevantLinks_Title';
import DISCOVER_TITLE from '@salesforce/label/c.Discover_Title';
import ENGAGE from '@salesforce/label/c.PP_Resource_Engage';
import EXPLORE from '@salesforce/label/c.PP_Resource_Explore';
import DOCUMENTS from '@salesforce/label/c.PP_Resource_Documents';
import FIND_ANSWERS from '@salesforce/label/c.PP_Resource_Answers';
import RESOURCES from '@salesforce/label/c.PG_SW_Tab_Resources';
import CHANGE_PREFERENCES from '@salesforce/label/c.PP_Change_Preferences';
import basePathName from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';

import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpResourceContainerPage extends NavigationMixin(LightningElement) {
    //boolean var
    desktop = true;
    isRTL = false;
    isInitialized = false;
    toggleExplore = false;
    toggleLinks = false;
    toggleDocs = false;

    linksGridSize = 3;
    documentGridSize = 3;
    hideFirstColumn = false;
    rightColumnPadding = "resource-gutter-left";

    //labels
    labels = {
        RESOURCES,
        RELEVANT_LINKS,
        ERROR_MESSAGE,
        ENGAGE,
        EXPLORE,
        DOCUMENTS,
        FIND_ANSWERS,
        DISCOVER_TITLE,
        CHANGE_PREFERENCES
    };
    @track linksData;
    @track trialdata;
    redirecturl = '';
    disableSave = true;
    @track textValue;
    @track selectedResourceType;
    @track options = [];

    selectedOptions = "Engage";
    containerElement;

    empty_state = pp_community_icons + '/' + 'engage_empty.png';

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    connectedCallback() {        
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);       
        this.initializeData();
    }
    // renderedCallback(){
    //     window.addEventListener('click', this.closeOptions);
    // }
    //template toggle
    render() {
        return this.desktop ? resourcesDesktop : resourcesMobile;
    }
    async initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        if (communityService.isInitialized()) {
            var recId = communityService.getUrlParameter('id');
            var userMode = communityService.getUserMode();
            //language support
            let paramLanguage = communityService.getUrlParameter('language');
            let lanCode = communityService.getUrlParameter('lanCode');

            if (
                rtlLanguages.includes(communityService.getLanguage()) ||
                (paramLanguage && rtlLanguages.includes(paramLanguage)) ||
                (lanCode && rtlLanguages.includes(lanCode))
            ) {
                this.isRTL = true;
            }
            let result = await getTrialDetail({ trialId: recId, userMode: userMode }).catch(
                (error) => {
                    this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                }
            );
            this.linksData = await getLinksData({}).catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });

            this.trialdata = JSON.parse(result);
            //cards toggle logic
            if (communityService.getCurrentCommunityMode().participantState == 'PARTICIPANT') {
                this.toggleExplore = this.trialdata?.trial?.Video_And_Articles_Are_Available__c;
                this.toggleDocs = this.trialdata?.trial?.Study_Documents_Are_Available__c;
                this.toggleLinks = this.linksData?.linksAvailable;
            } else {
                this.toggleExplore = true;
                this.toggleLinks = true;
            }
            this.isInitialized = true;
            this.createoptions();
        }

        if (this.spinner) {
            this.spinner.hide();
        }
    }
    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
    handleChangePreference() {
        this.redirecturl = window.location.origin + basePathName + '/account-settings?changePref';
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: this.redirecturl
            }
        };
        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }
    updateResources(event) {
        this.selectedResourceType = event.currentTarget.dataset.key;
        this.getKey(this.selectedResourceType);

        let inputFields = this.template.querySelectorAll('.noselected');
        inputFields.forEach((ele) => {
            let key = ele.getAttribute('data-key');
            if (key == this.selectedResourceType) {
                ele.classList.add('selected');
            }
            else{
                ele.classList.remove('selected');
            }
        });
    }

    getKey(value){
            this.options.forEach((obj, index) => {
                let key = '';
                if(obj.value == value){
                    key = obj.label
                    this.selectedOptions = key;
                }
            });      
    }
    get exploreVisible() {
        return this.selectedResourceType == 'explore' ? true : false;
    }
    get documentsVisible() {
        return this.selectedResourceType == 'documents' ? true : false;
    }

    get discoverVisible() {
        return this.selectedResourceType == 'discover' ? true : false;
    }

    get answersVisible() {
        return this.selectedResourceType == 'answers' ? true : false;
    }

    get engageVisible() {
        return this.selectedResourceType == 'engage' ? true : false;
    }

    createoptions() {
        if (this.toggleExplore) {
            let option = { value: 'engage', label: this.labels.ENGAGE };
            let option1 = { value: 'explore', label: this.labels.EXPLORE };
            this.options.push(option);
            this.options.push(option1);

        }
        if (this.toggleLinks) {
            let option = { value: 'discover', label: this.labels.DISCOVER_TITLE };
            this.options.push(option);
        }
        if (this.toggleDocs) {
            let option = { value: 'documents', label: this.labels.DOCUMENTS };
            this.options.push(option);
        }

        // Populate Grid size 
        if(!this.toggleExplore && !this.toggleDocs && this.toggleLinks){
            this.linksGridSize = 6;
        }

        if(!this.toggleExplore && !this.toggleLinks && this.toggleDocs){
            this.hideFirstColumn = true;
            this.documentGridSize = 6;
            this.rightColumnPadding = '';
        }
    }

    showOptions(event){
        this.containerElement = this.template.querySelectorAll('.res-options');
        this.containerElement[0].classList.toggle('hidden');
    }

    // closeOptions(event){
    //     if(this.containerElement[0])
    //         this.containerElement[0].classList.add('hidden');      
    // }
}