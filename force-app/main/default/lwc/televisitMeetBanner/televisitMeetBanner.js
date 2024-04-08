import { LightningElement, api, wire, track } from 'lwc';
import cometdStaticResource from '@salesforce/resourceUrl/cometd';
import { loadScript } from 'lightning/platformResourceLoader';
import getSessionId from '@salesforce/apex/TelevisitMeetBannerController.getSessionId';
import getVisits from '@salesforce/apex/TelevisitMeetBannerController.getVisits';
import USER_TIME_ZONE from '@salesforce/i18n/timeZone';
import USER_LOCALE from '@salesforce/i18n/locale';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import PT_TV_MEET_INFO from '@salesforce/label/c.PT_Televisit_Meet_Info';
import PI_TV_MEET_INFO from '@salesforce/label/c.PI_Televisit_Meet_Info';
import JOIN_MEET from '@salesforce/label/c.WelcomeModal_Join';
import UPCOMING_VISIT from '@salesforce/label/c.Televisit_Upcoming_Meet';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class TelevisitMeetBanner extends NavigationMixin(LightningElement) {
    @api channel = '/event/Televisit_Event__e';
    @api urlPathPrefix = '';
    hasVisits = false;
    cometd;
    subscription;
    currentVisit = {};
    _currentMode = {};
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
    UPCOMING_VISIT = UPCOMING_VISIT;
    showTelevisitCameraAndMicrophoneAccessPopup = false;
    bgCss;
    multipleJoinCss;
    singleJoinCss;
    allVisitCss;
    isPP2View = false;
    _handler;
    deviceSize = 10;
    isMobileDevice;
    @track labels = {
        UPCOMING_VISIT,
        PT_TV_MEET_INFO,
        PI_TV_MEET_INFO,
        JOIN_MEET
    };

    // Initializes the component
    connectedCallback() {
        this.getCommunintyTemplateName();
        this.getVisits();
        this.loadCometdScript();
        this.timeInterval();
        document.addEventListener('click', this._handler = this.close.bind(this));
    }

    loadCometdScript() {
        if (!this.subscription) {
            Promise.all([loadScript(this, cometdStaticResource)])
                .then(() => {
                    this.loadSessionId();
                })
                .catch((error) => {
                    let message = error.message || error.body.message;
                    console.log('Error::' + message);
                });
        } else {
            //TODO
            console.log('!this.subscription');
        }
    }

    loadSessionId() {
        getSessionId()
            .then((sessionId) => {
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
                    if (status.successful) {
                        this.subscription = this.cometd.subscribe(this.channel, (message) => {
                            let reLoadRequired = message.data.payload.Payload__c.includes(USER_ID);
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
            .catch((error) => {
                let message = error.message || error.body.message;
                console.log('Error ;;' + message);
                //TODO
            });
    }
    getCommunintyTemplateName() {
        if(this._currentMode.template.communityName === 'IQVIA Patient Portal'){
            this.isPP2View = true;
            this.allVisitCss = 'allVisitsPP2';
            if(FORM_FACTOR == 'Large'){
                this.bgCss = 'divBodyPP2 slds-p-around_medium slds-text-color_inverse';
                this.multipleJoinCss = 'slds-text-color_inverse join multipleJoinPP2';
                this.singleJoinCss = 'slds-text-color_inverse join singleJoinPP2';
                this.deviceSize = 10;
                this.isMobileDevice = false;
            }else{
                this.bgCss = 'divBodyPP2Mobile slds-p-around_medium slds-text-color_inverse';
                this.multipleJoinCss = 'slds-text-color_inverse join multipleJoinPP2Mobile';
                this.singleJoinCss = 'slds-text-color_inverse join singleJoinPP2Mobile';
                this.deviceSize = 10;
                this.isMobileDevice = true;
            }
            
        }else{
            this.bgCss = 'divBody slds-p-around_medium slds-text-color_inverse';
            this.isPP2View = false;
            this.allVisitCss = 'allVisits';
            
            if(FORM_FACTOR == 'Large'){
                this.isMobileDevice = false;
                this.deviceSize = 10;
            }else{
                this.isMobileDevice = true;
                this.deviceSize = 10;
            }
        } 
    }

    getVisits() {
        this.hasVisits = true;
        this.showMoreVisits = false;
        getVisits({
            communityMode: this._currentMode.template.communityName,
            userMode: this._currentMode.userMode
        })
            .then((result) => {
                var televisitInformation = JSON.parse(result);
                if (televisitInformation) {
                    let visitData = Object.assign(televisitInformation);
                    this.loadVisitData(visitData);
                }
            })
            .catch((error) => {
                let message = error.message || error.body.message;
                console.log('Error' + message);
            });
    }
    loadVisitData(visitData) {
        this.allVisits = visitData;
        this.hasActiveVisits = false;
        let activeVisits = [];
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
            }
        });
        /*
        if(this.allActiveVisits.length != activeVisits.length){
            this.moreVisitIconName = 'utility:chevrondown';
        }*/
        

        this.allActiveVisits = activeVisits;
        this.showMoreVisits =
            this.showMoreVisits && (activeVisits.length === 0 || activeVisits.length === 1)
                ? false
                : this.showMoreVisits;

        if(!this.showMoreVisits){
            this.moreVisitIconName = 'utility:chevrondown';
        }
        if (activeVisits.length > 0) {
            this.hasActiveVisits = true;
            window.sessionStorage.setItem("televistActive", 'true');       
        }
        else{
            window.sessionStorage.setItem("televistActive", 'false');
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
    }

    @api
    get currentMode() {
        return this._currentMode;        
    }
    set currentMode(value) {  
        this._currentMode = value;        
        if (this._currentMode) {
            this.getVisits();
        }
    }

    handleJoinClick(event) {
        var mobileApp = communityService.isMobileSDK();
        this.handleOpenCloseVisits();
        let url = this.urlPathPrefix.replace('/s', '') + event.target.dataset.name + '&mobileApp=' + mobileApp ;
        window.open(url, '_blank');
    }
    handleSingleMeetJoin(event) {
        var mobileApp = communityService.isMobileSDK();
        event.target.style.color = 'white';
        let url = this.urlPathPrefix.replace('/s', '') + this.meetLinkUrl + '&mobileApp=' + mobileApp;
        window.open(url, '_blank');
        
    }
    handleOpenCloseVisits() {
        this.showMoreVisits = !this.showMoreVisits;
        this.moreVisitIconName =
            this.moreVisitIconName === 'utility:chevrondown'
                ? 'utility:chevronup'
                : 'utility:chevrondown';
    }

    ignore(event) {
        event.stopPropagation();
        return false;
    }
    disconnectedCallback() {
        document.removeEventListener('click', this._handler);
    }
    close() { 
        this.showMoreVisits = false;
        this.moreVisitIconName = 'utility:chevrondown';
    }

    handleCloseAccessPopup(event) {
        this.showTelevisitCameraAndMicrophoneAccessPopup = event.detail;
    }

    timeInterval() {
        setInterval(() => {
            this.loadVisitData(this.allVisits);
        }, 60 * 1000);
    }

    getLocaleTime(televisitDate) {
        let dateValue = new Date(televisitDate);
        return dateValue.toLocaleString(USER_LOCALE, {
            timeZone: USER_TIME_ZONE,
            hour: '2-digit',
            minute: '2-digit',
            //hour12: true
        });
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

    
    
}