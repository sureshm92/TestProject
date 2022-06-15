import { LightningElement, api, wire, track } from 'lwc';
import cometdStaticResource from '@salesforce/resourceUrl/cometd';
import { loadScript } from 'lightning/platformResourceLoader';
import getSessionId from '@salesforce/apex/TelevisitMeetBannerController.getSessionId';
import getVisits from '@salesforce/apex/TelevisitMeetBannerController.getVisits';
import USER_TIME_ZONE from '@salesforce/i18n/timeZone';
import USER_LOCALE from '@salesforce/i18n/locale';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
//import MEET_WITH from '@salesforce/label/c.Televisit_Meet_Sub1';
//import MEET_AT from '@salesforce/label/c.Televisit_Meet_Sub2';
//import UPCOMING_VISIT from '@salesforce/label/c.Televisit_Upcoming_Meet';
//import TO from '@salesforce/label/c.RH_To';
import PT_TV_MEET_INFO from '@salesforce/label/c.PT_Televisit_Meet_Info';
import PI_TV_MEET_INFO from '@salesforce/label/c.PI_Televisit_Meet_Info';
import JOIN_MEET from '@salesforce/label/c.WelcomeModal_Join';
import UPCOMING_VISIT from '@salesforce/label/c.Televisit_Upcoming_Meet';

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
    moreVisitIconName = 'utility:chevrondown';
    allVisits = [];
    allActiveVisits = [];
    hasActiveVisits = false;
    //MEET_WITH = MEET_WITH;
    //MEET_AT = MEET_AT;
    UPCOMING_VISIT = UPCOMING_VISIT;
    //TO = TO;
    showTelevisitCameraAndMicrophoneAccessPopup = false;

    @track labels = {
        UPCOMING_VISIT,
        PT_TV_MEET_INFO,
        PI_TV_MEET_INFO,
        JOIN_MEET
    };

    // Initializes the component
    connectedCallback() {
        this.getVisits();
        this.loadCometdScript();
        this.timeInterval();
    }
    
    loadCometdScript() {
        if (!this.subscription) {
            Promise.all([
                loadScript(this, cometdStaticResource)
            ])
                .then(() => {
                    this.loadSessionId();
                })
                .catch(error => {
                    let message = error.message || error.body.message;
                    console.log('Error::' + message);//TODO
                });
        } else {
            //TODO
            console.log('!this.subscription');
        }
    }

    loadSessionId() {
        getSessionId()
            .then(sessionId => {
                this.cometd = new window.org.cometd.CometD();
                this.cometd.configure({
                    url: window.location.protocol + '//' + window.location.hostname + '/cometd/49.0/',
                    requestHeaders: { Authorization: 'OAuth ' + sessionId },
                    appendMessageTypeToURL: false
                });
                this.cometd.websocketEnabled = false;
                this.cometd.handshake((status) => {
                    if (status.successful) {
                        this.subscription = this.cometd.subscribe(this.channel, (message) => {
                            let reLoadRequired = (message.data.payload.Payload__c.includes(USER_ID));
                            //TODO check update banner cases
                            if (reLoadRequired) {
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
                console.log('Error ;;' + message);
                //TODO
            });
    }
    getVisits() {
        this.hasVisits = true;
        this.showMoreVisits = false;
        getVisits()
            .then(result => {
                var televisitInformation = JSON.parse(result);
                if (televisitInformation) {
                    let visitData = Object.assign(televisitInformation);
                    this.loadVisitData(visitData);
                }
            })
            .catch(error => {
                let message = error.message || error.body.message;
                console.log('Error' + message);
            });
    }
    loadVisitData(visitData) {

        this.allVisits = visitData;
        this.hasActiveVisits = false;
        var activeVisits = [];
        visitData.forEach(visitInfo => {
            let visitDetail = visitInfo;
            var now = new Date();
            let dateNow = new Date(now);
            // let scheduledDate = new Date(visitInfo.Televisit__r.Visit_Date_Time__c);
            // let scheduledEndDate = new Date(visitInfo.Televisit__r.Visit_End_Date_Time__c);
            // visitDetail.scheduledTime = scheduledDate;
            // visitDetail.scheduledEndTime = scheduledEndDate;
            let meetInfo = this.getIsPTorPTDelegate(visitInfo.Attendee_Type__c) ? this.labels.PT_TV_MEET_INFO : this.labels.PI_TV_MEET_INFO;
            meetInfo = this.getTelevisitMeetInfo(meetInfo, visitInfo);
            visitDetail.eachMeetInfo = meetInfo;

            let bannerStartTime = new Date(visitInfo.Televisit__r.Visit_Link_Activation_Start_Time__c);
            let bannerEndTime = new Date(visitInfo.Televisit__r.Visit_Link_Activation_End_Time__c);
            if (dateNow >= bannerStartTime && dateNow <= bannerEndTime) {
                activeVisits.push(visitDetail);
            }
        });
        this.allActiveVisits = activeVisits;
        this.showMoreVisits = (this.showMoreVisits && (activeVisits.length === 0 || activeVisits.length === 1) ? false : this.showMoreVisits);
        if (activeVisits.length > 0) {
            this.hasActiveVisits = true;
        }
        if (activeVisits.length === 1) {
            this.singleMeetDetail = activeVisits[0];
            // this.meetMainInfo = activeVisits[0].Televisit__r.Title__c + ' ' + MEET_WITH + ' ' + activeVisits[0].Televisit__r.Participant_Enrollment__r.Participant_Name__c
            //     + ' ' + MEET_AT + ' ';//activeVisits[0].
            this.meetMainInfo = this.getIsPTorPTDelegate(activeVisits[0].Attendee_Type__c) ? this.labels.PT_TV_MEET_INFO : this.labels.PI_TV_MEET_INFO;
            this.meetMainInfo = this.getTelevisitMeetInfo(this.meetMainInfo, activeVisits[0]);
            this.singleActiveVisit = true;
            this.meetLinkUrl = activeVisits[0].Televisit__r.Meeting_URL__c;
        } else if (activeVisits.length > 1) {
            this.singleActiveVisit = false;
            //this.meetMainInfo = activeVisits.length + ' ' + UPCOMING_VISIT;
            this.meetMainInfo = this.labels.UPCOMING_VISIT.replace('##NoOfTV', activeVisits.length);
        }
        //this.currentVisit = visitData[0];
        //console.log('loadVisitData ::'+this.currentVisit.Televisit__r.Title__c);
    }

    handleJoinClick(event) {
        let url = event.target.dataset.name;
        //window.open(url, '_blank');
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: url
        //     }
        // },
        //     true
        // ).then(generatedUrl => {
        //     window.open(generatedUrl, '_blank');
        // });
        //let url = event.target.dataset.name;

        this.showTelevisitCameraAndMicrophoneAccessPopup = true;

    }
    handleSingleMeetJoin(event) {
        this.showTelevisitCameraAndMicrophoneAccessPopup = true;

        //window.open(this.meetLinkUrl, '_blank');
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: this.meetLinkUrl
        //     }
        // },
        //     true
        // ).then(generatedUrl => {
        //     window.open(generatedUrl, '_blank');
        // });
    }
    handleOpenCloseVisits() {
        this.showMoreVisits = (!this.showMoreVisits);
        this.moreVisitIconName = (this.moreVisitIconName === 'utility:chevrondown' ? 'utility:chevronup' : 'utility:chevrondown');
    }
    timeInterval() {
        setInterval(() => {
            this.loadVisitData(this.allVisits);
        }, 60 * 1000);
    }

    getLocaleTime(televisitDate) {
        let dateValue = new Date(televisitDate);
        return dateValue.toLocaleString(USER_LOCALE, { timeZone: USER_TIME_ZONE, hour: '2-digit', minute: '2-digit', hour12: true });
    }

    getIsPTorPTDelegate(attendeeType) {
        let isPTorPTDelegate = (attendeeType === 'Participant' || attendeeType === 'Participant Delegate') ? true : false;
        return isPTorPTDelegate;
    }

    getTelevisitMeetInfo(label, visitInfo) {
        let teleMeetMainInfo = label.replace('##TVName', visitInfo.Televisit__r.Title__c);
        teleMeetMainInfo = teleMeetMainInfo.replace('##PIName', visitInfo.Televisit__r.Participant_Enrollment__r.PI_Contact__r.Full_Name__c)
        teleMeetMainInfo = teleMeetMainInfo.replace('##PTName', visitInfo.Televisit__r.Participant_Enrollment__r.Participant__r.Full_Name__c);
        teleMeetMainInfo = teleMeetMainInfo.replace('##StartTime', this.getLocaleTime(visitInfo.Televisit__r.Visit_Date_Time__c));
        teleMeetMainInfo = teleMeetMainInfo.replace('##EndTime', this.getLocaleTime(visitInfo.Televisit__r.Visit_End_Date_Time__c));
        return teleMeetMainInfo;
    }

}