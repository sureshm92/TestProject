import { LightningElement, api, wire } from "lwc";
import getInitData from '@salesforce/apex/ReferHealthcareProviderRemote.getInitData';
import getParticipantData from '@salesforce/apex/PIR_SharingOptionsController.fetchParticipantData';

export default class Pir_sharingOption extends LightningElement {
    
    value = [];
    datafetchsuccess = false;
    get options() {
        return [
            { label: '2022', value: '2022' },
            { label: '2021', value: '2021' },
            { label: '2020', value: '2020' },
            { label: '2019', value: '2019' },
          
        ];
    }
    handleChange(e) {
        this.value = e.detail.value;
    }
    @api selectedPE;
    healthcareProviders = [];
    delegates = [];
    yob = [];
    loading = false;
    participantObject;
    isHCPDelegates;
    isAddDelegates;
    yobOptions=[];
    

    connectedCallback(){
        this.fetchInitialDetails();
    }

    @api
    fetchInitialDetails() {  
        this.resetFormElements();
        this.getParticipantDetails();
    }

    resetFormElements() {
        this.delegates = [];    
        this.healthcareProviders=[];
        this.isAddDelegates = false;
        this.ishcpAddDelegates = false;
        this.yob=[];
    }

    getParticipantDetails() {
        if(!this.loading) {
            this.loading = true;
        }
        getParticipantData({perId:this.selectedPE.id})
            .then((result) => {
                this.participantObject = result;
                this.getInitialData();
                this.loading = false;
                
            })
            .catch((error) => {
                console.log(error);
                this.loading = false;
            });
    }

    getInitialData() {
        if(!this.loading) {
            this.loading = true;
        }
        getInitData({ peId: this.selectedPE.id, participantId: this.selectedPE.participantId })
        .then((result) => {
            let hcp = result.healthcareProviders;
            for (let i = 0; i < hcp.length; i++) {
                hcp[i].sObjectType = 'Healthcare_Provider__c';
            }
            let del = result.listWrapp;
            for (let i = 0; i < del.length; i++) {
                del[i].sObjectType = 'Object';
            }
            this.delegates = del;
            this.isAddDelegates = true;
            this.healthcareProviders = hcp;
            this.ishcpAddDelegates = true;
            this.yob = result.yearOfBirth;
        })
        .catch((error) => {
            console.log(error);
            this.loading = false;
        });
    }

    editYob() {
       
        if(this.yob) {
            let options = [];
            for(let option in this.yob){
                options.push({ label: this.yob[option].label, value: this.yob[option].value });
            }
            this.yobOptions = options;
        }

    }

    refreshDelegates() {
        this.fetchInitialDetails();

    }
    


}