import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import cometdStaticResource from '@salesforce/resourceUrl/cometd';
import { loadScript } from 'lightning/platformResourceLoader';
import getSessionId from '@salesforce/apex/TelevisitMeetBannerController.getSessionId';
import getVisits from '@salesforce/apex/TelevisitMeetBannerController.getVisits';
import PT_TV_MEET_INFO from '@salesforce/label/c.PT_Televisit_Meet_Info';
import PI_TV_MEET_INFO from '@salesforce/label/c.PI_Televisit_Meet_Info';
import JOIN_MEET from '@salesforce/label/c.WelcomeModal_Join';
import UPCOMING_VISIT from '@salesforce/label/c.Televisit_Upcoming_Meet';
import USER_LOCALE from '@salesforce/i18n/locale';
import USER_TIME_ZONE from '@salesforce/i18n/timeZone';
import USER_ID from '@salesforce/user/Id';
import getParticipantDetails from '@salesforce/apex/ParticipantTelevisitRemote.getParticipantTelevisits';
export default class PpMyTelevisitsList extends NavigationMixin (LightningElement) {
    showupcomingtelevisits = false;
    upcomingtelevisitdata = [];
    pasttelevisitdata = [];
    @api upcomingtelevisitsrecords;
    @api pasttelevisitsrecords;
    @api ismobile;
    @api channel = '/event/Televisit_Event__e';
    showJoinButton = [];
    @api zonetime;
    @api urlPathPrefix = '';
    USER_ID = USER_ID;
    cometd;
    meetMainInfo = 'Text';
    meetLinkUrl;
    singleMeetDetail = {};
    singleActiveVisit = true;
    showMoreVisits = false;
    moreVisitIconName = 'utility:chevrondown';
    allVisits = [];
    allActiveVisits = [];
    hasActiveVisits = false;
    UPCOMING_VISIT = UPCOMING_VISIT;
    showTelevisitCameraAndMicrophoneAccessPopup = false;
    bgCss;
    @api past;
    @track labels = {
        UPCOMING_VISIT,
        PT_TV_MEET_INFO,
        PI_TV_MEET_INFO,
        JOIN_MEET
    };
    
    connectedCallback() {
        this.upcomingtelevisitdata = this.upcomingtelevisitsrecords;
        this.pasttelevisitdata = this.pasttelevisitsrecords;
        if(this.upcomingtelevisitdata.length > 0){
            this.showupcomingtelevisits = true;
        }
        this.getVisits(); 
        this.loadCometdScript();
        this.timeInterval();
    }
   joinmeeting (event){
        this.urlPathPrefix = '/pp/s';
        let url = this.urlPathPrefix.replace('/s', '') + event.currentTarget.dataset.id;
        window.open(url, '_blank');
    }


    loadCometdScript() {
        
        Promise.all([loadScript(this, cometdStaticResource)])
            .then(() => {
                this.loadSessionId();
            })
            .catch((error) => {
                let message = error.message || error.body.message;
            });
    } 

    loadSessionId() {
        getSessionId()
            .then((sessionId) => {
                console.log(sessionId);
                this.cometd = new window.org.cometd.CometD();
                this.cometd.configure({
                    url:
                        window.location.protocol +
                        '//' +
                        window.location.hostname +
                        '/cometd/49.0/',
                    requestHeaders: { Authorization: 'OAuth ' + sessionId },
                    appendMessageTypeToURL: false
                });
                this.cometd.websocketEnabled = false;
                this.cometd.handshake((status) => {
                    this.cometd.subscribe(this.channel, (message) => {
                        let reLoadRequired = message.data.payload.Payload__c.includes(USER_ID);
                        //TODO check update banner cases
                        if (reLoadRequired) {
                            this.getVisits();
                        }
                        
                    });
                });
            })
            .catch((error) => {
                let message = error.message || error.body.message;
                //TODO
            });
    }

    getVisits() {
        this.hasVisits = true;
        this.showMoreVisits = false;
        getVisits({communityMode : 'IQVIA Patient Portal', userMode : 'Participant'})
            .then((result) => {
                var televisitInformation = JSON.parse(result);
            if (televisitInformation) {
                let visitData = Object.assign(televisitInformation);
                this.loadVisitData(visitData);
            }
            })
            .catch((error) => {
                let message = error.message || error.body.message;
            });
    }

    loadVisitData(visitData) {
        this.allVisits = visitData;
        this.hasActiveVisits = false;
        let activeVisits = [];
        let activevisitids = [];
        console.log(this.allActiveVisits);
        visitData.forEach((visitInfo) => {
            let visitDetail = visitInfo;
            var now = new Date();
            let dateNow = new Date(now);
            let meetInfo = this.getIsPTorPTDelegate(visitInfo.Attendee_Type__c)
                ? this.labels.PT_TV_MEET_INFO
                : this.labels.PI_TV_MEET_INFO;
            meetInfo = this.getTelevisitMeetInfo(meetInfo, visitInfo);
            visitDetail.eachMeetInfo = meetInfo;

            let bannerStartTime = new Date(
                visitInfo.Televisit__r.Visit_Link_Activation_Start_Time__c
            );
            let bannerEndTime = new Date(visitInfo.Televisit__r.Visit_Link_Activation_End_Time__c);
            if (dateNow >= bannerStartTime && dateNow <= bannerEndTime) {
                activeVisits.push(visitDetail);
                activevisitids.push(visitDetail.Televisit__c);
            }
        });
        if(this.allActiveVisits.length > activevisitids.length || ((this.allActiveVisits.length < activevisitids.length) || 
            (activevisitids.length > 0 && this.allActiveVisits.length == activevisitids.length))){
            getParticipantDetails({joinbuttonids :activevisitids })
            .then((result) => {
                if(result != undefined && result != ''){
                    if(this.allActiveVisits.length < activevisitids.length || 
                       (activevisitids.length > 0 && this.allActiveVisits.length == activevisitids.length && 
                        this.upcomingtelevisitdata.length == result.televisitupcomingList.length)){
                        this.showupcomingtelevisits = false;
                        this.upcomingtelevisitdata = result.televisitupcomingList;
                        this.showupcomingtelevisits = true;
                        this.allActiveVisits = activeVisits;
                        this.showMoreVisits =
                        this.showMoreVisits && (activeVisits.length === 0 || activeVisits.length === 1)
                            ? false
                            : this.showMoreVisits;
                        if (activeVisits.length > 0) {
                            this.hasActiveVisits = true;
                        }
                        if (activeVisits.length === 1) {
                            this.singleMeetDetail = activeVisits[0];
                            this.meetMainInfo = this.getIsPTorPTDelegate(activeVisits[0].Attendee_Type__c)
                                ? this.labels.PT_TV_MEET_INFO
                                : this.labels.PI_TV_MEET_INFO;
                            this.meetMainInfo = this.getTelevisitMeetInfo(this.meetMainInfo, activeVisits[0]);
                            this.singleActiveVisit = true;
                            this.meetLinkUrl = activeVisits[0].Televisit__r.Meeting_URL__c;
                        } else if (activeVisits.length > 1) {
                            this.singleActiveVisit = false;
                            this.meetMainInfo = this.labels.UPCOMING_VISIT.replace('##NoOfTV', activeVisits.length);
                        }
                        if(this.upcomingtelevisitdata.length > 0){
                            const selectEvent = new CustomEvent('selection', {
                                detail: 
                                    {
                                        filter:'showblankupcomingtelevisits:false',
                                        details:result.televisitpastList,
                                        upcomingdata:this.upcomingtelevisitdata
                                    }
                                });
                            this.dispatchEvent(selectEvent);
                        }
                }
                
                if(this.allActiveVisits.length > activevisitids.length){
                    this.upcomingtelevisitdata = result.televisitupcomingList;
                    this.allActiveVisits = activeVisits;
                    if(this.upcomingtelevisitdata.length == 0 && activevisitids.length == 0){
                        const selectEvent = new CustomEvent('selection', {
                            detail: 
                            {
                                filter:'showblankupcomingtelevisits:true',
                                details:result.televisitpastList,
                                upcomingdata:this.upcomingtelevisitdata
                            }
                        });
                        this.dispatchEvent(selectEvent);
                    }else{
                        const selectEvent = new CustomEvent('selection', {
                            detail: 
                            {
                                filter:'datachange',
                                details:result.televisitpastList,
                                upcomingdata:this.upcomingtelevisitdata
                            }
                        });
                        this.dispatchEvent(selectEvent);
                    }

                }
                
            }
        })
        .catch((error) => {
            console.log('+++++++++'+error);
        });
        }
        
    }

    timeInterval() {
        setInterval(() => {
            this.loadVisitData(this.allVisits);
        }, 60 * 1000);
    }

    handleSingleMeetJoin(event) {
        console.log(this.urlPathPrefix);
        this.urlPathPrefix = '/pp/s';
        let url = this.urlPathPrefix.replace('/s', '') + this.meetLinkUrl;
        window.open(url, '_blank');
    }
    
    getIsPTorPTDelegate(attendeeType) {
        let isPTorPTDelegate =
            attendeeType === 'Participant' || attendeeType === 'Participant Delegate'
                ? true
                : false;
        return isPTorPTDelegate;
    }

    getTelevisitMeetInfo(label, visitInfo) {
        let teleMeetMainInfo = label.replace('##TVName', visitInfo.Televisit__r.Title__c);
        teleMeetMainInfo = teleMeetMainInfo.replace(
            '##PIName',
            visitInfo.Televisit__r.Participant_Enrollment__r.PI_Contact__r.Salutation_With_Name__c
        );
        let participantFullName;
        if (
            visitInfo.Attendee_Type__c === 'Participant' &&
            visitInfo.Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c
        ) {
            participantFullName =
                visitInfo.Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c +
                ' ' +
                visitInfo.Televisit__r.Participant_Enrollment__r.Participant__r.Full_Name__c;
        } else {
            participantFullName =
                visitInfo.Televisit__r.Participant_Enrollment__r.Participant__r.Full_Name__c;
        }
        teleMeetMainInfo = teleMeetMainInfo.replace('##PTName', participantFullName);
        teleMeetMainInfo = teleMeetMainInfo.replace(
            '##StartTime',
            this.getLocaleTime(visitInfo.Televisit__r.Visit_Date_Time__c)
        );
        teleMeetMainInfo = teleMeetMainInfo.replace(
            '##EndTime',
            this.getLocaleTime(visitInfo.Televisit__r.Visit_End_Date_Time__c)
        );
        return teleMeetMainInfo;
    }

    getLocaleTime(televisitDate) {
        let dateValue = new Date(televisitDate);
        return dateValue.toLocaleString(USER_LOCALE, {
            timeZone: USER_TIME_ZONE,
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
    }
  
    handleJoinClick(event) {
        this.urlPathPrefix = '/pp/s';
        let url = this.urlPathPrefix.replace('/s', '') + event.target.dataset.name;
        window.open(url, '_blank');
    }

    
}