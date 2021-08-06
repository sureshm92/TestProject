import { LightningElement, api, track } from 'lwc';
import getFiles from '@salesforce/apex/FileContainer.getFiles';

export default class RPRevamp extends LightningElement {

    @api recordId;
    isloading;
    @track fileList;
    renderTable = false;

    fileList = [
        {
            Id: 1,
            fileName: 'testing1',
            initialTotalRecords: '200',
            accepted: '150',
            rejected: '50',
            uploadedBy: 'Sumit S',
            uploadedOn: '02/08/2021',
            action: 'Download',

        },
        {
            Id: 2,
            fileName: 'testing2',
            initialTotalRecords: '200',
            accepted: '180',
            rejected: '20',
            uploadedBy: 'Sumit S',
            uploadedOn: '02/08/2021',
            action: 'Download',
        },
        {
            Id: 3,
            fileName: 'testing2',
            initialTotalRecords: '300',
            accepted: '300',
            rejected: '00',
            uploadedBy: 'Sumit S',
            uploadedOn: '02/08/2021',
            action: 'Download',
        },
    ];

    /*
    connectedCallback() {
        this.isLoading = true;
        getFiles()
            .then(result => {
                this.fileList = result;
                if (this.fileList.length === 0) {
                    this.renderTable = false;
                }
                else {
                    this.renderTable = true;
                }
            })
            this.isLoading = false;
    }
    */
}