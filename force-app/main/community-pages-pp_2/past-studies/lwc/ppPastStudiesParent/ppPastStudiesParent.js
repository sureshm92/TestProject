import { LightningElement } from 'lwc';
import getStudyData from '@salesforce/apex/ppPastStudiesTabUtility.getStudyData';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import con_icons from '@salesforce/resourceUrl/contact_support_icons';
import PP_SwitchStudyProgram from '@salesforce/label/c.PP_SwitchStudyProgram';
import PP_Past_Studies_Page_Header from '@salesforce/label/c.PP_Past_Studies_Page_Header';
import PP_Overview from '@salesforce/label/c.PP_Overview';
import Your_participation_is_complete from '@salesforce/label/c.Your_participation_is_complete';
import Participation_complete_description from '@salesforce/label/c.Participation_complete_description';
import PP_Resource_Documents from '@salesforce/label/c.PP_Resource_Documents';
import No_Documents_Available from '@salesforce/label/c.No_Documents_Available';
import PP_MyFiles from '@salesforce/label/c.PP_MyFiles';
import Visit_Results_Dashboard_My_Results from '@salesforce/label/c.Visit_Results_Dashboard_My_Results';
import PP_No_results_available from '@salesforce/label/c.PP_No_results_available';
import PP_Care_Team_Contact from '@salesforce/label/c.PP_Care_Team_Contact';
import PP_Phone_In_Caps from '@salesforce/label/c.PP_Phone_In_Caps';
import PP_Visit_Result_Value_Not_Available from '@salesforce/label/c.PP_Visit_Result_Value_Not_Available';
import PP_EMAIL_caps from '@salesforce/label/c.PP_EMAIL_caps';
import PP_Past_Messages from '@salesforce/label/c.PP_Past_Messages';
import Back_to_Past_Studies_and_Programs from '@salesforce/label/c.Back_to_Past_Studies_and_Programs';
import PP_Communications from '@salesforce/label/c.PP_Communications';

export default class PpPastStudiesParent extends LightningElement {
    hideDetailPage = false;
    showMenu = false;
    sectionList = [];
    selectedSection = PP_Overview;
    showOverview = false;
    showDoc = false;
    showFiles = false;
    showResults = false;
    showComm = false;
    showFilePage = false;
    contID;
    isDelegate = false;
    perList=[];
    selectedPER;
    studyPERMap = new Map();
    sycnDropDown = pp_icons + '/' + 'arrow2-sync.svg';
    noDocsIcon = pp_icons + '/' + 'no-docs.svg';
    noFilesIcon = pp_icons + '/' + 'no-files.svg';
    noMessagesIcon = pp_icons + '/' + 'no-messages.svg';
    noResultsIcon = pp_icons + '/' + 'no-results.svg';
    winnersIcon = pp_icons + '/' + 'winners.svg';
    copyIconUrl =  `${pp_icons + '/copy.svg'}#copy`;
    copiedIcon = con_icons + '/copied.svg';
    uploadedFilesClass;
    sharedFilesClass;
    label={
        PP_SwitchStudyProgram,
        PP_Overview,
        Your_participation_is_complete,
        Participation_complete_description,
        PP_Resource_Documents,
        No_Documents_Available,
        PP_MyFiles,
        Visit_Results_Dashboard_My_Results,
        PP_No_results_available,
        PP_Care_Team_Contact,
        PP_Phone_In_Caps,
        PP_Visit_Result_Value_Not_Available,
        PP_EMAIL_caps,
        PP_Past_Messages,
        Back_to_Past_Studies_and_Programs
    };
    connectedCallback() {
        window.addEventListener('resize', this.windowResize);   
        this.showMenu = window.innerWidth<1024;
        this.renderSections();
        
        this.sectionList.push({id: PP_Overview , class :'selected'});
        
        if (!communityService.isDummy()) {
            if (communityService.getCurrentCommunityMode().currentDelegateId) {
                this.isDelegate = true;
                this.contID = communityService.getCurrentCommunityMode().currentDelegateId;
            } else {
                this.contID = communityService.getParticipantData().currentContactId;
            }
            getStudyData({
                contID: this.contID,
                isDelegate: this.isDelegate
            }).then((result) => {
                this.perList = JSON.parse(JSON.stringify(result));
                console.log(JSON.stringify(result));
            })
            .catch((error) => {
                console.error('Error:', error);
            });
        }
    }
    windowResize = () => {
        this.showMenu = window.innerWidth<1024;
        this.renderSections();
    };
    selectStudy(event){
        this.updateSelectedStudy(event.target.dataset.item);
    }
    updateSelectedStudy(perid){
        this.hideDetailPage=true;
        this.uploadedFilesClass='no-show-link';
        this.sharedFilesClass='no-show-link';
        for (let i = 0; i < this.perList.length; i++) {
            this.studyPERMap.set(this.perList[i].Clinical_Trial_Profile__c, this.perList[i].Id);
            this.perList[i].class ='swt-study';
            if(perid == this.perList[i].Id){
                this.selectedPER = this.perList[i];
                this.perList[i].class ='swt-study selected'
                
                this.sectionList =[];        
                this.sectionList.push({id: PP_Overview , class :'selected'});
                this.selectedSection = PP_Overview;
                this.renderSections();
                if(this.selectedPER.Clinical_Trial_Profile__r.Study_Documents_Are_Available__c)
                    this.sectionList.push({id: PP_Resource_Documents , class :''});
                this.sectionList.push({id: PP_MyFiles , class :''});
                if(this.selectedPER.Clinical_Trial_Profile__r.Visit_Data_Shareback__c)
                    this.sectionList.push({id: Visit_Results_Dashboard_My_Results , class :''});
                this.sectionList.push({id: PP_Communications , class :''});
                
                if(this.template.querySelector('.switcher'))
                    this.template.querySelector('.switcher').blur();
            }
            clearTimeout(this.timeoutId); 
            this.timeoutId = setTimeout(this.showDetail.bind(this),250);
        }        
    }
    showDetail(){
        this.hideDetailPage=false;
    }
    removeStudy(){
        this.selectedPER = null;
        this.selectedSection = PP_Overview;
    }
    toggleOpt(){
        this.template.querySelector('.res-options').classList.toggle('slds-hide');
    }
    get showMenuOpt(){
        return this.showMenu && this.selectedPER;
    }
    sectionChange(event){
        this.selectedSection = event.target.dataset.item;
        this.renderSections();
    }
    renderSections(){
        this.showOverview = !this.showMenu || this.selectedSection == PP_Overview;
        this.showDoc = !this.showMenu || this.selectedSection == PP_Resource_Documents;
        this.showFiles = !this.showMenu || this.selectedSection == PP_MyFiles;
        this.showResults = !this.showMenu || this.selectedSection == Visit_Results_Dashboard_My_Results;
        this.showComm = !this.showMenu || this.selectedSection == PP_Communications;
        for (let i = 0; i < this.sectionList.length; i++) {
            this.sectionList[i].class ='';
            if(this.sectionList[i].id==this.selectedSection){
                this.sectionList[i].class ='selected';
            }
        }
        if(this.template.querySelector('.dropdown'))
            this.template.querySelector('.dropdown').blur();
    }
    get pageHeader(){
        if(this.selectedPER){
            return this.selectedPER.Clinical_Trial_Profile__r.Study_Code_Name__c;
        }
        return PP_Past_Studies_Page_Header;
    }
    get showDetailPage(){
        if(this.selectedPER){
            return true;
        }
        return false;
    }
    toggleSwt(){
        this.template.querySelector('.swt-options').classList.toggle('slds-hide');
    }
    docContClass='slds-large-size--1-of-2 slds-size--1-of-1 file-container';
    bottonRightBoxClass = 'slds-large-size--2-of-5 slds-size--1-of-1 slds-grid slds-wrap box-right';
    get docFileClass(){
        if(this.selectedPER && this.selectedPER.Clinical_Trial_Profile__r.Study_Documents_Are_Available__c){
            this.docContClass ='slds-large-size--1-of-2 slds-size--1-of-1 file-container';
            this.bottonRightBoxClass = 'slds-large-size--2-of-5 slds-size--1-of-1 slds-grid slds-wrap box-right';
            return 'slds-large-size--3-of-5 slds-size--1-of-1 slds-grid slds-wrap'
        }
        this.docContClass ='slds-size--1-of-1 file-container file-container-left';
        this.bottonRightBoxClass = 'slds-large-size--2-of-5 slds-size--1-of-1 slds-grid slds-wrap';
        return 'slds-large-size--2-of-6 slds-size--1-of-1 slds-grid slds-wrap';
    }
    copyEmailPhone(event){
        console.log('copy this::'+event.currentTarget.dataset.id);
        event.currentTarget.classList.add("copying");        
        try{
            clearTimeout(this.timeoutId); 
            this.timeoutId = setTimeout(this.copied.bind(this),2000); 
            this.docopy(event.currentTarget.dataset.id);
        } catch (error) {
            console.error(error);
        } 
    }
    docopy(data){
        const input = document.createElement("textarea");
        input.innerHTML = data;

        document.body.appendChild(input);
        input.select();

        if(navigator.clipboard){
            const selection = document.getSelection();
        } else {
            // deprecated but still a good fallback because it is supported in most of the browsers
            document.execCommand('copy');
        }
        document.body.removeChild(input);
    }
    copied() {
        var e = this.template.querySelectorAll(".copying");
        for(let i=0; i< e.length ; i++){
            e[i].classList.remove("copying");   
        }
    }
    showViewMore(event){
        if(event.detail.message=='shared'){
            this.sharedFilesClass='show-link';
        }
        if(event.detail.message=='uploaded'){
            this.uploadedFilesClass='show-link';
        }
    }
    viewFile(){
        const topDiv = this.template.querySelector('[data-id="top"]');
        topDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
        this.showFilePage=true;
    }
    slectStudyFormFiles(event){
        if(event.detail.message!=this.selectedPER.Clinical_Trial_Profile__c){
            this.updateSelectedStudy(this.studyPERMap.get(event.detail.message));
        }
        this.showFilePage=false;
    }
}