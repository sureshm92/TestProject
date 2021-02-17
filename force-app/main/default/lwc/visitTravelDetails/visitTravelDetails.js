import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import rrCommunityJs from '@salesforce/resourceUrl/rr_community_js';
import getTravelDetails from '@salesforce/apex/TravelSupportRemote.getTravelVendors';
import getTravelVendors from '@salesforce/apex/TravelSupportRemote.getAvailableVendorsForSS';
import addNewBooking from '@salesforce/label/c.Home_Page_StudyVisit_Btn';
import bookingStatus from '@salesforce/label/c.Home_Page_Travel_Support_Booking_Status_Col';
import action from '@salesforce/label/c.Home_Page_Travel_Support_Action_Col';
import bookingDate from '@salesforce/label/c.PP_Travel_Date';
import bookingTime from '@salesforce/label/c.PP_Travel_Time';
import travelSupport from '@salesforce/label/c.PP_Travel_Support';

export default class VisitTravelDetails extends LightningElement {
    labels = {
        addNewBooking,
        bookingStatus,
        action,
        bookingDate,
        bookingTime,
        travelSupport
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
            .catch((error) => {
                console.log('error');
            });

        this.handleLoad();
        this.getTravelVendorsDetails();
    }

    handleLoad() {
        getTravelDetails({ clientId: '12345', clientSecret: '12345', isHomePage: false })
            .then((result) => {
                console.log('travelWrapper', result);
                this.travelWrapper = result;
                this.constructBookingData(this.travelWrapper);
            })
            .catch((error) => {
                this.error = error;
            });
    }

    getTravelVendorsDetails() {
        getTravelVendors()
            .then((result) => {
                console.log('travelVendors', result);
                this.vendors = result;
                this.showVendors = result.length != 0;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    constructBookingData(travelData) {
        console.log('inside booking data-->', travelData);
        this.bookingDetails = travelData;
        console.log('bookingDetails:1' + JSON.stringify(this.bookingDetails));
        for (let i = 0; i < this.bookingDetails.length; i++) {
            if (
                this.bookingDetails[i].visitName == this.vname &&
                this.bookingDetails[i].visitId == this.vnum
            ) {
                this.travelDetails.push(this.bookingDetails[i]);
            }
        }
        console.log('travelDetails-->', travelDetails);
    }
}
