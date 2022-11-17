import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import versionDate from '@salesforce/label/c.Version_date';
export default class Documents extends NavigationMixin(LightningElement) {
    @api document;
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

    connectedCallback() {
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
        let detailLink =
            window.location.origin +
            '/pp/s/resource-detail' +
            '?resourceid=' +
            this.id +
            '&resourcetype=' +
            this.document.resource.RecordType.DeveloperName +
            '&state=' +
            this.state;

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }

    doMenuItemSelected(event) {
        let translationItem = event.target.dataset.itemvalue;
        let langCode = event.target.dataset.langcode;
        let contentId = event.target.dataset.contentid;

        let detailLink =
            window.location.origin +
            '/pp/s/resource-detail' +
            '?resourceid=' +
            this.id +
            '&resourcetype=' +
            this.document.resource.RecordType.DeveloperName;
        if (langCode) detailLink += '&lang=' + langCode;
        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
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
}
