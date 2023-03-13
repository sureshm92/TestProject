import { LightningElement,track, api } from 'lwc';
import My_Image from '@salesforce/resourceUrl/MRRImage';
import MRRHeader from '@salesforce/label/c.Medical_Record_Retrieval';
import Select from '@salesforce/label/c.Select';
import RHManageAuth from '@salesforce/label/c.RH_Manage_Auth_Disclaimer';
import ExternalLink from '@salesforce/label/c.RH_External_Link_Disclaimer';
import externalLink1 from '@salesforce/label/c.RH_External_Link_Disclaimer1';
import HAPI_Provider from '@salesforce/label/c.HAPI_Provider';
import Manage_Authorization from '@salesforce/label/c.Manage_Authorization';
import HAPI_Start_Loading from '@salesforce/label/c.HAPI_Start_Loading';
import humanapijs from '@salesforce/resourceUrl/humanapijs';
import {loadScript } from 'lightning/platformResourceLoader';
import getSessionToken from '@salesforce/apex/MedicalRecordAccessRemote.getSessionToken';
import getAccessToken from '@salesforce/apex/MedicalRecordAccessRemote.getAccessToken';
import getStudyProviderList from '@salesforce/apex/MedicalRecordAccessRemote.getStudyProviderList';
import getHumanSourcesList from '@salesforce/apex/MedicalRecordAccessRemote.getHumanSourcesList';
import getHumanAPIAlunmiPastPEListRevamp from '@salesforce/apex/MedicalRecordAccessRemote.getHumanAPIAlunmiPastPEListRevamp';

export default class PpMedicalRecordRetrievalPanel extends LightningElement {
    MRRImage = My_Image;
    label={
        MRRHeader,
        Select,
        RHManageAuth,
        ExternalLink,
        externalLink1,
        HAPI_Provider,
        Manage_Authorization,
        HAPI_Start_Loading
    };
    @api participantState;
    peId;
    defaultStudy;
    isHumanApiChecked;
    initialized=false;
    sessionToken;
    humanid;
    accessToken;
    success;
    @track medicalProviders = [];
    @track referrals = [];
    showMedicalCard = false;
    isDelegatet = false;
    externalLinkDisclaimer;
    obj;
    communityService;
    returnValue;
    referralId;
    isHumanApiVendorChecked;
    token;
    @track studyProviders= [];
    innerspinner = false;
    showspinner = true;

    connectedCallback(){
        Promise.all([
            loadScript(this,humanapijs)
        ]).then(() => {
           this.initialize();
            //
        }).catch((error)=>{
            this.showspinner = false;
            console.error('error in load:'+JSON.stringify(error));
        })
    }
    initialize(){
        getHumanAPIAlunmiPastPEListRevamp()
                .then(response =>{
                    this.returnValue = response;
                    this.referrals = this.returnValue.referrals;
                    console.log('referrals:'+ response.participantState);
                    this.populateDisclaimerText(this.returnValue.communityName);
                    this.participantState = JSON.parse(this.returnValue.participantState);
                    if(this.referrals.length > 0){
                        let currentPe = this.participantState.pe ? this.participantState.pe.Id : null;
                        return getStudyProviderList({itemstr : JSON.stringify(this.referrals),peId : currentPe})
                    }
                    return false;
                })
                .then(response =>{
                    console.log('in promise 2');
                    this.studyProviders = response;
                    if(this.studyProviders.length > 0){
                        this.medicalProviders = this.studyProviders[0].providers;
                        this.defaultStudy = this.studyProviders[0].value;
                        this.initialized = true;

                    }
                    this.showspinner = false;
                    
                })
                .catch(error=>{
                    this.showspinner = false;
                    console.log('Error'+JSON.stringify(error));
                }); 
          
    }

    populateDisclaimerText(communityName){
        if (communityName !== null) {
            let disclaimerText =
                this.label.RHManageAuth +
                ' ' +
                this.label.ExternalLink +
                ' ' +
                this.communityName +
                ' ' +
                this.label.externalLink1;
            this.externalLinkDisclaimer = disclaimerText ;
            
        }
    }



    manageSources(){
        this.calloutSession(this.defaultStudy);
    }

    doListProviders(event){
        this.defaultStudy = event.target.value;
        let itemIndex  = this.studyProviders.findIndex( item => this.defaultStudy === item.value );
        this.medicalProviders = this.studyProviders[itemIndex].providers;
    }
    
    listProvidersChange(){
        this.calloutAccessToken(this.defaultStudy);
    }

    calloutSession(referralId){
        var self = this;
        getSessionToken({referralId: referralId}).then(response=>{
            console.log('callout response:'+JSON.stringify(response));
            let returnValue = response;
            if(returnValue){
                this.humanid = returnValue.humanId;
                this.sessionToken = returnValue.id_token;
                self.launchConnect();
            }
        })
    }
    
    calloutAccessToken(referralId) {
            getAccessToken({referralId: referralId}).then(response=> {
                    this.returnValue = response;
                    if(this.returnValue){
                        this.accessToken = this.returnValue;
                        
                        this.listProviders(referralId);
                    }
                }).catch(error=>{
                    console.log('error:'+JSON.stringify(error));
                });             

    }

    listProviders(referralId) {  
        var obj = this.participantState; 
        getHumanSourcesList({referralId:referralId}).then(response=>{
            this.returnValue=response;
            if(this.returnValue) {               
                console.log('returned providers:'+JSON.stringify(this.returnValue));
                this.medicalProviders = this.returnValue;  
               
                if(this.studyProviders.length >0){
                    if(this.returnValue.length === 0 && ((obj.pe && !this.defaultStudy.includes(obj.pe.Id)) || !obj.pe)){
                        let itemIndex =  this.studyProviders.findIndex( item => this.defaultStudy === item.value );
                        if(itemIndex != -1){
                            console.log('item getting spliced');
                            this.studyProviders.splice(itemIndex,1);
                            this.defaultStudy =  this.studyProviders.length >0 ? this.studyProviders[0].value : '';
                            this.medicalProviders =this.studyProviders.length >0 ? this.studyProviders[0].providers : [];   
                        }
                       
                        if(this.pastStudiesVisibility === true){
                            this.template.querySelector('lightning-combobox').options = this.studyProviders;
                        }
                    }
                    else{
                        let itemIndex  = this.studyProviders.findIndex( item => this.defaultStudy === item.value );
                        this.studyProviders[itemIndex].providers = this.returnValue;
                    }
                   // this.showMedicalCard = true;
                    
                } 
                

               if(obj.value !== 'ALUMNI'){
                    if(obj.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c){
                        if(this.isHumanApiChecked){
                            this.showMedicalCard = true;
                        }
                        else {
                            if(this.isAuthorised && obj.pe.Human_Id__c){
                                this.showMedicalCard =true;
                            }
                        }
                    }
                } 
                this.showspinner = false;
                this.innerspinner  = false;
                this.initialized = true;
            }
        })   
    }
    
    launchConnect() {
        var self = this;
        HumanConnect.open({
            token : this.sessionToken,
            onClose(response) {
                var results = response.sessionResults;
                self.success = results.connectedSources;
                self.innerspinner  = true;
                self.calloutAccessToken(self.defaultStudy);
            },
            onConnectSource(response) {
               var results = response.sessionResults;
                self.success = results.connectedSources;
                self.calloutAccessToken(self.defaultStudy);   
            },
            onDisconnectSource(response) {
               var results = response.sessionResults;
                self.success = results.connectedSources; 
                //self.calloutAccessToken(self.defaultStudy);
                
            }
        });
        
    }
    get medicalCard(){
        var cardCheck = (this.showMedicalCard || this.studyProviders.length >0)
        return cardCheck;
    }

    get pastStudiesVisibility(){
        return this.studyProviders.length > 1
    }
    set updatedProviders(val){
        this.calloutAccessToken(this.defaultStudy);
    }
    get isAuthorised(){
         return this.medicalProviders.length > 0
    }
    get showEmptySpace(){
        return (!this.isAuthorised && this.initialized);
    }
    get authorisedVisibility(){
        return (this.medicalCard && this.initialized);
    }

}