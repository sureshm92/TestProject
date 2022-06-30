import { LightningElement, api, track } from 'lwc';
import fetchSites from '@salesforce/apex/rh_siteBirthdateConfigController.fetchSites';
import updateDobOnSites from '@salesforce/apex/rh_siteBirthdateConfigController.updateDobOnSites';
import { NavigationMixin } from 'lightning/navigation';
import selectAll from '@salesforce/label/c.Select_All_PI';

const sortField = {};
sortField.isCountry = false;
sortField.isSSName = true;
sortField.isSSNumber = false;

export default class Rh_siteBirthdateConfig extends NavigationMixin(LightningElement) {
    @api recordId;
    @track studySites=[];
    studiesToDisplay = [];
    totalStudyCount = 0;
    showpagenation = false;
    isSortAsc = true;
    isLoading = true;
    @track sortField = sortField;

    connectedCallback() {
        this.fetchSites(this.recordId,'ASC','Name');        
    }

    fetchSites(studyId,sortOrder,sortBy){
        this.studySites = [];
        fetchSites({ studyId: studyId,
            sortOrder : sortOrder,
            sortBy : sortBy })
        .then(result => {
            this.studiesToDisplay = result;
            for(var res in result) {
                result[res].ddmmyyy = 'DD-MM-YYYY'==result[res].Participant_DOB_format__c;
                result[res].mmyyy = 'MM-YYYY'==result[res].Participant_DOB_format__c;
                result[res].yyyy = 'YYYY'==result[res].Participant_DOB_format__c;
                this.studySites.push(result[res]);
            }
            this.totalStudyCount = this.studySites.length;
            this.showpagenation = (this.totalStudyCount > 0);
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            console.log('err:'+error.message);
        });
    }

    updateSite(event){
        this.isLoading = true;
        var studySite = {};
        for(var res in this.studySites) {
            if(this.studySites[res].Id == event.target.dataset.site){
                this.studySites[res].Participant_DOB_format__c =event.target.dataset.label;
                this.studySites[res].ddmmyyy = 'DD-MM-YYYY'== event.target.dataset.label;
                this.studySites[res].mmyyy = 'MM-YYYY'== event.target.dataset.label;
                this.studySites[res].yyyy = 'YYYY'== event.target.dataset.label;
                studySite =  this.studySites[res];
                break;
            }
        }
        var sitesToUpdate = [];
        sitesToUpdate.push(studySite);
        updateDobOnSites({ updateSites: sitesToUpdate })
        .then(result => {
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            console.log('err:'+error.message);
        });        
    }

    handleSelectAll(event){
        if(this.totalStudyCount>0){
            this.isLoading = true;
            for(var res in this.studySites) {
                this.studySites[res].Participant_DOB_format__c = event.target.dataset.label;
                this.studySites[res].ddmmyyy = 'DD-MM-YYYY'==this.studySites[res].Participant_DOB_format__c;
                this.studySites[res].mmyyy = 'MM-YYYY'==this.studySites[res].Participant_DOB_format__c;
                this.studySites[res].yyyy = 'YYYY'==this.studySites[res].Participant_DOB_format__c;
            }
            this.updateSites();
        }
    }

    updateSites(){
        updateDobOnSites({ updateSites: this.studySites })
        .then(result => {
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = true;
            this.error = error;
            console.log('err:'+error.message);
        });
    }

    handlePaginatorChanges(event){
        this.studiesToDisplay = event.detail;
    }
    
    handleSort(event){
        this.isLoading = true;
        this.isSortAsc = !(this.isSortAsc);
        this.sortField.isCountry = event.target.dataset.sortby == 'Country';
        this.sortField.isSSName = event.target.dataset.sortby == 'SSName';
        this.sortField.isSSNumber = event.target.dataset.sortby == 'SSNumber';
        this.showpagenation = false;
        this.fetchSites(this.recordId,(this.isSortAsc ? 'ASC' : 'DESC'),event.target.dataset.sortby);
        this.isLoading = false;
    }

    openSS(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.siteid,
                objectApiName: 'Study_Site__c', 
                actionName: 'view'
            }
        });
    }

    get sortIcon(){
        return (this.isSortAsc ?  'utility:arrowup' : 'utility:arrowdown' );
    }

    label = {
        selectAll
    };
}