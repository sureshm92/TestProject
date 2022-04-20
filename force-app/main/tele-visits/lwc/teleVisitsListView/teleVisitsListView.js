import { LightningElement, api } from 'lwc';
//import { loadScript } from 'lightning/platformResourceLoader';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import RTL_Languages from '@salesforce/label/c.RTL_Languages';
import FILTER_LABEL from '@salesforce/label/c.Home_Page_StudyVisit_Show_Filter_Visits';
import TIMEZONE from '@salesforce/i18n/timeZone';

export default class TeleVisitsListView extends LightningElement {
    @api isMobileApp;
    @api isRTL;
    labels = {
        RTL_Languages,
        FILTER_LABEL
    };
    options = [
        {
            value: 'Upcoming',
            label: 'Upcoming'
        },
        { value: 'Past', label: 'Past' },
        { value: 'Cancelled', label: 'Cancelled' }
    ];
    teleVisits = [
        {
            id: '0',
            visitName: 'Visit 1',
            visitDate: '2022-04-18T11:16:47.000+0000',
            visitDuration: '30 minutes',
            visitAttendees: 'Mike Tyson (PI)'
        },
        {
            id: '1',
            visitName: 'Visit 2',
            visitDate: '2022-04-18T11:16:47.000+0000',
            visitDuration: '30 minutes',
            visitAttendees: 'Mike Tyson (PI)'
        },
        {
            id: '2',
            visitName: 'Visit 3',
            visitDate: '2022-04-18T11:16:47.000+0000',
            visitDuration: '30 minutes',
            visitAttendees: 'Mike Tyson (PI)'
        },
        {
            id: '3',
            visitName: 'Visit 4',
            visitDate: '2022-04-18T11:16:47.000+0000',
            visitDuration: '30 minutes',
            visitAttendees: 'Mike Tyson (PI)'
        },
        {
            id: '4',
            visitName: 'Visit 5',
            visitDate: '2022-04-18T11:16:47.000+0000',
            visitDuration: '30 minutes',
            visitAttendees: 'Mike Tyson (PI)'
        }
    ];
    isInitialized = true;
    timeZone = TIMEZONE;
    entriesOnPage = 4;
    pageNumber = 1;
    allRecordsCount = 5;
    teleVisitsToDisplay = [];

    /*connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                this.isMobileApp = communityService.isMobileSDK();
                this.isMobileScreen = communityService.isMobileOS();
                this.isRTL = this.labels.RTL_Languages.contains(communityService.getLanguage());
                this.isInitialized = true;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading RR_COMMUNITY_JS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }*/
    get containerClass() {
        return 'tv-body' + (this.isInitialized ? '' : 'hidden');
    }

    get titleClass() {
        return 'tv-title' + (this.isRTL === true ? ' tile-rtl' : '');
    }
    get filterLabel() {
        return this.labels.FILTER_LABEL;
    }
    handlePaginatorChanges(event) {
        this.teleVisitsToDisplay = event.detail;
        //this.rowNumberOffset = this.teleVisitsToDisplay[0].rowNumber - 1;
    }
}
