import { LightningElement,api,wire } from 'lwc';
import cometdStaticResource from '@salesforce/resourceUrl/cometd';
import { loadScript } from 'lightning/platformResourceLoader';
import getSessionId from '@salesforce/apex/TelevisitMeetBannerController.getSessionId';
import getVisits from '@salesforce/apex/TelevisitMeetBannerController.getVisits';
import USER_TIME_ZONE from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
export default class TelevisitMeetBanner extends NavigationMixin(LightningElement) {
    @api channel = '/event/Televisit_Event__e';
    hasVisits = false;
    cometd;
    subscription;
    currentVisit = {};
    USER_TIME_ZONE = USER_TIME_ZONE;
    USER_ID = USER_ID;
    meetMainInfo = 'Text'; 
    meetLinkUrl; 
    singleMeetDetail = {};
    singleActiveVisit = true;
    showMoreVisits = false;
    moreVisitIconName = 'utility:chevronright';
    allVisits = [];
    allActiveVisits = [];
    hasActiveVisits = false;
    
    // Initializes the component
    connectedCallback() {      
        this.getVisits(); 
        this.loadCometdScript();
        this.timeInterval();
    }

    loadCometdScript(){
        console.log('loadCometdScript');
        if(!this.subscription){
            Promise.all([
                loadScript(this, cometdStaticResource)
            ])
                .then(() => {
                    this.loadSessionId();
                })
                .catch(error => {
                    let message = error.message || error.body.message;
                    console.log('Error::'+message);//TODO
                });
        } else {
            //TODO
            console.log('!this.subscription');
        }
    }

    loadSessionId(){
        console.log('loadSessionId');
        getSessionId()
            .then(sessionId => {
                console.log('sessionId');
                this.cometd = new window.org.cometd.CometD();
                this.cometd.configure({
                    url: window.location.protocol + '//' + window.location.hostname + '/cometd/49.0/',
                    requestHeaders: { Authorization: 'OAuth ' + sessionId},
                    appendMessageTypeToURL : false
                });
                this.cometd.websocketEnabled = false;
                this.cometd.handshake( (status) => {
                    if (status.successful) {
                        //console.log('status.successful::'+status.successful);
                        this.subscription = this.cometd.subscribe( this.channel , (message) => {
                            //console.log('s::');
                            console.log('Payload::'+JSON.stringify(message.data.payload));
                            let reLoadRequired = (message.data.payload.Payload__c.includes(USER_ID));
                            console.log('reLoadRequired::'+reLoadRequired);
                            //TODO check update banner cases
                            if(reLoadRequired){
                                this.getVisits();
                            }
                        });
                    } else {
                        console.log(status);
                        //TODO
                    }
                });

            })
            .catch(error => {
                let message = error.message || error.body.message;
                console.log('Error ;;'+message);
                //TODO
            });
    }
    getVisits() {
        console.log('getVisits');
        this.hasVisits = true;
        getVisits()
        .then(result => {
            var televisitInformation = JSON.parse(result);
            if (televisitInformation) {
                console.log('televisitInformation :: '+televisitInformation);
                let visitData = Object.assign(televisitInformation);
                this.loadVisitData(visitData);
            }
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log('Error'+message);
        });
    }
    loadVisitData(visitData){
        //console.log('visitData : '+JSON.stringify(visitData));
        this.allVisits = visitData;
        this.hasActiveVisits = false;
        var activeVisits = [];
        visitData.forEach( visitInfo => {
            console.log('visitData : '+JSON.stringify(visitInfo));
            let visitDetail = visitInfo;
            var now = new Date();
            let dateNow = new Date(now);
            console.log(dateNow.getTime());
            
            let scheduledDate = new Date(visitInfo.Televisit__r.Visit_Date_Time__c);
            let scheduledEndDate = new Date(visitInfo.Televisit__r.Visit_End_Date_Time__c);
           
            console.log('scheduledEndDate::'+scheduledEndDate);
            //scheduledEndDate.setMinutes(date.getMinutes() + visitInfo.Televisit__r.Duration__c);
            console.log('visitInfo.Televisit__r.Visit_Date_Time__c :: Title'+visitInfo.Televisit__r.Title__c);
            console.log('visitInfo.Televisit__r.Visit_Date_Time__c :: date now'+dateNow);
            console.log('visitInfo.Televisit__r.Visit_Date_Time__c :: record detail'+visitInfo.Televisit__r.Visit_Date_Time__c);
            console.log('visitInfo.Televisit__r.Visit_Date_Time__c :: scheduled date'+scheduledDate);
            visitDetail.scheduledTime = scheduledDate; 
            visitDetail.scheduledEndTime = scheduledEndDate; 
            let bannerStartTime = new Date(visitInfo.Televisit__r.Visit_Link_Activation_Start_Time__c);
            let bannerEndTime = new Date(visitInfo.Televisit__r.Visit_Link_Activation_End_Time__c);
            if(dateNow >= bannerStartTime && dateNow <= bannerEndTime){
                activeVisits.push(visitDetail);
            }
        });
        //console.log('loadVisitData 1'+activeVisits.length);
        this.allActiveVisits = activeVisits;
        if(activeVisits.length > 0 ){
            //console.log('loadVisitData 2');
            this.hasActiveVisits = true;
        }
        if(activeVisits.length == 1){
            //console.log('loadVisitData 3');
            this.singleMeetDetail = activeVisits[0];
            this.meetMainInfo = activeVisits[0].Televisit__r.Title__c +' with '+activeVisits[0].Televisit__r.Participant_Enrollment__r.PI_Contact__r.Full_Name__c 
            +' will take place at ';//activeVisits[0].
            this.singleActiveVisit = true;
            this.meetLinkUrl = activeVisits[0].Televisit__r.Meeting_URL__c ;
        }else if(activeVisits.length > 1){
            //console.log('loadVisitData 4');
            this.singleActiveVisit = false;
            this.meetMainInfo = activeVisits.length +' Upcomming or Active Televisits';
        }
        //this.currentVisit = visitData[0];
        //console.log('loadVisitData ::'+this.currentVisit.Televisit__r.Title__c);
    }
    handleJoinClick(event){
        console.log('handleJoinClick');
        console.log(event.target.dataset.name);
        let url = event.target.dataset.name;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
                attributes: {
                    url: url
                }
            },
            true
        ).then(generatedUrl => {
            window.open(generatedUrl, '_blank');
        });
    }
    handleSingleMeetJoin(event){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
                attributes: {
                    url: this.meetLinkUrl
                }
            },
            true
        ).then(generatedUrl => {
            window.open(generatedUrl, '_blank');
        });
    }
    handleOpenCloseVisits(event){
        this.showMoreVisits = (!this.showMoreVisits);
        this.moreVisitIconName = (this.moreVisitIconName == 'utility:chevronright' ? 'utility:chevrondown' : 'utility:chevronright');
    }
    timeInterval(){
        setInterval(() => {
            this.loadVisitData(this.allVisits);
        }, 60 * 1000);
    }
    
}