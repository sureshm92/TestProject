import { LightningElement,api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import xlsxmin from '@salesforce/resourceUrl/xlsxmin';
import PIR_Community_CSS from '@salesforce/resourceUrl/PIR_Community_CSS'; 
import DownloadParticipantTemplate from '@salesforce/resourceUrl/PARTICIPANTS_TEMPLATE'; 
import ParticipantBulkImportInstructions from '@salesforce/resourceUrl/Instructions'; 
import { loadStyle } from 'lightning/platformResourceLoader';
import PIR_Study_Site_Name from '@salesforce/label/c.PIR_Study_Site_Name';
import PIR_Study_Name from '@salesforce/label/c.PIR_Study_Name';
import CC_Study from '@salesforce/label/c.CC_Study';
import PG_AC_Select from '@salesforce/label/c.PG_AC_Select';
import Janssen_Community_Template_Name from '@salesforce/label/c.Janssen_Community_Template_Name';
import getParticipantsStatusesAndVisitPlans from '@salesforce/apex/PIR_HomepageController.getParticipantsStatusesAndVisitPlans';
import deleteFile from '@salesforce/apex/PIR_HomepageController.deleteFile';
import saveTheChunkFile from '@salesforce/apex/PIR_HomepageController.saveTheChunkFile';
import uploadParticipants from '@salesforce/apex/PIR_HomepageController.uploadParticipants';
import getStudyStudySiteDetails from "@salesforce/apex/PIR_HomepageController.getStudyStudySiteDetails";
import getISOLanguage from "@salesforce/apex/PIR_HomepageController.getISOLanguage";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const CHUNK_SIZE = 9000; 

export default class Pir_importParticipant extends NavigationMixin(LightningElement) {
@api importParticipant=false; @api isMyStudies = false;@api studyid;@api siteid;
@api selectedStudy='';@api selectedSite=''; @api studylist;@api siteAccessLevels;@api studyToStudySite;
studySiteList;shouldDisableImportStatus = true;@api studysiteaccess=false;
@api selectedStatus; importParticipantStatus = [];shouldDisableImport = true;
progress = 0;
progressWidth = 'width :0%';
base = 1;
progressMultiplier = 0;
fileName = '';
filesUploaded = [];
isLoading = false;
fileSize;
fileId = '';
csvData = '';
totalRecords = 0;
fileLength = 0;
validFile = true; 
@api stringArray = '';
isEmail = false;
doContact = false;
isPhone = false;
isSMS = false;
createUsers = false;
iqviaOutreachEmail = false;
iqviaOutreachSMS = false;
iqviaOutreachPhone = false;
iqviaOutreachDirectMail = false;
isSuppressed = true;
isStudyPPEnabled = false;
disablePatientInvite = true;
isDataLoading = false;
isFileLoadedComplete = false;
visitPlanAvailable = false;
visitPlanDisabled = false;
selectedvisitPlanId = undefined;
visitPlanRequired = false;
visitPlansLVList = [];

downloadTemplate = DownloadParticipantTemplate;
ParticipantBulkImportInstructions = ParticipantBulkImportInstructions;

label = { PIR_Study_Site_Name,
          PIR_Study_Name,
          CC_Study,
          PG_AC_Select,
          Janssen_Community_Template_Name
        };
connectedCallback() {
    loadScript(this, xlsxmin).then(() => {});
    loadStyle(this, PIR_Community_CSS);
}
@wire(getStudyStudySiteDetails)
participantAccess({ error, data }) {
  if (data){
        this.isloading = true;
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
                this.studylist= studylist;
                this.siteAccessLevels = siteAccessLevels;
                this.studyToStudySite = studyToStudySite;
                this.studysiteaccess = true;
        }else{
            //this.showAddParticipant = false;
        }
        this.isloading = false;
  } else if (error) {
      this.error = error;
      this.isloading = false;
  }
}
get isMyStudiesPg(){
    if(this.isMyStudies){
        this.selectedStudy = this.studyid;
        this.selectedSite = this.siteid;
        if(this.selectedSite){
            getParticipantsStatusesAndVisitPlans({
            studySiteId: this.selectedSite 
            })
            .then((result) => {
            this.importParticipantStatus = result.participantStatuses;
            this.shouldDisableImportStatus = false;
            this.toggleImportButton();
            })
            .catch((error) => {
            console.error('Error: ', error);
            })
            } 
        return true;
    }else{
        return false;
    }
}
studyhandleChange(event) {
    this.isDataLoading = true;
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
    this.shouldDisableImportStatus = true;
    this.studysiteaccess = false;
    this.selectedStatus = '';
    this.isDataLoading = false;
    this.toggleImportButton();

}
generateISOLanguage(){
    console.log('>>>rgenerate iso called>>');
    getISOLanguage()
    .then((result) => {
        console.log('>>>result in iso>>'+result);
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (result == null || !result.length) {
            return;
         }
        columnDivider = ',';
        lineDivider =  '\n';
        //keys = ['Language','Language ISO Code'];
        keys = ['Language','LanguageISOcode'];

        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < result.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ; 
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
                if(result[i][skey] != undefined){
                    csvStringResult += '"'+ result[i][skey]+'"'; 
                }else{
                    csvStringResult += '"'+ '' +'"';
                }               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 

          var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvStringResult);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'ISO_Language_Guide.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
          hiddenElement.click(); // using click() js function to download csv file

    })
    .catch((error) => {
        console.log(">>error in Generating ISO>>>" + JSON.stringify(error));
      });

}







handleppinvite(event){
    this.createUsers = event.target.checked;
}
studysitehandleChange(event) {
    this.selectedSite = event.target.value;
    if(this.selectedSite){
        this.isDataLoading = true;
    getParticipantsStatusesAndVisitPlans({
    studySiteId: this.selectedSite 
    })
    .then((result) => {
        this.template.querySelector('[data-id="mainDivscroll"]').classList.remove('bulkautoScroll');
    this.importParticipantStatus = result.participantStatuses;
    this.shouldDisableImportStatus = false;
     
     var communityWithPPInv = communityService.getCurrentCommunityTemplateName() !=  this.label.Janssen_Community_Template_Name;
    
    if ( (result.objStudySite.Suppress_Participant_Emails__c || result.objStudySite.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c) 
            &&  result.objStudySite.Study_Site_Type__c == 'Traditional') 
    {
        this.isSuppressed = true;
    }
    else{
    this.isSuppressed = false;
    }

    if(result.objStudySite.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c == true && communityWithPPInv == true
        && result.objStudySite.Study_Site_Type__c != 'Hybrid' && result.objStudySite.Study_Site_Type__c != 'Virtual')
    {
        this.isStudyPPEnabled = true;
    }
    if(result.visitPlansLVList != undefined && result.visitPlansLVList.length >0){
       this.visitPlanAvailable = true;
        if(result.visitPlansLVList.length != 1){
            result.visitPlansLVList.push({label:'None',value:''});
        }else{
            this.visitPlanDisabled = true;
           this.selectedvisitPlanId = result.visitPlansLVList[0].value;
        }
    }
    console.log('>>selectedvisitPlanId>>'+this.selectedvisitPlanId);
    this.visitPlansLVList =  result.visitPlansLVList;   


    this.isDataLoading = false;
    this.toggleImportButton();

    })
    .catch((error) => {
    console.error('Error: ', error);
    })

    } 
}        
handleImportParticipantclose(){
    const custEvent = new CustomEvent('close');
    this.dispatchEvent(custEvent);
}

particiapntStatushandleChange(event){
    this.selectedStatus =  event.target.value;
    if((this.selectedStatus =='Enrollment Success' || this.selectedStatus =='Randomization Success') && 
       this.visitPlanDisabled == true){
        this.visitPlanRequired = true;
    }else{
    this.visitPlanRequired = false;
    }
    this.toggleImportButton();
}   
handleConsentChange(event){  
    console.log('>>event>>'+JSON.stringify(event.detail)); 

    this.isEmail = event.detail.consentMap.pe.Permit_Mail_Email_contact_for_this_study__c;
    this.doContact = event.detail.consentMap.pe.Permit_Mail_Email_contact_for_this_study__c;
    this.disablePatientInvite = !this.doContact;
   this.isPhone = event.detail.consentMap.pe.Permit_Voice_Text_contact_for_this_study__c;
   this.isSMS = event.detail.consentMap.pe.Permit_SMS_Text_for_this_study__c;
   console.log('>>>doContact>>'+this.doContact);
    if (!this.doContact) {
        this.createUsers = false;
    }    
    this.iqviaOutreachEmail = event.detail.consentMap.contact.Participant_Opt_In_Status_Emails__c;
    this.iqviaOutreachSMS = event.detail.consentMap.contact.Participant_Opt_In_Status_SMS__c;
    this.iqviaOutreachPhone = event.detail.consentMap.contact.Participant_Phone_Opt_In_Permit_Phone__c;
    this.iqviaOutreachDirectMail = event.detail.consentMap.contact.IQVIA_Direct_Mail_Consent__c;
    this.toggleImportButton();

  }

  toggleImportButton(){
    if(this.isFileLoadedComplete && this.selectedStudy && this.selectedSite && this.selectedStatus
    && this.doContact)
    {
    this.shouldDisableImport = false;

    }
    else { 
    this.shouldDisableImport = true;
    }
} 

 
deleteFiles(){
     this.isDataLoading = true;
      deleteFile({ 
          fileId: this.fileId   
      })
      .then(result => {
          this.template.querySelector(".fileInput").value=null; 
          this.template.querySelector(".fileInput").disabled = false;
          this.fileName = '';
          this.isFileLoadedComplete = false;
          this.progress = 0;
          this.progressWidth='width :0%';
          this.base = 1;
          this.progressMultiplier = 0;
          this.isDataLoading = false;
          this.isFileAdded = false;
          this.template.querySelector('[data-id="browsediv"]').classList.remove('disabledrag');
          this.toggleImportButton();
      })
      .catch(error => {
         this.isDataLoading = false;
          console.error('Error: ', error);
      })
      .finally(()=>{
         this.isDataLoading = false;
      })
}
  
handleFilesChange_new(event) {
      if (event.target.files.length > 0) {
          this.filesUploaded = event.target.files;
          this.template.querySelector('[data-id="browsediv"]').classList.add('disabledrag');
          event.target.disabled = true;
          this.fileName = event.target.files[0].name;
          this.isFileLoadedComplete = false;
          this.progress = 0;
          this.progressWidth = 'width :0%';
          this.base = 1;
          this.stringArray = '';
          this.totalRecords = 0;
          this.fileLength = 0;
          this.progressMultiplier = 0;
          this.saveFile();
      }
}
  
saveFile() {
      var fileCon = this.filesUploaded[0];
      this.fileSize = this.formatBytes(fileCon.size, 2);
      console.log('>>fileSize123>>'+this.fileSize);
      console.log('>>fileSize123>>'+this.fileName);
      console.log('>>fileSize123>>'+this.fileName.split('.')[1]);
      if (
          this.fileName.split('.')[1] != 'csv' &&
          this.fileName.split('.')[1] != 'xlsx' &&
          this.fileName.split('.')[1] != 'xls'
      ) {
          let message ="Please upload xls file";
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: message,
                  variant: 'error'
              })
          );
          this.template.querySelector('.fileInput').value = null;
          this.template.querySelector('.fileInput').disabled = false;
          this.fileName = '';
          this.isFileLoadedComplete = false;
          this.toggleImportButton();
          this.template.querySelector('[data-id="browsediv"]').classList.remove('disabledrag');
          return;
      }
  
       
  
      this.progressWidth = 'width :8%';
      this.progress = 8;
      this.base = Math.floor((CHUNK_SIZE / fileCon.size) * 100);
      var reader = new FileReader();
      var self = this;
      reader.onload = function () {
          var fileContents = reader.result;
          var base64Mark = 'base64,';
          var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
          fileContents = fileContents.substring(dataStart);
          self.upload(fileCon, fileContents);
      };
      var reader2 = new FileReader();
      reader2.onload = function (e) {
          try {
              var binary = '';
              var bytes = new Uint8Array(e.target.result);
              var length = bytes.byteLength;
              self.fileLength = length;
              for (var i = 0; i < length; i++) {
                  binary += String.fromCharCode(bytes[i]);
              }
              var workbook = XLSX.read(binary, { type: 'binary', raw: true });
              var sheet_name_list = workbook.SheetNames; 
              var csvData = XLSX.utils.sheet_to_csv(workbook.Sheets[sheet_name_list[0]]);
              self.stringArray = csvData.split('\n');
              console.log('>>>filebody373>>'+JSON.stringify(self.stringArray));
              self.totalRecords = self.stringArray.length;
              console.log('>>total records>>'+self.totalRecords);
              console.log('>>>filebody373>>'+JSON.stringify(self.stringArray));
               
          } catch (e) {
              console.log('error in reader2>>' + e.message);
          }
      };
      reader2.readAsArrayBuffer(fileCon);
      reader.readAsDataURL(fileCon);
}
get enableDel(){
    return this.progress == 100;
} 
  
upload(file, fileContents) {
    console.log('>>upload>>');
    var fromPos = 0;
    var toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
    this.uploadChunk(file, fileContents, fromPos, toPos, '');
}
  
uploadChunk(file, fileContents, fromPos, toPos, attachId) {
   // this.isLoading = true;
    var chunk = fileContents.substring(fromPos, toPos);
    console.log('>>upload>>');
    saveTheChunkFile({
        fileName: file.name,
        base64Data: encodeURIComponent(chunk),
        contentType: file.type,
        fileId: attachId
    })
        .then((result) => {
            this.fileId = result;
            attachId = result;
            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
            if (fromPos < toPos) {
                this.progressMultiplier++;
                if (this.base * this.progressMultiplier < 100) {
                    this.progress = this.base * this.progressMultiplier;
                } else {
                    this.progress = 99;
                }
                this.progressWidth = 'width :' + this.progress + '%';
                this.uploadChunk(file, fileContents, fromPos, toPos, attachId);
            } else if (this.totalRecords > 45005 || this.fileLength >4100226 ) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:'file contains more than 45,000 records; you may split the file. Please correct the problem and try again.',
                        variant: 'error'
                    })
                );
                this.deleteFiles();
               // this.isLoading = false;
                }
            else {
                    this.progress = 100;
                    this.progressWidth =
                        'width :' + this.progress + '%;background-color: #00C221;';
                        this.isFileLoadedComplete=true;
                        this.toggleImportButton();
                  //  this.isLoading = false;
                
            }
        })
        .catch((error) => {
            console.error('Error: ', error);
        })
        .finally(() => {});
}
  
formatBytes(bytes, decimals) {
    if (bytes == 0) return '0 Bytes';
    var k = 1024,
        dm = decimals || 2,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}

testValueComing(event){
    console.log('>>>>>fileBody>>'+JSON.stringify(this.stringArray))

}

doImportParticipant(){
  this.isDataLoading  = true;
   

    
    uploadParticipants({
        csvFileLines: this.stringArray,
        fileName:  this.fileName,
        studySiteId: this.selectedSite,
        selectedStatus: this.selectedStatus,
        createUsers: this.createUsers && this.communityWithPPInv,
        doContact: this.doContact,
        allowEmail: this.isEmail,
        allowPhone: this.isPhone,
        allowSMS: this.isSMS,
        outreachEmail : this.iqviaOutreachEmail,
        outreachPhone : this.iqviaOutreachPhone,
        outreachSMS : this.iqviaOutreachSMS,
        outreachDirectMail : this.iqviaOutreachDirectMail,
        visitPlanId: undefined
    })
    .then((result) => {

        console.log('>>result is>>'+result);
        this.isDataLoading  = false;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'bulk-imports'
              },
            state: {
              'myParticipants' : true
             }
        });
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'batch is processing success',
            variant: "success",
            mode: "dismissable"
          });
          this.dispatchEvent(evt);
          const custEvent = new CustomEvent('close');
          this.dispatchEvent(custEvent);


    })
    .catch((error) => {
        this.isDataLoading  = false;
        console.error('Error in executing batch ', error);
    })

}
 
  
 
  
}