import { api, LightningElement } from 'lwc';
import generateProgressBar from '@salesforce/apex/PP_ProgressBarUtility.generateProgressBar';
import updatePatientVisit from '@salesforce/apex/PP_ProgressBarUtility.updatePatientVisit';
import ppProgressBarIcons from '@salesforce/resourceUrl/ppProgressBarIcons';
import Stay_Tuned from '@salesforce/resourceUrl/Pre_Trial_Stay_Tuned';
import Status_Check from '@salesforce/resourceUrl/Pre_Trial_Status_Show';
import PP_Event_Completion_Warning_Message from '@salesforce/label/c.PP_Event_Completion_Warning_Message';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import Mark_As_Completed from '@salesforce/label/c.BTN_Mark_As_Completed';
import BTN_Continue from '@salesforce/label/c.Continue';
import PP_ProgressBar_No_Visit from '@salesforce/label/c.PP_ProgressBar_No_Visit';
import PP_ProgressBar_Event_Complete from '@salesforce/label/c.PP_ProgressBar_Event_Complete';
import Stay_Tune_Label from '@salesforce/label/c.Pre_Trial_Stay_Tune';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class PpProgressBar extends LightningElement {
    userTimezone = TIME_ZONE;
stayTunedIcon = Stay_Tuned;
    statusCheckIcon = Status_Check;
    @api
    parentClass = 'big';
    layoutClass1 = 'slds-col slds-large-size_2-of-5 slds-size_1-of-1';
    layoutClass2 = 'slds-col slds-large-size_3-of-5 slds-size_1-of-1';
    layoutClass3 = 'slds-col slds-large-size_2-of-7 slds-size_1-of-1';
    
    icon = {
        recentlyCompletedActive : ppProgressBarIcons+'/recentlyCompletedActive.svg',
        recentlycompleted : ppProgressBarIcons+'/recentlycompleted.svg',
        mountain : ppProgressBarIcons+'/mountain.svg',
        futureActive : ppProgressBarIcons+'/futureActive.svg',
        emptyState : ppProgressBarIcons+'/emptyState.svg',
        completedState : ppProgressBarIcons+'/completedState.svg',
        completedActive : ppProgressBarIcons+'/completedActive.svg',
        carOrange : ppProgressBarIcons+'/carOrange.svg',
        carGrey : ppProgressBarIcons+'/carGrey.svg',
        activeIndicator : ppProgressBarIcons+'/activeIndicator.svg',
        unavailable : ppProgressBarIcons+'/unavailable.svg',
        unavailableActive : ppProgressBarIcons+'/unavailableActive.svg',
        open_in_new_Icon : ppProgressBarIcons+'/open_in_new_Icon.svg'
    };
    iconInverse = new Map([
        [ppProgressBarIcons+"/recentlyCompletedActive.svg",ppProgressBarIcons+"/recentlycompleted.svg"],
        [ppProgressBarIcons+"/recentlycompleted.svg",ppProgressBarIcons+"/recentlyCompletedActive.svg"],
        [ppProgressBarIcons+"/futureActive.svg",ppProgressBarIcons+"/emptyState.svg"],
        [ppProgressBarIcons+"/emptyState.svg",ppProgressBarIcons+"/futureActive.svg"],
        [ppProgressBarIcons+"/completedState.svg",ppProgressBarIcons+"/completedActive.svg"],
        [ppProgressBarIcons+"/completedActive.svg",ppProgressBarIcons+"/completedState.svg"],
        [ppProgressBarIcons+"/carOrange.svg",ppProgressBarIcons+"/carGrey.svg"],
        [ppProgressBarIcons+"/carGrey.svg",ppProgressBarIcons+"/carOrange.svg"],
        [ppProgressBarIcons+"/unavailable.svg",ppProgressBarIcons+"/unavailableActive.svg"],
        [ppProgressBarIcons+"/unavailableActive.svg",ppProgressBarIcons+"/unavailable.svg"]
    ]);
    label = {
        BTN_Cancel,
        PP_Event_Completion_Warning_Message,
        Mark_As_Completed,
        BTN_Continue,
        PP_ProgressBar_No_Visit,
        PP_ProgressBar_Event_Complete,
        Stay_Tune_Label
    };
    @api
    parentWrapper ;
    bars;
    barsToShow;
    currentCard ;
    showMarkAsCompletePopUp = false;
    showSpinner = false;
    peId;
    @api
    get perid() {
        return this.peId;
    }
    set perid(value) {
        this.peId = value;
        this.initCmp();
    }
    initCmp(){
        var value = this.peId;
        generateProgressBar({ peId: value })
        .then(result => {
            this.parentWrapper = result;
            if(result){
                this.currentCard = result.currentStatusVal;
                this.setBars(result.currentStatusVal);
                this.showSpinner = false;
            }
            else{
                const emptyEvent = new CustomEvent('progressbarempty', {
                    detail: null
                });
                this.dispatchEvent(emptyEvent);
            }
        })
        .catch(error => {            
            console.log(error);
            const emptyEvent = new CustomEvent('progressbarempty', {
                detail: null
            });
            this.dispatchEvent(emptyEvent);
        });
        if(this.parentClass!='big'){
            this.layoutClass1 = 'slds-col slds-size_1-of-1';
            this.layoutClass2 = 'slds-col slds-size_1-of-1';
            this.layoutClass3 = 'slds-col slds-size_1-of-1';
        }
    }
    setBars(setActive){
        this.bars =[];
        for(let i = 0 ; i<this.parentWrapper.progressWrapperList.length ; i ++){
            let li = this.parentWrapper.progressWrapperList[i];
            var bar = {};            
            bar.id = i;
            bar.iconClass = 'prIcon';
            if(li.stepVal == 0){
                //current
                bar.iconUrl = this.icon.carOrange;
                bar.iconUrl = (li.status == 'UNAVAILABLE' ? this.icon.unavailableActive : bar.iconUrl);
                bar.iconUrl = (li.status == 'COMPLETED' ? this.icon.completedActive : bar.iconUrl);
                bar.iconClass = (li.status == 'COMPLETED' || li.status == 'UNAVAILABLE' ? 'prIcon prIconActive' : bar.iconClass);
            }
            else if(li.stepVal > 0){
                //future
                bar.iconUrl = this.icon.emptyState;
            }
            else if(li.stepVal < 0){
                //past
                bar.iconUrl = this.icon.completedState;
            }
            bar.iconUrl = (li.status == 'UNAVAILABLE' && li.stepVal != 0 ? this.icon.unavailable : bar.iconUrl);
            bar.iconUrl = (li.status == 'COMPLETED' && li.stepVal != 0 ? this.icon.completedState : bar.iconUrl);
            if(i+2 == setActive && bar.iconUrl == this.icon.completedState ){//recent past
                bar.iconUrl = this.icon.recentlycompleted;
            }                     
            if(this.parentWrapper.progressWrapperList.length == i+1 && bar.iconClass.includes('prIconActive') && li.status == 'COMPLETED'){
                bar.iconUrl = this.icon.recentlyCompletedActive;
                if(this.bars[i-1]){
                    if(this.bars[i-1].iconUrl == this.icon.recentlycompleted){
                        this.bars[i-1].iconUrl = this.icon.completedState; 
                    }
                }
            }
            this.bars.push(bar); 
        }
        this.selectBarsToDisplay();
    }   
    next(){
        this.bars[this.currentCard-1] = this.toggleBarUX(this.bars[this.currentCard-1]);
        this.bars[this.currentCard] = this.toggleBarUX(this.bars[this.currentCard]);
        this.currentCard++;        
        this.selectBarsToDisplay();

    }
    prev(){
        this.bars[this.currentCard-1] = this.toggleBarUX(this.bars[this.currentCard-1]);
        this.bars[this.currentCard-2] = this.toggleBarUX(this.bars[this.currentCard-2]);
        this.currentCard--;
        this.selectBarsToDisplay();
    }
    toggleBarUX(bar){
        bar.iconUrl = this.iconInverse.get(bar.iconUrl);
        bar.iconClass = "prIcon"; 
        if(bar.iconUrl.includes("Active")){
            bar.iconClass = "prIcon prIconActive";
        }
        return bar;
    }
    selectBarsToDisplay(){
        this.barsToShow = null;
        let temp = [];
        let startIndex = 0;
       
        if(this.currentCard>5){
            startIndex = this.currentCard-5;
        }
        let endIndex = startIndex+5;
        if(this.bars.length<5){
            endIndex = this.bars.length;
        }
        for(startIndex ; startIndex<endIndex; startIndex++){
            temp.push(this.bars[startIndex]);
        }
        this.barsToShow = temp;
    }
    handleMarkAsComplete(){
        this.showMarkAsCompletePopUp = !this.showMarkAsCompletePopUp;
    }
    markEventAsComplete(event){
        updatePatientVisit({ patientVisitId: this.parentWrapper.progressWrapperList[this.currentCard-1].recordId })
        .then(result => {
            this.showNotification('',"Event marked as complete","success");
        })
        .catch(error => {
            this.showNotification('',"Event could not be marked as complete","error");
        });
        this.handleMarkAsComplete();
        this.showSpinner = true;
        setTimeout(()=>{this.initCmp();}, 1000);
    }
    showNotification(_title,_message,_variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
    learnMore(){
        if(this.parentWrapper.journeyLink != null){
            window.open(this.parentWrapper.journeyLink);
        } 
    }
    get title(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1])
            return this.parentWrapper.progressWrapperList[this.currentCard-1].title;
        return null;
    }
    get description(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1])
            return this.parentWrapper.progressWrapperList[this.currentCard-1].description;
        return null;
    }
    get barStatus(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1])
            return this.parentWrapper.progressWrapperList[this.currentCard-1].status;
        return null;
    }
    get barStatusDate(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1])
            return this.parentWrapper.progressWrapperList[this.currentCard-1].statusDate;
        return null;
    }
get showMarkAsComplete(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1] && !this.parentWrapper.isPreTiral)
            return (this.parentWrapper.isEvent && (!this.parentWrapper.progressWrapperList[this.currentCard-1].statusDate));
        return null;
    }
    get markAsCompleteWarnMessage(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1])
            return this.label.PP_Event_Completion_Warning_Message.replace("--",this.parentWrapper.progressWrapperList[this.currentCard-1].title);
        return null;
    }
    get subStatusAvailable(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1])
            return this.parentWrapper.progressWrapperList[this.currentCard-1].statusWrapperList != undefined ? this.parentWrapper.progressWrapperList[this.currentCard-1].statusWrapperList : null;
        return null;
    }
    get isPreTrial(){
        if(this.parentWrapper)
            return this.parentWrapper.isPreTiral;
        return false;
    }
    get showStatus(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1] && !this.parentWrapper.isPreTiral)
            return (!this.parentWrapper.isEvent  || (this.parentWrapper.isEvent && (this.parentWrapper.progressWrapperList[this.currentCard-1].statusDate)));
        return false;
    }
    get totalProgressSteps(){
        return (this.bars!=null ? this.bars.length : '');
    }
    get layout2Class(){
        if(this.parentWrapper.isPreTiral && this.parentClass=='big'){
            this.layoutClass2 = 'slds-col slds-large-size_5-of-7 slds-size_1-of-1';
        }
        return this.layoutClass2;
    }
    get leftDesktopClass(){
        if(this.parentWrapper.progressWrapperList[this.currentCard-1] && !this.parentWrapper.isPreTiral){
            if(this.currentCard==1){
                return "arrowCont slds-align-top disableClick"; 
            }
            return "arrowCont slds-align-top";
        }
        if(this.currentCard==1){
            return "arrowContOptB slds-align-top disableClick"; 
        }
        return "arrowContOptB slds-align-top";
    }
    get rightDesktopClass(){
let customCSS = 'tRight slds-align-top';
        if(this.parentWrapper.progressWrapperList[this.currentCard-1] && !this.parentWrapper.isPreTiral){
            customCSS = 'arrowCont '+customCSS;
        }else{
            customCSS = 'arrowContOptB '+customCSS;
        }
        if(this.currentCard==this.parentWrapper.progressWrapperList.length){
            return customCSS+' disableClick'; 
        }
        return customCSS;
        
    }
    get leftMobileClass(){
        if(this.currentCard==1){
            return "arrowMob disableClick"; 
        }
        return "arrowMob";
    }
    get rightMobileClass(){
        if(this.currentCard==this.parentWrapper.progressWrapperList.length){
            return "arrowMob tRight disableClick"; 
        }
        return "arrowMob tRight";
    }
    get middleDesktopClass(){
        if(this.parentWrapper.isPreTiral){
            return "rBMain tCenter orderA"; 
        }
        return "rMain";
    }
    get progressSteps(){
        if(this.parentWrapper.isPreTiral){
            return "progressBPath orderB";
        }
        return "progress"; 
    }
	get leftBoxClass(){
        if(this.parentWrapper.isPreTiral){
            return "leftBBox";
        }
        return "leftBox"; 
    }
	get leftSectionDescription(){
        if(this.parentWrapper.isPreTiral){
            return "leftBSectionDescription";
        }
        return "leftDescription";
    }
    get leftTitle() {
        return (this.parentWrapper.isPreTiral? "leftPreTrailTitle" : "leftTitle");
    }
}