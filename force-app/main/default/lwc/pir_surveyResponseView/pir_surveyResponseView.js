import { LightningElement,api } from 'lwc';
import CP_See_if_You_Qualify_Test_Positive from '@salesforce/label/c.CP_See_if_You_Qualify_Test_Positive';
import CP_Symptoms_Yes from '@salesforce/label/c.CP_Symptoms_Yes';
import CP_Symptoms_No from '@salesforce/label/c.CP_Symptoms_No';
import CP_Test_Date from '@salesforce/label/c.CP_Test_Date';
import CP_Estimated_date_of_first_symptom from '@salesforce/label/c.CP_Estimated_date_of_first_symptom';
import CP_Estimated_date_of_last_symptom from '@salesforce/label/c.CP_Estimated_date_of_last_symptom';
import CP_Outside_Organization_Label from '@salesforce/label/c.CP_Outside_Organization_Label';
import CP_Referring_Organization from '@salesforce/label/c.CP_Referring_Organization';
import CP_Test_Result from '@salesforce/label/c.CP_Test_Result';

import getSurveyResponsecovid from "@salesforce/apex/MedicalHistryTabController.getSurveyResponsecovid"; 
 
export default class Pir_survey_response_view extends LightningElement {

    Label = {CP_See_if_You_Qualify_Test_Positive, 
            CP_Symptoms_Yes,
            CP_Symptoms_No,
            CP_Test_Date,
            CP_Estimated_date_of_first_symptom,
            CP_Estimated_date_of_last_symptom,
            CP_Outside_Organization_Label,
            CP_Referring_Organization,
            CP_Test_Result
    };

    surveyresponse;
    isloaded;
    hrefSrc ; 
    filename;
    

    @api
    selectedpeid;
    @api
    get checkSurvey(){return true;}
    set checkSurvey(value){
        this.dochecksurvey();
    }

    @api
    dochecksurvey(){ 
    this.isloaded = false;
       getSurveyResponsecovid({ perid : this.selectedpeid})
       .then(result => {
        this.surveyresponse = JSON.parse(result); 
        if(this.surveyresponse.entries.length > 0){
        this.hrefSrc = '/servlet/servlet.FileDownload?file='+ this.surveyresponse.entries[0].Id;
        this.filename = this.surveyresponse.entries[0].Name;
        }
        this.isloaded = true;

       })
       .catch(error => {
        console.log('>>error surevey>>>'+JSON.stringify(error)); 
        console.log('>>errorsurey jsonn>>>'+error);
    }) ; 
         
    }




}