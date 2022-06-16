import { LightningElement, api, wire } from "lwc";
import getInitData from '@salesforce/apex/ReferHealthcareProviderRemote.getInitData';
import getParticipantData from '@salesforce/apex/PIR_SharingOptionsController.fetchParticipantData';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import MessageForDelegates from '@salesforce/label/c.Message_For_Delegates';
import MessageForDelegatesJansen from '@salesforce/label/c.Message_For_Delegates_Jansen';
import MessageForProviders from '@salesforce/label/c.Message_For_Providers';
import OtherProvidersHeader from '@salesforce/label/c.Other_Providers';
import DelegatesHeader from '@salesforce/label/c.Delegates';
import ReferringProviderHeader from '@salesforce/label/c.Referring_Provider';
import updatePerRecord from '@salesforce/apex/PIR_SharingOptionsController.updatePerRecord';
export default class Pir_sharingOption extends LightningElement {
    
    value = [];
    datafetchsuccess = false;
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
    rpList = [];
    communityTemplate;
    isDisplayProviders = true;    
    @api delegateLevel;
    delegateLabel;
    @api isrtl = false;
    maindivcls;
    
    label = {
        MessageForDelegates,
        MessageForDelegatesJansen,
        MessageForProviders,
        OtherProvidersHeader,
        DelegatesHeader,
        ReferringProviderHeader
    }

    connectedCallback(){
        if(this.isrtl){
            this.maindivcls = 'rtl';
        } else {
            this.maindivcls = 'ltr';
        }
        
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
            if(this.communityTemplate != 'Janssen') {
                this.delegateLabel = this.label.MessageForDelegates;
            }else {
                this.delegateLabel = this.label.MessageForDelegatesJansen;

            }
        }).catch((error) => {
             console.log('Error: ' + error);
        });
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
        this.rpList = [];
        this.isrpContact = false;
        this.yob=[];
    }

    getCommunityInfo() {
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
            if(this.communityTemplate != 'Janssen') {
                this.delegateLabel = this.label.MessageForDelegates;
            }else {
                this.delegateLabel = this.label.MessageForDelegatesJansen;

            }
        }).catch((error) => {
             console.log('Error: ' + error);
        });
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
            if(this.communityTemplate != 'Janssen') {
                this.isDisplayProviders = true;
            } else {
                this.isDisplayProviders = false;
            }
            if(this.participantObject.HCP__r) {
                let obj = {};
                let mergedObj = {};
                obj = {"sObjectType": 'Contact'};
                mergedObj = { ...this.participantObject.HCP__r.HCP_Contact__r, ...obj };
                this.rpList.push(mergedObj);
                this.isrpContact = true;
                console.log('this.rpList:'+JSON.stringify(this.rpList));
            } 
        })
        .catch((error) => {
            console.log(error);
            this.loading = false;
        });
    }
    refreshDelegates() {
        this.fetchInitialDetails();

    }
    fetchAccessLevel() {
        if(this.studyAccess && this.participantObject) {
            let studyId = this.participantObject.Study_Site__c;
            for (var key in this.studyAccess) {
                if (this.studyAccess.hasOwnProperty(key) && key === studyId) {
                    this.delegateLevel = this.studyAccess[key];
                    console.log(this.delegateLevel);
                }
            }
            
        }
    }
    updatePer() {
        updatePerRecord({ perId: this.selectedPE.id })        
        .then((result) => {
            //'per updated successfully
            
        })
        .catch((error) => {
            console.log('Update Per Error'+error);
        });

    }
    


}