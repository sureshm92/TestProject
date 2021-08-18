import { LightningElement,track,wire } from 'lwc';
import getPEDetails from '@salesforce/apex/RPRecordReviewLogController.getPEDetails';
import community_icon from '@salesforce/resourceUrl/rr_community_icons';
export default class RP_NonReferredTable extends LightningElement {

    @track data = [];
    @track error;
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track isModalOpen = false;
    //get icons from static resource to be displayed on the page
    refresh_icon = community_icon + '/refresh.png';

    // Getting PE using Wire Service
    @wire(getPEDetails)
    contacts(result) {
        if (result.data) {
            this.data = result.data;
            this.recordsToDisplay = result.data;
            this.error = undefined; 
            this.showTable = true;

        } else if (result.error) {
            this.error = result.error;
            alert(JSON.stringify(this.error));
            this.data = undefined;
        }
    }
    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }
    
    // Select the all rows
    allRowSelected(event) {

    }

    //Open model for refresh
    openModal() {
        this.isModalOpen = true;
    }
    //close model for refresh
    closeModal() {
        this.isModalOpen = false;
    }
    //Refresh page
    refreshComponent(event){
        eval("$A.get('e.force:refreshView').fire();");
    }
}