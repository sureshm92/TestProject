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

export default class PpMyTelevisitsList extends NavigationMixin (LightningElement) {
    showupcomingtelevisits = false;
    upcomingtelevisitdata = [];
    @api upcomingtelevisitsrecords;
    @api ismobile;
    @api channel = '/event/Televisit_Event__e';
    allActiveVisits = [];
    showJoinButton = [];
    allVisits = [];
    @api zonetime;
    @track labels = {
        UPCOMING_VISIT,
        PT_TV_MEET_INFO,
        PI_TV_MEET_INFO,
        JOIN_MEET
    };
 
    connectedCallback() {
        this.upcomingtelevisitdata = this.upcomingtelevisitsrecords;
        this.showupcomingtelevisits = true;
        console.log('++++++++this.zonetime'+ JSON.stringify(this.zonetime));
        console.log('this.upcomingtelevisitdata ::',this.upcomingtelevisitdata[0].televisitmettingurl);
        this.getVisits(); 
        this.loadCometdScript();
        this.timeInterval();
    }

    joinmeeting (event){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: event.currentTarget.dataset.id
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });

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
                        console.log(message);
                        console.log('Televisit event Fired');
                        //TODO check update banner cases
                        this.getVisits();
                        
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
        //this.hasVisits = true;
        //this.showMoreVisits = false;
        getVisits({communityMode : 'IQVIA Patient Portal', userMode : 'Participant'})
            .then((result) => {
                console.log('result',result);
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
        console.log('visitData :',visitData);
        this.allVisits = visitData;
        //this.hasActiveVisits = false;
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
                console.log('activeVisits:',activeVisits);
            }
        });
        this.allActiveVisits = activeVisits;
        
        this.processData();
    }

    processData(){
        console.log('this.allActiveVisits',this.allActiveVisits);
        for(var i=0; i<this.upcomingtelevisitdata.length; i++){
            this.template.querySelector('[data-tv='+this.upcomingtelevisitdata[i].televisitId+']').style="display:none;"; 
            for(var j=0; j<this.allActiveVisits.length; j++){
                if(this.upcomingtelevisitdata[i].televisitId === this.allActiveVisits[j].Televisit__r.Id){
                    this.showJoinButton.push(this.upcomingtelevisitdata[i].televisitId);
                    this.template.querySelector('[data-tv='+this.upcomingtelevisitdata[i].televisitId+']').style="display:block;";
                } 
            }
        }

        console.log('this.showJoinButton',this.showJoinButton);
       // console.log(this.template.querySelector('[data-tv='+this.showJoinButton+']').style="display:block;");
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

    timeInterval() {
        setInterval(() => {
            console,log('In');
            this.getVisits(); 
            //this.loadVisitData(this.allVisits);
        }, 60 * 1000);
    }
}