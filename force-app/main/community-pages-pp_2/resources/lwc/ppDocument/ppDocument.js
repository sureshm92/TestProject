import { LightningElement, api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import versionDate from '@salesforce/label/c.Version_date';
export default class Documents extends NavigationMixin(LightningElement) {
    @api document;
    @api pe;
    title;
    versiondate;
    id;
    thumbnail;
    subDomain;
    state;
    dropdownOpen = false;
    translations = [];
    multipleTranslations = false;
    thumbnailPresent = false;
    thumbnailEmpty = pp_community_icons + '/' + 'image-file-landscape-alternate.png';
    label = {
        versionDate
    };
    @track isTabLandscape;
    @track isTabPortrait=false;

    connectedCallback() {
        this.isTabLandscape=this.isTabletLandscape();
        window.addEventListener('orientationchange', this.onOrientationChange);
        this.processData();
    }
    onOrientationChange = () => {
        this.isTabLandscape=this.isTabletLandscape();
        };

    processData() {
        this.id = this.document.resource.Id;
        this.title = this.document.resource.Title__c;
        this.versiondate = this.document.resource.Version_Date__c;
        if (this.document.thumbnailDocId) {
            this.subDomain = communityService.getSubDomain();
            this.thumbnail =
                this.subDomain +
                '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' +
                this.document.thumbnailDocId;
            this.thumbnailPresent = true;
        }

        this.translations = this.document.translations;
        if (this.translations.length > 1) {
            this.multipleTranslations = true;
        }
        if (communityService.isInitialized()) {
            this.state = communityService.getCurrentCommunityMode().participantState;
        }
    }

    handleNavigateDefault() {
        const clickResource = new CustomEvent('resourceclick', {
            detail: { resourceId: this.id },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(clickResource);
        if(this.pe){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'resource-detail'
                },
                state: {
                    resourceid: this.id,
                    resourcetype: this.document.resource.RecordType.DeveloperName,
                    state: this.state,
                    pe:this.pe.Id,
                    studyname:this.pe.Clinical_Trial_Profile__r.Study_Code_Name__c
                }
            });
        }else{
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'resource-detail'
                },
                state: {
                    resourceid: this.id,
                    resourcetype: this.document.resource.RecordType.DeveloperName,
                    state: this.state
                }
            });
        }
    }

    doMenuItemSelected(event) {
        let translationItem = event.target.dataset.itemvalue;
        let langCode = event.target.dataset.langcode;
        let contentId = event.target.dataset.contentid;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'resource-detail'
            },
            state: {
                resourceid: this.id,
                resourcetype: this.document.resource.RecordType.DeveloperName,
                lang: langCode
            }
        });
    }

    handleError() {
        this.thumbnailPresent = false;
    }

    expandClosetheCard() {
        if (this.dropdownOpen) {
            let radioTask = this.template.querySelector('[data-popup="' + this.id + '"]');
            radioTask.classList.remove('slds-is-open');
            this.dropdownOpen = false;
        } else {
            let radioTask = this.template.querySelector('[data-popup="' + this.id + '"]');
            radioTask.classList.add('slds-is-open');
            this.dropdownOpen = true;
        }
    }

    get thumbnailClass(){
        return this.isTabPortrait?'slds-col slds-size_1-of-7 thumbnail-outerbox-tab':'slds-col slds-size_1-of-6 thumbnail-outerbox';
    }

    get docDetailClass(){
        return this.isTabPortrait?'slds-col slds-size_6-of-7 document-details':'slds-col slds-size_5-of-6 document-details';
    }
    isTabletLandscape(){
        let orientation = screen.orientation.type;
        if(window.innerWidth >= 768 && window.innerWidth <= 1280 ){  
        if(/android/i.test(navigator.userAgent.toLowerCase())){            
            if(orientation.startsWith('landscape')){
                this.isTabPortrait=false;
                return true;
            }
            else{
                this.isTabPortrait=true;
                return false;
            }
        }else{
            this.isTabPortrait=false;
            return false;
        }            
        }else{
               this.isTabPortrait=false;
            return false;
        } 
    }
}