import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import rrCommunityJs from '@salesforce/resourceUrl/rr_community_js';
import getTravelDetails from '@salesforce/apex/TravelSupportRemote.getTravelVendors';
import getTravelVendors from '@salesforce/apex/TravelSupportRemote.getAvailableVendorsForSS';
import addNewBooking from '@salesforce/label/c.Home_Page_StudyVisit_Btn';
import bookingStatus from '@salesforce/label/c.PP_Travel_Status';
import bookingTitle from '@salesforce/label/c.PP_Travel_Booking';
import action from '@salesforce/label/c.Home_Page_Travel_Support_Action_Col';
import bookingDate from '@salesforce/label/c.PP_Travel_Date';
import bookingTime from '@salesforce/label/c.PP_Travel_Time';
import travelSupport from '@salesforce/label/c.PP_Travel_Support';
import noTravelInfo from '@salesforce/label/c.No_Travel_Information';

export default class VisitTravelDetails extends LightningElement {
    labels = {
        addNewBooking,
        bookingStatus,
        action,
        bookingDate,
        bookingTime,
        travelSupport,
        noTravelInfo,
        bookingTitle
    };

    @track travelWrapper = [];
    @track currentTravels;
    @track initialized = false;
    @track travelMode = 'All';
    @track options;
    @track vendors;
    @track externalLinkDisclaimer;
    @api visitName;
    @api visitNumber;
    @api vname;
    @api vnum;
    @track bookingDetails = [];
    @track travelDetails = [];
    @track showVendors = false;
    @track noTravelInformation = false;
    @api isrtl;
    @track travelDetailsClass = 'travel-support slds-float_left slds-col slds-size_1-of-2';
    @track addNewClass = 'slds-col slds-size_1-of-2';
    @track noTravelClass = 'no-travels-message';
    connectedCallback() {
        console.log('visitName-->' + this.vname);
        console.log('visitNumber-->' + this.vnum);
        Promise.all([
            loadScript(this, rrCommunityJs)
            // loadStyle(this, D3 + '/style.css')
        ])
            .then(() => {
                console.log('inside js loaded-->');
            })
            .catch(error => {
                console.log('error');
            });
        if (this.isrtl) {
            this.addNewClass = 'slds-col slds-size_1-of-2 mr_rtl';
            this.noTravelClass = 'no-travels-message_rtl';
            this.travelDetailsClass =
                'travel-support slds-float_left slds-col slds-size_1-of-2 tsRtl';
        } else {
            this.addNewClass = 'slds-col slds-size_1-of-2 mr';
            this.noTravelClass = 'no-travels-message';
        }

        this.handleLoad();
        this.getTravelVendorsDetails();
    }

    handleLoad() {
        getTravelDetails({ clientId: '12345', clientSecret: '12345', isHomePage: false })
            .then(result => {
                console.log('result', result);
                this.travelWrapper = result;
                console.log('travelWrapper' + JSON.stringify(this.travelWrapper));
                this.constructBookingData(this.travelWrapper);
            })
            .catch(error => {
                this.error = error;
            });
    }

    getTravelVendorsDetails() {
        getTravelVendors()
            .then(result => {
                console.log('travelVendors', result);
                this.vendors = result;
                this.showVendors = result.length != 0;
                const lwcEvent = new CustomEvent('hasVendors', {
                    detail: { showVendors: this.showVendors }
                });
                this.dispatchEvent(lwcEvent);
            })
            .catch(error => {
                this.error = error;
            });
    }

    constructBookingData(travelData) {
        this.bookingDetails = travelData;
        console.log('travelData' + JSON.stringify(travelData));
        console.log(this.vname);
        console.log(this.vnum);
        console.log('bookingDetails--' + JSON.stringify(this.bookingDetails));
        for (let i = 0; i < this.bookingDetails.length; i++) {
            if (
                this.bookingDetails[i].visitName == this.vname &&
                this.bookingDetails[i].visitId == this.vnum
            ) {
                console.log('inside if condition-->');
                this.travelDetails.push(this.bookingDetails[i]);
            }
            console.log('travelDetails ', this.travelDetails);
        }
        this.noTravelInformation = this.travelDetails.length === 0;
    }
}
