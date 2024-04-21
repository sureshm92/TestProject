import { LightningElement,track, api } from 'lwc';
import My_Image from '@salesforce/resourceUrl/MRRImage';
import MRRHeader from '@salesforce/label/c.Medical_Record_Retrieval';
import Select from '@salesforce/label/c.Select';
import RHManageAuth from '@salesforce/label/c.HAPI_Helptext';
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
    participantState;
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
    participantPresent = false;

    connectedCallback(){
       //load human API JS and then initialize component data
        Promise.all([
            loadScript(this,humanapijs)
        ]).then(() => {
           this.initialize();
            //
        }).catch((error)=>{
            this.innerspinner  = false;
            this.showspinner = false;
            console.error('error in load:'+JSON.stringify(error));
        })
    }


    initialize(){
        //method responsible to fetch possible past studies
        getHumanAPIAlunmiPastPEListRevamp()
                .then(response =>{
                    this.returnValue = response;
                    this.referrals = this.returnValue.referrals;
                   // this.populateDisclaimerText(this.returnValue.communityName);
                    this.peId = this.returnValue.currentPerId;
                    this.participantState = this.returnValue.currentPerStatus;
                    this.participantPresent = this.returnValue.iscurrentPresent;
                    if(this.referrals.length > 0 ){
                        if(this.participantPresent){
                            this.innerspinner = true;
                            this.sendloadinfoParent('successload');
                        }                      
                        //method responsible to fetch studies providers from HAPI.
                        return getStudyProviderList({itemstr : JSON.stringify(this.referrals),
                                                     peId : this.peId,
                                                     status : this.participantState});
                    }
                    return false;
                })
                .then(response =>{
                    this.studyProviders = response;
                    if(this.studyProviders.length > 0){
                        if(!this.participantPresent){
                            this.sendloadinfoParent('successload');
                        }
                        this.innerspinner = false;
                        this.medicalProviders = this.studyProviders[0].providers;
                        this.defaultStudy = this.studyProviders[0].value;
                        this.initialized = true;
                    
                    }
                    this.showspinner = false;
                    
                })
                .catch(error=>{
                    this.innerspinner = false;
                    this.showspinner = false;
                    console.log('Error'+JSON.stringify(error));
                }); 
          
    }

    sendloadinfoParent(eventname){
        const custEvent = new CustomEvent(
            eventname, {detail:'MedicalRecordRetrieval'});
        this.dispatchEvent(custEvent);
    }

    populateDisclaimerText(communityName){
        if (communityName !== null) {
            let disclaimerText =
                this.label.RHManageAuth +
                ' ' +
                this.label.ExternalLink +
                ' ' +
                communityName +
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

    //this method is used to call HAPI UI
    calloutSession(referralId){
        var self = this;
        getSessionToken({referralId: referralId}).then(response=>{
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

    // this method is used to fetch ondemand providers for study
    listProviders(referralId) {  

        getHumanSourcesList({referralId:referralId}).then(response=>{
            this.returnValue=response;
            if(this.returnValue) {               
                this.medicalProviders = this.returnValue;  
                if(this.studyProviders.length >0){
                    if(this.returnValue.length === 0 && ((this.peId && !this.defaultStudy.includes(this.peId)) || this.participantState === 'ALUMINI')){
                        let itemIndex =  this.studyProviders.findIndex( item => this.defaultStudy === item.value );
                        if(itemIndex != -1){
                            this.studyProviders.splice(itemIndex,1);
                            this.defaultStudy =  this.studyProviders.length >0 ? this.studyProviders[0].value : '';
                            this.medicalProviders =this.studyProviders.length >0 ? this.studyProviders[0].providers : [];   
                            if(this.studyProviders.length == 0){
                                this.sendloadinfoParent('cardremove');
                            }
                        }
                       
                        if(this.pastStudiesVisibility === true){
                            this.template.querySelector('lightning-combobox').options = this.studyProviders;
                        }
                    }
                    else{
                        let itemIndex  = this.studyProviders.findIndex( item => this.defaultStudy === item.value );
                        this.studyProviders[itemIndex].providers = this.returnValue;
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
        var cardCheck = (this.participantPresent || this.studyProviders.length >0)
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

    showHideInfo(event){
        let name = event.type;
        if(name === 'mouseover'){
            this.template.querySelector('div.info-tooltip_position').classList.remove('slds-hide');
        }
        else if(name === 'mouseleave'){
            this.template.querySelector('div.info-tooltip_position').classList.add('slds-hide');

        }
    }

}