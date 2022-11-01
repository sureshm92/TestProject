import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Documents extends NavigationMixin(LightningElement) {
    @api document;
    title;
    versiondate;
    id;
    thumbnail;
    translations = [];
    multipleTranslations = false;

    connectedCallback() {
        this.id = this.document.resource.Id;
        this.title = this.document.resource.Title__c;
        this.versiondate = this.document.resource.Version_Date__c;
        this.thumbnail =
            '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' +
            this.document.thumbnailDocId;
        this.translations = this.document.translations;
        if (this.translations.length > 1) {
            this.multipleTranslations = true;
        }
    }

    handleNavigateDefault() {
        let detailLink =
            window.location.origin +
            '/pp/s/resource-detail' +
            '?resourceid=' +
            this.id +
            '&resourcetype=' +
            this.document.resource.RecordType.DeveloperName;

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

    expandtheCard() {
        let radioTask = this.template.querySelector('[data-popup="' + this.id + '"]');
        radioTask.classList.add('slds-is-open');
    }

    closeMenu() {
        let radioTask = this.template.querySelector('[data-popup="' + this.id + '"]');
        radioTask.classList.remove('slds-is-open');
    }
}
