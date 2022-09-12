import { LightningElement,track,api} from 'lwc';
import getParticipantVisits from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import communicationPreference from '@salesforce/label/c.Communication_Preference';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import getIcon from '@salesforce/apex/PatientVisitService.getVisitIcons';
import WTELabel from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';
import getParticipantVisitsDetails from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisitsDetails'; 
import getSiteAddress from '@salesforce/apex/ParticipantVisitsRemote.getSiteAddress'; 
import basePathName from '@salesforce/community/basePath';

export default class PpStudyVisitPage extends LightningElement {
    label = {
        noVisitsLabel
    };
    @track visitMode = 'All';
    @track upcomingVisits = [];
    @track pastVisits = [];
    @track sitePhoneNumber;
    @track noVisitDate = false;
    @track showUpcomingVisits=true;
    @track upcomingVariantValue = "Neutral";
    @track pastVariantValue = "Neutral";
    @track onVisitSelection = false;
    @track contentLoaded = false;
    @track visitTimezone;
    @track visitName;
    @track plannedDate;
    @track visitid;
    @track visitdata;
    @track visitStatus;
    @track showreminderdatepicker = false;
    @track sfdcBaseURL;
    @track siteAddress;
    @track selecteddate ='';
    @track taskId;
    @track taskSubject;
    @track showChild = false;
    @track siteName;
    @track past = false;
    @track pastVisitId;
    @track upcomingVisitId;
    @track selectedIndex = 0;
    initialized = '';
    visitMode = 'All';
    visitWrappers = [];
    @api icondetails = [];
    isError = false;

    labels = {
        WTELabel
    };

    callParticipantVisit(){
        getParticipantVisits({
            visitMode: this.visitMode
        })
            .then((result) => {
                console.log('Result:'+JSON.stringify(result));
                this.upcomingVariantValue = 'brand';
                this.pastVariantValue = 'Neutral';
                if(result.length>0){
                    this.visitid = result[0].visit.Id;
                    this.taskSubject = result[0].visit.Name;
                    for (let i = 0; i < result.length; i++) {
                        //set visitId on load of page
                        if (
                            result[i].visit.Completed_Date__c == null &&
                            (result[i].visit.Status__c == 'Scheduled' ||
                                result[i].visit.Status__c == 'Pending')
                        ) {
                            if (result[i].visit.Planned_Date__c === undefined) {
                                this.noVisitDate = true;
                                result[i].noVisitDate = this.noVisitDate;
                            }
                            this.upcomingVisits.push(result[i]);
                        } else if (
                            result[i].visit.Status__c == 'Completed' ||
                                result[i].visit.Status__c == 'Missed'
                        ) {
                            if (result[i].visit.Completed_Date__c === undefined) {
                                this.noVisitDate = true;
                                result[i].noVisitDate = this.noVisitDate;
                            }
                            this.pastVisits.push(result[i]);
                        }
                        this.visitTimezone = TIME_ZONE;
                        console.log('Time zone'+this.visitTimezone);
                        result[i].visitTimezone = this.visitTimezone;
                    }
                    if(!this.pastVisitId && this.pastVisits.length>0){
                        console.log('In past visits');
                        this.pastVisits = this.pastVisits.reverse();
                        this.pastVisitId = this.pastVisits[0].visit.Id;
                    }
                    if(!this.upcomingVisitId && this.upcomingVisits.length>0){
                        this.upcomingVisitId = this.upcomingVisits[0].visit.Id;
                        this.visitName = this.upcomingVisits[0].visit.Name;
                        this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
                    }
                    console.log('this.pastVisits:'+JSON.stringify(this.pastVisits));
                    this.initializeData(this.visitid);
                    this.createEditTask();
                }else{
                    this.contentLoaded = true;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    connectedCallback(){
        this.sfdcBaseURL = window.location.origin+basePathName+communicationPreference;
        this.callParticipantVisit();
        getSiteAddress()
        .then(result=>{
            var data = JSON.parse(result);
            this.siteAddress = data.accountAddress;
            this.siteName = data.accountName;
            this.sitePhoneNumber = data.accountPhone;
        })
        .catch(error=>{
            console.log('Error- Address'+JSON.stringify(error));
        })
    }
    
    onUpcomingClick(event){
        this.showChild = false;
        if(this.visitid){
            const theDiv = this.template.querySelector('[data-id="' +this.visitid+ '"]');
            console.log('theDiv'+theDiv);
            theDiv.className='inactiveCustomBoxclass';
        }
        this.template.querySelector('[data-id="upcoming"]').className = 'slds-button slds-button_brand up-button active-button-background';
        this.template.querySelector('[data-id="past"]').className = 'slds-button slds-button_neutral past-button inactive-button-background';
        this.showUpcomingVisits = true;
        if(this.upcomingVisits.length>0){
            this.visitid = this.upcomingVisitId;
            this.visitName = this.upcomingVisits[0].visit.Name;
            this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
            this.visitStatus = this.upcomingVisits[0].visit.Status__c;
            this.past = false;
            this.createEditTask();
        }
    }

    onPastClick(event){
        this.showChild = false;
        if(this.visitid){
            const theDiv = this.template.querySelector('[data-id="' +this.visitid+ '"]');
            console.log('theDiv'+theDiv);
            theDiv.className='inactiveCustomBoxclass';
        }
        this.template.querySelector('[data-id="past"]').className = 'slds-button slds-button_brand past-button active-button-background';
        this.template.querySelector('[data-id="upcoming"]').className = 'slds-button slds-button_neutral up-button inactive-button-background';
        this.showUpcomingVisits = false;
        if(this.pastVisits){
            this.visitid = this.pastVisitId;
            this.visitName = this.pastVisits[0].visit.Name;
            this.plannedDate = this.pastVisits[0].visit.Planned_Date__c;
            this.visitStatus = this.pastVisits[0].visit.Status__c;
            this.past = true;
            this.createEditTask();
        }
    }

    onVisitSelect(event){
        var index = event.currentTarget.dataset.index;
        console.log('Index:'+index);
        var past = event.currentTarget.dataset.past;
        console.log('past'+past);
        const theDiv = this.template.querySelector('[data-id="' +this.visitid+ '"]');
        console.log('theDiv'+theDiv);
        theDiv.className='inactiveCustomBoxclass';
        if(past=="true"){
            this.past = true;
            this.visitid = this.pastVisits[index].visit.Id;
            this.visitName = this.pastVisits[index].visit.Name;
            this.plannedDate = this.pastVisits[index].visit.Planned_Date__c;
            this.visitStatus = this.pastVisits[index].visit.Status__c;
        }else{
            console.log('In else');
            this.visitid = this.upcomingVisits[index].visit.Id;
            this.visitName = this.upcomingVisits[index].visit.Name;
            this.selectedIndex = index;
            this.past = false;
        }
        this.taskSubject = event.currentTarget.dataset.name;
        this.createEditTask();
        const objChild = this.template.querySelector('c-pp-R-R-Icon-Splitter');
        objChild.resetValues();
        this.initializeData(this.visitid);
    }

    handleDataUpdate(){
        console.log('handleDataupdate');
        this.createEditTask();
    }

    createEditTask(index){
        this.contentLoaded = false;
        this.showreminderdatepicker = false;
        if(this.visitid){
            getParticipantVisitsDetails({
                visitId : this.visitid
            })
            .then(result=>{
                var str = '{"Id":"","Patient_Visit__c":"","Reminder_Date__c":"","ReminderDateTime":"","Remind_Me__c":"","Remind_Using_Email__c":false,"Remind_Using_SMS__c":false}';
                var jsonstr = JSON.stringify(result[0]);
                const obj = JSON.parse(jsonstr);
                if(typeof result[0].task === 'undefined'){
                    obj.task = JSON.parse(str);
                }
                if(typeof result[0].visitDate === 'undefined'){
                    obj.visitDate = "";
                }
                this.visitdata = obj;
                console.log('this.visitData'+JSON.stringify(this.visitdata));
                this.taskId = this.visitdata.task.Id;
                const theDiv = this.template.querySelector('[data-id="' +this.visitid+ '"]');
                console.log('theDiv'+theDiv);
                theDiv.className='activeCustomBoxclass';
                this.upcomingVisits[this.selectedIndex].visit.Planned_Date__c = this.visitdata.visitDate;
                this.upcomingVisits[this.selectedIndex].visit.Completed_Date__c = this.visitdata.visit.Completed_Date__c;
                this.plannedDate = this.upcomingVisits[this.selectedIndex].visit.Planned_Date__c;
                this.contentLoaded = true;
                this.showChild = true;
                console.log('Test');
                this.template.querySelector('c-pp-Study-Visit-What-To-Expect').callFromParent();
            })
            .catch(error=>{
                this.error = error;
            })    
        }else{
            this.contentLoaded = true;
        }    
    }

    initializeData(visitid) {
        this.initialized = 'false';
        getIcon({
            visitId: visitid 
        })
            .then((result) => {
                this.icondetails = result;
                if (result.length === 0) {
                    this.isError = true;
                } else {
                    this.isError = false;
                }
                let iconNames = '';
                for (let i = 0; i < result.length; i++) {
                    iconNames += result[i].icons + ';';
                }
            })
            .catch((error) => {
                this.showErrorToast('error occured', error.message, 'error');
            });
    }

    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
}