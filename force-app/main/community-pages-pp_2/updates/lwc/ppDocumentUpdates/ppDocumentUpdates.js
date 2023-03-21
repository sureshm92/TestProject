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
        console.log(this.documentData.thumbnailDocId);
        if (this.documentData.thumbnailDocId) {
            this.subDomain = communityService.getSubDomain();
            this.thumbnail =
                this.subDomain +
                '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' +
                this.documentData.thumbnailDocId;
            this.thumbnailPresent = true;
        }
        console.log('thumbnail : '+this.thumbnail)
    }

    handleNoThumnnailError() {
        console.log('coming here to no thumbnail')
        this.thumbnailPresent = false;
    }

    navigateResourceDetail() {
        let subDomain = communityService.getSubDomain();
        let state;
        if (communityService.isInitialized()) {
            state = communityService.getCurrentCommunityMode().participantState;
        }
        console.log('window.location.origin : '+window.location.origin);
        let detailLink =
            window.location.origin +
            subDomain +
            '/s/resource-detail' +
            '?resourceid=' +
            this.documentData.recId +
            '&resourcetype=' +
            this.documentData.resourceDevRecordType +
            '&state=' +
            state;

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            sessionStorage.setItem('Cookies', 'Accepted');
            //window.open(url, '_self');
        });
    }
}
