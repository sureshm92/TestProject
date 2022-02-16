import { LightningElement,api } from 'lwc';
import getRelatedMediaFiles from '@salesforce/apex/BioMarkerRecordController.getRelatedMediaFiles';
import Biomarker_Media_Player from "@salesforce/label/c.Biomarker_Media_Player";
import Media_file_Header from "@salesforce/label/c.Media_file_Header";

export default class MediaFile extends LightningElement {
    label = {
        Media_file_Header,
        Biomarker_Media_Player
    }
    @api AssesedDate;
    mediaFiles;
    showModal = false;
    mediaFile;
    @api recordId;
    showTable = true;
    
    @api
    fileRecords(recordId,AssesedDate){
        getRelatedMediaFiles({perId: recordId,AssesedDate: AssesedDate})
        .then(result => {
            this.mediaFiles = result;
            console.log(AssesedDate);
            if(this.mediaFiles.length == 0){
                this.showTable = false;
            }
            else{
                this.showTable = true;
            }
        })
        .catch(error => {
            console.log(error.message);
        });
    }

    playFile(event){
        var urlMap =  event.target.dataset.value;
        this.mediaFiles.forEach(item => {
            if(item.url == urlMap){
                this.mediaFile = item;
            }
        });
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.mediaFile = null;
    }
}