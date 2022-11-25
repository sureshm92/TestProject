import { LightningElement, api } from 'lwc';
import versionDate from '@salesforce/label/c.Version_date';
import { NavigationMixin } from 'lightning/navigation';

export default class PpDocumentUpdates extends NavigationMixin(LightningElement) {
    @api documentData;
    @api showVisitSection;
    @api desktop;
    noDocumentImage = false;
    thumbnailPresent = false;
    subDomain;
    thumbnail;
    label = {
        versionDate
    };

    connectedCallback() {
        if (this.documentData.thumbnailDocId) {
            this.subDomain = communityService.getSubDomain();
            this.thumbnail =
                this.subDomain +
                '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' +
                this.documentData.thumbnailDocId;
            this.thumbnailPresent = true;
        }
    }

    handleNoThumnnailError() {
        this.thumbnailPresent = false;
    }

    navigateResourceDetail() {
        let subDomain = communityService.getSubDomain();
        let detailLink =
            window.location.origin +
            subDomain +
            '/s/resource-detail' +
            '?resourceid=' +
            this.documentData.resource.Id +
            '&resourcetype=' +
            this.documentData.resource.RecordType.DeveloperName;

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
}
