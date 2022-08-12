import { LightningElement, api, track } from 'lwc';
import fetchSites from '@salesforce/apex/rh_siteBirthdateConfigController.fetchSites';
import updateDobOnSites from '@salesforce/apex/rh_siteBirthdateConfigController.updateDobOnSites';
import { NavigationMixin } from 'lightning/navigation';
import selectAll from '@salesforce/label/c.Select_All_PI';
import selectCountry from '@salesforce/label/c.RH_RP_Select_Country';
import selectStudySite from '@salesforce/label/c.TS_Select_Study_Site';
import selectDobFormat from '@salesforce/label/c.RH_Dob_Format_Search';

const sortField = {};
sortField.isCountry = false;
sortField.isSSName = true;
sortField.isSSNumber = false;

const dobFormat = [{id: "DD-MM-YYYY", value: "DD-MM-YYYY", icon: 'standard:task2'},
{id: "MM-YYYY", value: "MM-YYYY", icon: 'standard:task2'},
{id: "YYYY", value: "YYYY", icon: 'standard:task2'}];

export default class Rh_siteBirthdateConfig extends NavigationMixin(LightningElement) {
    @api recordId;
    @track studySites=[];
    @track studiesToDisplay = [];
    totalStudyCount = 0;
    showpagenation = false;
    isSortAsc = true;
    sortBy = 'Name';
    isLoading = true;
    @track sortField = sortField;
    initialLoad = true;
    dobFormats = dobFormat;
    allCountryNames = [];
    allStudySitesNames = [];
    @track dobFormatOptions = dobFormat;
    @track countryOptions = [];
    @track studySiteOptions = [];
    selectedSites = [];
    selectedCountry = [];
    selectedFormats = [];
    connectedCallback() {
        this.fetchSites(this.recordId,'ASC',this.sortBy);   
    }

    fetchSites(studyId,sortOrder,sortBy,studySiteIds,countryNames,dateFormats){
        this.studySites = [];
        fetchSites({ studyId: studyId,
            sortOrder : sortOrder,
            sortBy : sortBy,
            studySiteIds: studySiteIds,
            countryNames : countryNames,
            dateFormats : dateFormats })
        .then(result => {
            this.isLoading = true;
            this.studiesToDisplay = result;
            let billingCountries = new Map();
            for(var res in result) {
                result[res].ddmmyyy = 'DD-MM-YYYY'==result[res].Participant_DOB_format__c;
                result[res].mmyyy = 'MM-YYYY'==result[res].Participant_DOB_format__c;
                result[res].yyyy = 'YYYY'==result[res].Participant_DOB_format__c;
                this.studySites.push(result[res]);

               if(this.initialLoad){
                    let ssName = {id: result[res].Id, value:result[res].Name, icon:'standard:task2'};
                    this.studySiteOptions.push(ssName);
                    this.allStudySitesNames.push(ssName);
                    billingCountries.set(result[res].Site__r.BillingCountry,result[res].Site__r.BillingCountry);
               }

            }
            if(this.initialLoad){
                for (const cName of billingCountries.keys()) {
                    let countryDetail = {id: cName, value:cName, icon:'standard:task2'};
                    this.allCountryNames.push(countryDetail);
                }
                this.countryOptions = this.allCountryNames;
            }
            this.totalStudyCount = this.studySites.length;
            this.showpagenation = (this.totalStudyCount > 0);
            this.isLoading = false;
            this.initialLoad = false;
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
        this.sortBy = event.target.dataset.sortby;
        this.showpagenation = false;
        this.fetchSites(this.recordId,(this.isSortAsc ? 'ASC' : 'DESC'), this.sortBy , this.selectedSites, this.selectedCountry, this.selectedFormats);
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

    handleCountryChange(event){
        this.isLoading = true;
        let details = event.detail;
        this.selectedCountry = [];
        this.countryOptions = [];
        let modifiedOptions = [];
        for(let i=0; i<details.length; i++){
            this.selectedCountry.push(details[i].value);
        }
        for(let i=0; i<this.allCountryNames.length; i++){
            if(this.selectedCountry.indexOf(this.allCountryNames[i].id) == -1){
                modifiedOptions.push(this.allCountryNames[i]);
            }
        }
        this.showpagenation = false;
        this.fetchSites(this.recordId,(this.isSortAsc ? 'ASC' : 'DESC'), this.sortBy , this.selectedSites, this.selectedCountry, this.selectedFormats);
        this.countryOptions = modifiedOptions;
    }

    handleSSChange(event){
        this.isLoading = true;
        let details = event.detail;
        this.selectedSites = [];
        let modifiedSSOptions = [];
        this.studySiteOptions = [];
        for(let i=0; i<details.length; i++){
            this.selectedSites.push(details[i].id);
        }
        for(let i=0; i<this.allStudySitesNames.length; i++){
            if(this.selectedSites.indexOf(this.allStudySitesNames[i].id) == -1){
                modifiedSSOptions.push(this.allStudySitesNames[i]);
            }
        }
        this.showpagenation = false;
        this.fetchSites(this.recordId,(this.isSortAsc ? 'ASC' : 'DESC'), this.sortBy , this.selectedSites, this.selectedCountry, this.selectedFormats);
        this.studySiteOptions = modifiedSSOptions;
    }

    handleFormatChange(event){
        this.isLoading = true;
        let details = event.detail;
        this.selectedFormats = [];
        let modifiedOptions = [];
        this.dobFormatOptions = [];
        for(let i=0; i<details.length; i++){
            this.selectedFormats.push(details[i].id);
        }
        for(let i=0; i<this.dobFormats.length; i++){
            if(this.selectedFormats.indexOf(this.dobFormats[i].id) == -1){
                modifiedOptions.push(this.dobFormats[i]);
            }
        }
        this.showpagenation = false;
        this.fetchSites(this.recordId,(this.isSortAsc ? 'ASC' : 'DESC'), this.sortBy , this.selectedSites, this.selectedCountry, this.selectedFormats);
        this.dobFormatOptions = modifiedOptions;
    }

    get sortIcon(){
        return (this.isSortAsc ?  'utility:arrowup' : 'utility:arrowdown' );
    }

    label = {
        selectAll,
        selectCountry,
        selectStudySite,
        selectDobFormat
    };
}