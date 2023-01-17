import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import PIR_Community_CSS from '@salesforce/resourceUrl/PIR_Community_CSS';
import { loadStyle } from 'lightning/platformResourceLoader';
import AllStudy from "@salesforce/label/c.PIR_All_Study";
import AllStudySite from "@salesforce/label/c.PIR_All_Study_Site";
import PIR_Study_Name from "@salesforce/label/c.PIR_Study_Name";
import PIR_Study_Site_Name from "@salesforce/label/c.PIR_Study_Site_Name";
import My_Participant from "@salesforce/label/c.My_Participant";
import RH_RP_Bulk_Import from "@salesforce/label/c.RH_RP_Bulk_Import";
import Home_Page_Label from "@salesforce/label/c.Home_Page_Label";
import pir_Bulk_Import_History from "@salesforce/label/c.pir_Bulk_Import_History";
import getStudyStudySiteDetails from "@salesforce/apex/PIR_BulkImportController.getStudyStudySiteDetails";
export default class Pir_BulkImport extends NavigationMixin(LightningElement) {
    @api myStudiesPg = false;
    @api studylist;
    siteAccessLevels;
    studyToStudySite;
    studysiteaccess=false;
    isTable=true;
    selectedSite='';
    studySiteList;
    selectedStudy='';
    currentPageReference = null; 
    urlStateParameters = null;
    urlmyStudies = null;
    urlmyParticipants = null;
    urltrialId = null;
    urlsiteId = null;
    isResetPagination=false;
    calledfrombulkimporthistry = false;
    @api selectedStudyChild;
    @api selectedStudySiteChild;
    @api pageNumberChild=1;
    @api stopSpinnerChild;
    label = {AllStudy,
        AllStudySite,
        PIR_Study_Name,
        PIR_Study_Site_Name,
        My_Participant,
        pir_Bulk_Import_History,
        RH_RP_Bulk_Import,
        Home_Page_Label};
    codeTemp;
    connectedCallback() {
        loadStyle(this, PIR_Community_CSS)
    }

    renderedCallback(){
      if(this.urlStateParameters != null && this.urlStateParameters.random != null && this.codeTemp != this.urlStateParameters.random){
        this.codeTemp = this.urlStateParameters.random;
        this.selectedStudy = this.urlStateParameters.trialId;
        var picklist_Value = this.urlStateParameters.trialId;
        if (this.siteAccessLevels != undefined) {
            var accesslevels = Object.keys(this.siteAccessLevels).length;
            var conts = this.studyToStudySite;
            let options = [];
            options.push({ label: this.label.AllStudySite, value: "All Study Site" });
            var i = this.siteAccessLevels;
            for (var key in conts) {
              if (key == picklist_Value) {
                var temp = conts[key];
                for (var j in temp) {
                    if(accesslevels == 0){
                        options.push({ label: temp[j].Name, value: temp[j].Id });
                    }else{
                        var level = this.siteAccessLevels[temp[j].Id];
                        if(level != 'Level 3' && level != 'Level 2'){
                            options.push({ label: temp[j].Name, value: temp[j].Id });
                        }
                    }
                }
              }
            }
            this.studySiteList = options;
            this.selectedSite = this.urlStateParameters.ssId;
            var getStudySiteList=[];
            if (
                this.selectedSite != null &&
                this.selectedSite != "All Study Site"
              ) {
                this.template.querySelector("c-pir_-bulk-import-files").getStudySite=this.selectedSite;
              }
            this.template.querySelector("c-pir_-bulk-import-files").pageNumber =1;
            this.isResetPagination=true;
            this.template.querySelector("c-pir_-bulk-import-files").stopSpinner=false;
            this.template.querySelector("c-pir_-bulk-import-files").updateInProgressOldData();
            
            this.template.querySelector("c-pir_-bulk-import-files").fetchData();
            
        }
        
      }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) { 
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
    navigatingFromStudy=false;
    setParametersBasedOnUrl() {
       this.urlmyStudies = this.urlStateParameters.myStudies || null;
       this.urlmyParticipants = this.urlStateParameters.myParticipants || null;
       this.calledfrombulkimporthistry=this.urlStateParameters.navigateFromComponent  == 'BulkimportHistryPage' ? true : false;;
       this.urltrialId = this.urlStateParameters.trialId || null;
       this.urlsiteId = this.urlStateParameters.ssId || null;
      if(this.urlmyStudies || this.urlStateParameters.navigateFromComponent=='MyStudies' || this.urlStateParameters.navigateFromComponent=='MyStudiesBulk'){
        this.navigatingFromStudy=true;
      }
      else{
        this.navigatingFromStudy=false;
      }
     
      
       if(this.urlmyStudies ){
            this.myStudiesPg = true;
            this.selectedStudy = this.urltrialId;
       }else{
            this.myStudiesPg = false; 
       }
    }
    @wire(getStudyStudySiteDetails)
    participantAccess({ error, data }) {
      if (data){
            var siteAccessLevels = data.siteAccessLevels;
            var ctpListNoAccess = [];
            var studySiteMap = data;
            var studylist;
            var studyToStudySite;
            ctpListNoAccess = data.ctpNoAccess;
            var k = 0;var a = 0;
            
            var accesslevels = Object.keys(siteAccessLevels).length;
            if (studySiteMap.ctpMap) {
                var conts = studySiteMap.ctpMap;
                let options = [];
                options.push({ label: this.label.AllStudy, value: "All Study" });
                var sites = studySiteMap.studySiteMap; 
                for (var key in conts) {
                    if(!ctpListNoAccess.includes(conts[key])){ 
                        var temp = sites[conts[key]];
                        let z = 0;
                        for (var j in temp) {
                             if(accesslevels == 0){
                                z=z+1;
                                a=a+1;
                             }else{
                                var level = siteAccessLevels[temp[j].Id];
                                if(level != 'Level 3' && level != 'Level 2'){
                                    z=z+1;
                                    a=a+1;
                                }
                             }
                        }
                        if(z != 0){
                            options.push({ label: key, value: conts[key] });
                            k=k+1;
                        }
                    }
                }
                studylist = options;
                if (studySiteMap.studySiteMap) {
                    studyToStudySite = studySiteMap.studySiteMap;
                }
            }
            if(k != 0 && a != 0){
                    this.studylist = studylist;
                    this.siteAccessLevels = siteAccessLevels;
                    this.studyToStudySite = studyToStudySite;
                    this.studysiteaccess = true;
                    
                    if(this.myStudiesPg && this.urltrialId){
                        this.selectedStudy = this.urltrialId; 
                        var accesslevels = Object.keys(this.siteAccessLevels).length; 
                        var conts = this.studyToStudySite;
                        let options = []; 
                        options.push({ label: this.label.AllStudySite, value: "All Study Site" });
                        var i = this.siteAccessLevels;
                        for (var key in conts) {
                        if (key == this.urltrialId) {
                            var temp = conts[key];
                            for (var j in temp) {
                                if(accesslevels == 0){
                                    options.push({ label: temp[j].Name, value: temp[j].Id });
                                }else{
                                    var level = this.siteAccessLevels[temp[j].Id];
                                    if(level != 'Level 3' && level != 'Level 2'){
                                        options.push({ label: temp[j].Name, value: temp[j].Id });
                                    }
                                }
                            }
                        }
                        }
                        this.studySiteList = options;
                        this.selectedSite = this.urlsiteId;
                        this.studysiteaccess = false;
                        this.selectedStudySiteChild=this.selectedStudy;
                        this.selectedStudyChild=this.selectedSite;
                        this.stopSpinnerChild=false;
                      
                      
                      } 
                    else{
                        
                        this.selectedStudy = this.studylist[0].value; 
                        var picklist_Value;
                        picklist_Value=this.selectedStudy;
                        var accesslevels = Object.keys(this.siteAccessLevels).length;
                        var conts = this.studyToStudySite;
                        let options = [];
                        options.push({ label: this.label.AllStudySite, value: "All Study Site" });
                        var i = this.siteAccessLevels;
                        if (picklist_Value != "All Study") {
                            for (var key in conts) {
                              if (key == picklist_Value) {
                                var temp = conts[key];
                                for (var j in temp) {
                                    if(accesslevels == 0){
                                        options.push({ label: temp[j].Name, value: temp[j].Id });
                                    }else{
                                        var level = this.siteAccessLevels[temp[j].Id];
                                        if(level != 'Level 3' && level != 'Level 2'){
                                            options.push({ label: temp[j].Name, value: temp[j].Id });
                                        }
                                    }
                                }
                              }
                            }
                          } else {
                            for (var key in conts) {
                              var temp = conts[key];
                              for (var j in temp) {
                                if(accesslevels == 0){
                                    options.push({ label: temp[j].Name, value: temp[j].Id });
                                }else{
                                    var level = this.siteAccessLevels[temp[j].Id];
                                    if(level != 'Level 3' && level != 'Level 2'){
                                        options.push({ label: temp[j].Name, value: temp[j].Id });
                                    }
                                }
                              }
                            }
                          }
                        this.studySiteList = options;
                        this.selectedSite = this.studySiteList[0].value;
                        this.studysiteaccess = false;
                        this.selectedStudyChild=this.selectedStudy;
                        var getStudySiteList=[];
                        if (this.selectedSite != null && this.selectedSite == "All Study Site") {
                            for (var i = 1; i < this.studySiteList.length; i++) {
                              getStudySiteList.push(this.studySiteList[i].value);
                              this.selectedStudySiteChild=getStudySiteList;
                            }
                          } else if (
                            this.selectedSite != null &&
                            this.selectedSite != "All Study Site"
                          ) {
                            this.selectedStudySiteChild=getStudySiteList;
                          }

                          this.stopSpinnerChild=false;
                          
                    }
            }
      } else if (error) {
          this.error = error;
          console.log('error wire'+error);
      }
    }
    studyhandleChange(event) {
        var picklist_Value = event.target.value;
        this.selectedStudy = picklist_Value;
        
        
        var accesslevels = Object.keys(this.siteAccessLevels).length;
        var conts = this.studyToStudySite;
        let options = [];
        options.push({ label: this.label.AllStudySite, value: "All Study Site" });
        var i = this.siteAccessLevels;

        if (picklist_Value != "All Study") {
            for (var key in conts) {
              if (key == picklist_Value) {
                var temp = conts[key];
                for (var j in temp) {
                    if(accesslevels == 0){
                        options.push({ label: temp[j].Name, value: temp[j].Id });
                    }else{
                        var level = this.siteAccessLevels[temp[j].Id];
                        if(level != 'Level 3' && level != 'Level 2'){
                            options.push({ label: temp[j].Name, value: temp[j].Id });
                        }
                    }
                }
              }
            }
          } else {
            for (var key in conts) {
              var temp = conts[key];
              for (var j in temp) {
                if(accesslevels == 0){
                    options.push({ label: temp[j].Name, value: temp[j].Id });
                }else{
                    var level = this.siteAccessLevels[temp[j].Id];
                    if(level != 'Level 3' && level != 'Level 2'){
                        options.push({ label: temp[j].Name, value: temp[j].Id });
                    }
                }
              }
            }
          }
        this.studySiteList = options;
       
        this.selectedSite= this.studySiteList[0].value;
        this.studysiteaccess = false;
        this.template.querySelector("c-pir_-bulk-import-files").getStudy=this.selectedStudy;
        var getStudySiteList=[];
        if (this.selectedSite != null && this.selectedSite == "All Study Site") {
            for (var i = 1; i < this.studySiteList.length; i++) {
              getStudySiteList.push(this.studySiteList[i].value);
              this.template.querySelector("c-pir_-bulk-import-files").getStudySite=getStudySiteList;
            }
          } else if (
            this.selectedSite != null &&
            this.selectedSite != "All Study Site"
          ) {
            this.template.querySelector("c-pir_-bulk-import-files").getStudySite=this.selectedSite;
          }
          this.template.querySelector("c-pir_-bulk-import-files").pageNumber =1;
          this.isResetPagination=true;
          this.template.querySelector("c-pir_-bulk-import-files").stopSpinner=false;
          this.template.querySelector("c-pir_-bulk-import-files").updateInProgressOldData();
          this.template.querySelector("c-pir_-bulk-import-files").fetchData();
          
      
      }
     
    studysitehandleChange(event) {
        this.selectedSite = event.target.value;
        var getStudySiteList=[];
        if (this.selectedSite != null && this.selectedSite == "All Study Site") {
            for (var i = 1; i < this.studySiteList.length; i++) {
              getStudySiteList.push(this.studySiteList[i].value);
              this.template.querySelector("c-pir_-bulk-import-files").getStudySite=getStudySiteList;
            }
          } else if (
            this.selectedSite != null &&
            this.selectedSite != "All Study Site"
          ) {
            this.template.querySelector("c-pir_-bulk-import-files").getStudySite=this.selectedSite;
          }
        this.template.querySelector("c-pir_-bulk-import-files").pageNumber =1;
        this.isResetPagination=true;
        this.template.querySelector("c-pir_-bulk-import-files").stopSpinner=false;
        this.template.querySelector("c-pir_-bulk-import-files").updateInProgressOldData();
        
        this.template.querySelector("c-pir_-bulk-import-files").fetchData();
        
        
    }
    handleStudiesPg(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
              }
        });
    }
    handleParticipantPg(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'my-referrals'
              }
        });
    }
    //pagination
    totalRecord;
    showZeroErr  = false;
    initialLoad = true;
    page;
    pageChanged(event) {
      console.log('>>page changed called>>>');
      this.page = event.detail.page;
      this.template.querySelector("c-pir_-bulk-import-files").pageNumber =this.page;
        if(!this.initialLoad){
          console.log('>>>fetch page called>>>');
          this.template.querySelector("c-pir_-bulk-import-files").stopSpinner=false;
          this.template.querySelector("c-pir_-bulk-import-files").updateInProgressOldData();
          this.template.querySelector("c-pir_-bulk-import-files").fetchData();
        }
        this.initialLoad = false;
    }
    changePage(event) {
      let dir = event.detail;
      if (dir == "next") { 
        this.template.querySelector("c-pir_participant-pagination").nextPage();
      }
      if (dir == "prev") {
        this.template
          .querySelector("c-pir_participant-pagination")
          .previousPage();
      }
    }
    handleUpdate=false;
    handletotalrecord(event){
      this.totalRecord=event.detail;
      
      this.handleUpdate=true;
      this.handleresetpageonupdate();
      }
    isResetOnUpdate=false;
    handleresetpageonupdate(){
      if( this.handleUpdate && !this.isResetPagination ){
        this.initialLoad=true;
        this.template.querySelector("c-pir_participant-pagination").totalRecords=this.totalRecord;
        this.template.querySelector("c-pir_participant-pagination").updateInprogress();
        }
      this.handleUpdate=false;
      this.initialLoad=false; 

    }
    handleresetpagination(event){
      if(this.isResetPagination ){
        this.initialLoad = true;
        this.template.querySelector("c-pir_participant-pagination").totalRecords=this.totalRecord;
        this.template.querySelector("c-pir_participant-pagination").goToStart();
      }
      this.isResetPagination = false;  
    }
  
    
}