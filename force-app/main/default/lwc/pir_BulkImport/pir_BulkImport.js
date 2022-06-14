import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getStudyStudySiteDetails from "@salesforce/apex/PIR_BulkImportController.getStudyStudySiteDetails";
export default class Pir_BulkImport extends NavigationMixin(LightningElement) {
    @api myStudiesPg = false;
    @api studylist;
    siteAccessLevels;
    studyToStudySite;
    studysiteaccess=false;
    selectedSite='';
    studySiteList;
    selectedStudy='';
    currentPageReference = null; 
    urlStateParameters = null;
    urlmyStudies = null;
    urlmyParticipants = null;
    urltrialId = null;
    urlsiteId = null;
 
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
    setParametersBasedOnUrl() {
       this.urlmyStudies = this.urlStateParameters.myStudies || null;
       this.urlmyParticipants = this.urlStateParameters.myParticipants || null;
       this.urltrialId = this.urlStateParameters.trialId || null;
       this.urlsiteId = this.urlStateParameters.ssId || null;
     
       if(this.urlmyStudies){
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

                    if(this.myStudiesPg){
                        this.selectedStudy = this.urltrialId; 
                        var accesslevels = Object.keys(this.siteAccessLevels).length; 
                        var conts = this.studyToStudySite;
                        let options = []; 
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
        this.selectedSite = '';
        this.studysiteaccess = false;
    
      }
    studysitehandleChange(event) {
        this.selectedSite = event.target.value;
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
}