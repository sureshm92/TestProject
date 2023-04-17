import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import cometdStaticResource from '@salesforce/resourceUrl/cometd';
import { loadScript } from 'lightning/platformResourceLoader';
import getSessionId from '@salesforce/apex/PPTelevisitUpcomingTileController.getSessionId';
import getVisits from '@salesforce/apex/PPTelevisitUpcomingTileController.getVisits';
import PT_TV_MEET_INFO from '@salesforce/label/c.PT_Televisit_Meet_Info';
import PI_TV_MEET_INFO from '@salesforce/label/c.PI_Televisit_Meet_Info';
import JOIN_MEET from '@salesforce/label/c.WelcomeModal_Join';
import UPCOMING_VISIT from '@salesforce/label/c.Televisit_Upcoming_Meet';
import USER_LOCALE from '@salesforce/i18n/locale';
import USER_TIME_ZONE from '@salesforce/i18n/timeZone';
import USER_ID from '@salesforce/user/Id';
import fetchTelevisitAttendees from '@salesforce/apex/PPTelevisitUpcomingTileController.fetchTelevisitAttendees';
import televisitDatePP2 from '@salesforce/resourceUrl/Televisit_Date_PP2';
import televisitTimePP2 from '@salesforce/resourceUrl/Televisit_Time_PP2';
import televisitAttendeePP2 from '@salesforce/resourceUrl/Televisit_Attendee_PP2';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import televisitNoUpcomingRecord from '@salesforce/resourceUrl/TelevisitNoUpcomingRecord';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class PpTelevisitUpcomingTile extends NavigationMixin(LightningElement)  {
    @track status;
    @track message;
    @track recordId;
    empty_state = pp_community_icons + '/' + 'empty_visits.png';
    subscription = {};
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
    showBlankTelevisit = false;
    hasActiveVisits = false;
    UPCOMING_VISIT = UPCOMING_VISIT;
    showTelevisitCameraAndMicrophoneAccessPopup = false;
    bgCss;
    televisitDatePP2 = televisitDatePP2;
    televisitTimePP2 = televisitTimePP2;
    televisitAttendeePP2 = televisitAttendeePP2;
    televisitNoUpcomingRecord = televisitNoUpcomingRecord;
    isPIAttendee = false;
    siteStaffName;
    desktop;
    mainDiv;
    keydiv;
    @track labels = {
        UPCOMING_VISIT,
        PT_TV_MEET_INFO,
        PI_TV_MEET_INFO,
        JOIN_MEET
    };
    isLoading = true;

    @api
    get currentMode() {
        return this._currentMode;        
    }
    set currentMode(value) {  
        this._currentMode = value;
        this.getVisits();
    }
    connectedCallback() {
        // Register error listener    
        this.getVisits(); 
        this.loadCometdScript();
        //this.loadSessionId();
        this.timeInterval();
        if(FORM_FACTOR == 'Large'){
            this.desktop = true;
            this.mainDiv = '';
            this.keydiv = '';
        }else{
            this.desktop = false;
            this.mainDiv = 'mainDiv';
            this.keydiv = 'keydiv';
        }
        
    }
 
    

    loadCometdScript() {
        
            Promise.all([loadScript(this, cometdStaticResource)])
                .then(() => {
                    this.loadSessionId();
                })
                .catch((error) => {
                    let message = error.message || error.body.message;
                    console.log('Error::' + message);
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
                        console.log('Status',status);
                        this.cometd.subscribe(this.channel, (message) => {
                            let reLoadRequired = message.data.payload.Payload__c.includes(USER_ID);
                            console.log(message);
                            console.log('Televisit event Fired');
                            //TODO check update banner cases
                            if (reLoadRequired) {
                                console.log('Televisit event Fired on banner : reload requested');
                                this.getVisits();
                            }
                            
                        });
                    });
                })
                .catch((error) => {
                    let message = error.message || error.body.message;
                    console.log('Error ;;' + message);
                    //TODO
                });
        }

        getVisits() {
            console.log('Televisit Get visits called');
            this.hasVisits = true;
            this.showMoreVisits = false;
            getVisits({communityMode : 'IQVIA Patient Portal', userMode : 'Participant'})
                .then((result) => {
                    console.log('result',result);
                    var televisitInformation = JSON.parse(result);
                if (televisitInformation) {
                    let visitData = Object.assign(televisitInformation);

                    var televisitIds = [];
                    visitData.forEach((visitInfo) => {
                        televisitIds.push(visitInfo.Televisit__c);
                        visitInfo.timezone = USER_TIME_ZONE;
                    });
                    console.log('televisitIds :',televisitIds);
                    
                    
                    fetchTelevisitAttendees({lstTelevisitIds:televisitIds}).then((result) => {
                        console.log('fetchTelevisitAttendees',result);
                        result.forEach((resultInfo) => {
                            console.log('resultInfo',resultInfo);
                            console.log('resultInfo',resultInfo.televisitId);
                            console.log('resultInfo',resultInfo.numberOfParticipants);
                            console.log('resultInfo',resultInfo.televisitAttendees);
                            console.log('resultInfo',resultInfo.relatedAttendees);
                            visitData.forEach((visitInfo) => {

                                if(visitInfo.Televisit__c === resultInfo.televisitId){
                                    console.log('Inside');
                                    visitInfo.numberOfParticipants ='+ ' + resultInfo.numberOfParticipants + ' more';
                                    visitInfo.televisitAttendees = resultInfo.televisitAttendees;
                                    visitInfo.relatedAttendees = resultInfo.relatedAttendees;
                                    for(var i=0; i < resultInfo.relatedAttendees.length; i++){
                                        if(resultInfo.relatedAttendees[i].attendeeType == 'PI'){
                                            visitInfo.isPIAttendee = true;
                                            break;
                                        }else if(resultInfo.relatedAttendees[i].attendeeType == 'Site Staff'){
                                            visitInfo.isPIAttendee = false;
                                            visitInfo.siteStaffName = resultInfo.relatedAttendees[i].firstname + ' ' + resultInfo.relatedAttendees[i].lastname;
        
                                        }
                                    }
                                }
                            });

                            
                            
                        });   
                        //visitData.push(visitInfo); 
                        console.log('visitData :',visitData);
                        this.loadVisitData(visitData);
                    }).catch((error) => {
                        let message = error.message || error.body.message;
                        console.log('Error' + message);
                    });
                    

                    //this.loadVisitData(visitData);
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
                    
                //visitDetail.PINameWithoutSalutation = visitInfo.Televisit__r.Participant_Enrollment__r.PI_Contact__r.Salutation_With_Name__c.split('Mr.')[1];
                visitDetail.PINameWithoutSalutation = visitInfo.Televisit__r.Participant_Enrollment__r.PI_Contact__r.Salutation_With_Name__c;

                let bannerEndTime = new Date(visitInfo.Televisit__r.Visit_Link_Activation_End_Time__c);
                //if (dateNow >= bannerStartTime && dateNow <= bannerEndTime) {
                if (dateNow <= bannerEndTime) {
                    activeVisits.push(visitDetail);
                }
            });
            this.allActiveVisits = activeVisits;
            if(this.allActiveVisits.length === 0){
                this.showBlankTelevisit = true;
                
            }else{
                this.showBlankTelevisit = false; 
                
            }
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
            this.isLoading = false;
        }

        handleSingleMeetJoin(event) {
            console.log('this.meetLinkUrl',this.meetLinkUrl);
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

        timeInterval() {
            setInterval(() => {
                this.loadVisitData(this.allVisits);
            }, 60 * 1000);
        }

        setSessionCookie() {
            sessionStorage.setItem('Cookies', 'Accepted');
            return true;
        }
        navigateToTelevisit() {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'televisit'
                }
            });
        }    

}