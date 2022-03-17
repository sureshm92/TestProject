import { api, LightningElement, wire } from 'lwc';
import pirResources from '@salesforce/resourceUrl/pirResources';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ethinicity_field from '@salesforce/schema/Participant__c.Ethnicity__c';
import language_field from '@salesforce/schema/Contact.Language__c';
import phType_field from '@salesforce/schema/Participant__c.Phone_Type__c';
import getParticipantData from '@salesforce/apex/PIR_ParticipantDetailController.getParticipantData';
import getCnData from '@salesforce/apex/PIR_ParticipantDetailController.getCnData';
import doSaveParticipantDetails from '@salesforce/apex/PIR_ParticipantDetailController.doSaveParticipantDetails';
import checkExisitingParticipant from '@salesforce/apex/ParticipantInformationRemote.checkExisitingParticipant';
import getStudyAccessLevel from "@salesforce/apex/PIR_HomepageController.getStudyAccessLevel";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//Labels
import Gender_Female from '@salesforce/label/c.Gender_Female';
import Gender_Male from '@salesforce/label/c.Gender_Male';
import BTN_Participant_Information from '@salesforce/label/c.BTN_Participant_Information';
import PG_AS_F_First_name from '@salesforce/label/c.PG_AS_F_First_name';
import PG_AS_F_Middle_name from '@salesforce/label/c.PG_AS_F_Middle_name';
import PG_AS_F_Last_name from '@salesforce/label/c.PG_AS_F_Last_name';
import PG_AS_F_Suffix from '@salesforce/label/c.PG_AS_F_Suffix';
import PG_AS_F_Nickname from '@salesforce/label/c.PG_AS_F_Nickname';
import PG_AS_F_Date_of_Birth from '@salesforce/label/c.PG_AS_F_Date_of_Birth';
import PG_AP_F_Language from '@salesforce/label/c.PG_AP_F_Language';
import PIR_Gender from '@salesforce/label/c.PIR_Gender';
import PG_Ref_L_Primary_Delegate_Information from '@salesforce/label/c.PG_Ref_L_Primary_Delegate_Information';
import PG_AS_F_Email_address from '@salesforce/label/c.PG_AS_F_Email_address';
import PG_Ref_L_Primary_daytime_telephone_number from '@salesforce/label/c.PG_Ref_L_Primary_daytime_telephone_number';
import RH_YearofBirth from '@salesforce/label/c.RH_YearofBirth';
import RH_DelegateAttestation from '@salesforce/label/c.RH_DelegateAttestation';
import RH_MinorDelegateErrMsg from '@salesforce/label/c.RH_MinorDelegateErrMsg';
import PG_AP_F_Phone_Type from '@salesforce/label/c.PG_AP_F_Phone_Type';
import PE_Country from '@salesforce/label/c.PE_Country';
import PE_State from '@salesforce/label/c.PE_State';
import PG_AS_F_Zip_Postal_Code from '@salesforce/label/c.PG_AS_F_Zip_Postal_Code';
import PG_AP_H_Contact_Information from '@salesforce/label/c.PG_AP_H_Contact_Information';
import PG_AP_F_Alternative_Phone_Number from '@salesforce/label/c.PG_AP_F_Alternative_Phone_Number';
import PG_AP_F_Alternative_Phone_Type from '@salesforce/label/c.PG_AP_F_Alternative_Phone_Type';
import PG_AP_F_Screening_Subject_Id from '@salesforce/label/c.PG_AP_F_Screening_Subject_Id';
import FD_PE_Field_Arm_Cohort from '@salesforce/label/c.FD_PE_Field_Arm_Cohort';
import PG_AS_F_Participation_Information from '@salesforce/label/c.PG_AS_F_Participation_Information';
import Source_ID from '@salesforce/label/c.Source_ID';
import PG_AS_F_Source_ID_Help_Text from '@salesforce/label/c.PG_AS_F_Source_ID_Help_Text';
import PG_Ref_L_Information_Sharing from '@salesforce/label/c.PG_Ref_L_Information_Sharing';
import PG_Ref_L_Permit_IQVIA_Confirmation from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_Confirmation';
import PG_Ref_L_Permit_IQVIA_To_Contact_Email from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Contact_Email';
import PG_Ref_L_Permit_IQVIA_To_Contact_Phone from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Contact_Phone';
import PG_Ref_L_Permit_IQVIA_To_Contact_SMS from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Contact_SMS';
import Age from '@salesforce/label/c.Age';
import RH_Ethnicity from '@salesforce/label/c.RH_Ethnicity';
import PG_AP_F_Preferred_Contact_Time from '@salesforce/label/c.PG_AP_F_Preferred_Contact_Time';
import This_Participant_has_reached_legal_age_of_emancipation from '@salesforce/label/c.This_Participant_has_reached_legal_age_of_emancipation';
import BTN_Verify from '@salesforce/label/c.BTN_Verify';
import PG_MT_T_Your_permissions_do_not_permit_this_action from '@salesforce/label/c.PG_MT_T_Your_permissions_do_not_permit_this_action';

export default class Pir_participantDetail extends LightningElement {
    @api selectedPE;@api delegateLevels='';@api lststudysiteaccesslevel = [];
    @api 
    actionReq = false;
    notification = pirResources+'/pirResources/icons/bell.svg';
    disableSrc = false;
    disableScreening = false;
    delegateMinor =false;
    disableEdit = false;
    fieldMap = new Map([["src" , "MRN_Id__c"],
				["cnt" , "Permit_Mail_Email_contact_for_this_study__c"],
				["smscnt" , "Permit_SMS_Text_for_this_study__c"],
				["txtcnt" , "Permit_Voice_Text_contact_for_this_study__c"],
				["pid" , "Id"],
				["adult" , "Adult__c"],
				["firstname" , "First_Name__c"],
				["lastname" , "Last_Name__c"],
				["middlename" , "Middle_Name__c"],
				["fullname" , "Full_Name__c"],
				["nickname" , "Nickname__c"],
				["suffixname" , "Suffix__c"],
				["lang" , "Preferred_Language__c"],
				["dob" , "Date_of_Birth__c"],
				["gender" , "Gender__c"],
				["email" , "Email__c"],
				["phone" , "Phone__c"],
				["phonetype" , "Phone_Type__c"],
				["altph" , "Alternative_Phone_Number__c"],
				["altphtype" , "Alternative_Phone_Type__c"],
				["prefCntTime" , "Preferred_Contact_Time__c"],
				["state" , "Mailing_State__c"],
				["statecode" , "Mailing_State_Code__c"],
				["country" , "Mailing_Country__c"],
				["countrycode" , "Mailing_Country_Code__c"],
				["zipcode" , "Mailing_Zip_Postal_Code__c"],
				["ethnicity" , "Ethnicity__c"],
				["dfirstname" , "First_Name__c"],
				["dlstname" , "Last_Name__c"],
				["dphone" , "Phone__c"],
				["demail" , "Email__c"],
				["dbyear" , "Birth_Year__c"],
				["dattest" , "Attestation__c"],
				["dpid" , "Id"]]);
    @api pd;
    initPd;
    @api
    get peid() {
        return this.pd;
    }
    set peid(value) {
        this.pd=null;
        this.initPd=null;
        this.infoSharingValue = [];
        this.showDupMsg = false;
        this.showUpdateMsg = false;
        this.showDelYear=false;
        this.newDel=null;
        this.delOp= '';    
        this.delegateMinor =false;
        this.stateReq = false;
        this.disableEdit = false;
        getParticipantData( { PEid:value})
            .then(result => {
                this.pd = result;   
                var disableSaveOn = ['Randomization Success','Treatment Period Started','Follow-Up Period Started','Participation Complete','Trial Complete','Enrollment Success'];
                this.disableEdit = disableSaveOn.includes(this.pd.pe.Participant_Status__c);         
                if(!this.pd['delegate']){
                    this.pd.delegate = {"Id":"","Participant_Delegate__c":"","Participant_Delegate__r":{} };
                    //this.pd.delegate.Participant_Delegate__r={"First_Name__c":"","Last_Name__c":"","Phone__c":"","Email__c":"","Birth_Year__c":"","Attestation__c":false};
                }
                if(!this.pd['pe']['Participant__r']['Middle_Name__c']){
                    this.pd['pe']['Participant__r']['Middle_Name__c'] = '';
                }
                if(!this.pd['pe']['MRN_Id__c']){
                    this.pd['pe']['MRN_Id__c'] = '' ;
                }
                if(this.pd['pe']['Participant__r']['Date_of_Birth__c']){
                    let dt = this.pd['pe']['Participant__r']['Date_of_Birth__c'].split("-");
                    this.valueYYYY = dt[0];
                    this.valueMM = dt[1];
                    this.valueDD = dt[2];
                    this.MMChange();
                    this.YYYYChange();
                }
                if(this.pd['pe']['Permit_Mail_Email_contact_for_this_study__c']){
                    this.infoSharingValue.push('cnt');
                }
                if(this.pd['pe']['Permit_SMS_Text_for_this_study__c']){
                    this.infoSharingValue.push('smscnt');
                }
                if(this.pd['pe']['Permit_Voice_Text_contact_for_this_study__c']){
                    this.infoSharingValue.push('txtcnt');
                }
                if(!this.pd['delegate']){
                    this.pd.delegate = {"Participant_Delegate__r":{} };
                    //this.pd.delegate.Participant_Delegate__r={"First_Name__c":"","Last_Name__c":"","Phone__c":"","Email__c":"","Birth_Year__c":"","Attestation__c":false};
                }
                if(this.pd['pe']['IVRS_IWRS__c']){
                    this.disableSrc = true;
                }
                if(this.pd['pe']['MRN_Id__c']){
                    this.disableScreening = true;
                }
                if(this.pd['pe']['Participant__r']['Adult__c']){
                    this.isAdult = true;
                    this.isNotAdult = false;
                    this.altIsNotAdult = true;
                    if(this.pd.pe.Participant__r.Alternative_Phone_Number__c){
                        if(this.pd.pe.Participant__r.Alternative_Phone_Number__c.trim()!==''){
                            this.altIsNotAdult = false;
                        }
                    }                    
                }
                window.clearTimeout(this.delayTimeout);
                this.delayTimeout = setTimeout(this.setEth.bind(this), 50);
                this.setReqEmail();
                this.setReqPhone();
                this.setReqDelegate();
                this.initPd = JSON.parse(JSON.stringify(this.pd));
            }).then(()=> {
                getStudyAccessLevel()
                .then((result) => {
                   this.lststudysiteaccesslevel = result;
                    if(this.lststudysiteaccesslevel[this.selectedPE.siteId])
                    {
                       this.delegateLevels = this.lststudysiteaccesslevel[this.selectedPE.siteId];
                    } 
                }) 
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
    get checkDelegateLevels(){
        if(this.delegateLevels == 'Level 3' || this.delegateLevels == 'Level 2'){
            return this.PG_MT_T_Your_permissions_do_not_permit_this_action;
        }else{
            return this.BTN_Verify;
        }
    }
    handleClick(){
        if(this.delegateLevels != 'Level 3' && this.delegateLevels != 'Level 2'){
            this.template.querySelector('c-pir_participant-emancipated').doExecute();
        }
    }
    handleEmancipation(event){
        this.actionReq = false; 
        this.peid = this.pd.pe.Id;
    }
    handleValChangeH(event){
        let val = event.target.value;
        let field =event.target.name;
        let lvl = event.target.getAttribute("data-lvl");
        this.setVal(val,lvl,field);
    }
    handleValChange(event){
        let val = event.target.value;
        let tempval= val.trim();
        console.log("temp"+tempval+"val")
        if(tempval ==''){
            event.target.value = tempval;
            val = tempval;
        }
        let lvl = event.target.dataset.lvl;
        let field =event.target.name;
        this.setVal(val,lvl,field);
    }
    setVal(val,lvl,field){
        if(lvl=='1'){
            this.pd['pe'][this.fieldMap.get(field)]=val;    
        } else if(lvl=='2'){
            this.pd['pe']['Participant__r'][this.fieldMap.get(field)]=val;   
            if(field=='altph'){                
                if(val.trim()!=''){
                    this.altIsNotAdult = false;
                } else{
                    this.altIsNotAdult = true;
                }               
            }               
        } else if(lvl=='3'){
            this.pd['delegate']['Participant_Delegate__r'][this.fieldMap.get(field)]=val;  
            if(field=="demail"){
                this.setReqEmail();
            }
            if(field=="dphone"){
                this.setReqPhone();
            }
            if(field=='dbyear'){
                if(this.contObj && this.pd){
                    let cCode = '';
                    let csCode = '';
                    if(this.pd['pe']['Participant__r']['Mailing_Country_Code__c']){
                        cCode =this.pd['pe']['Participant__r']['Mailing_Country_Code__c'];
                        if(this.pd['pe']['Participant__r']['Mailing_State_Code__c']){
                            if(this.pd['pe']['Participant__r']['Mailing_State_Code__c']!=''){
                                csCode = cCode+'_'+this.pd['pe']['Participant__r']['Mailing_State_Code__c'];
                            }
                        }
                    }
                    let adultAge = this.contObj.adultAgeByCountryStateCode["Age_for_All_Countries"];
                    if(this.contObj.adultAgeByCountryStateCode[cCode]){
                        adultAge = this.contObj.adultAgeByCountryStateCode[cCode];
                    }
                    if(this.contObj.adultAgeByCountryStateCode[csCode]){
                        adultAge = this.contObj.adultAgeByCountryStateCode[csCode];
                    }
                    var currentyr = new Date().getFullYear();
                    var adultyear = currentyr - adultAge;
                    this.delegateMinor = adultyear < val;
                }
                

            }
            this.setReqDelegate();
        }
        this.toggleSave();
    }
    //ethinicity start
    setEth(){  
        try{
            if(this.pd['pe']['Participant__r']['Ethnicity__c']){
                let sysVal = this.pd['pe']['Participant__r']['Ethnicity__c'].split(";");
                for(var i=0;i<sysVal.length;i++){
                    this.template.querySelector("input[value='"+sysVal[i]+"']").checked = true;
                    this.fcsEth = false;   
                    this.setEthinicityList();
                }
            }  
            else{
                this.removeAllE();
            }
            if(this.template.querySelector(".eBox")){
                this.template.querySelector('.eBox').addEventListener('focus', (event) => {  
                    this.template.querySelector('.eBoxOpen').classList.add("slds-is-open");
                }, false);   
                this.template.querySelector('.eBox').addEventListener('blur', (event) => {  
                   this.template.querySelector('.eBoxOpen').classList.remove("slds-is-open");
                }, false);
            }
            this.setState();
            this.toggleSave();
        }
        catch(e){
            window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(this.setEth.bind(this), 50);
        }
    }
    picklistValues;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',//default rectype id 
        fieldApiName: ethinicity_field
    }) 
    wiredEthVal({ error, data }) {
        if (data) {
            this.picklistValues = [];
            for(var i = 0;i<data.values.length;i++){
                this.picklistValues.push({label:data.values[i].label.split("- ")[1] , value:data.values[i].value});
            }
        } else if (error) {
            console.log("err");
        }
    }
    
    selectedEthinicity = [];
    fcsEth = true;
    divSetEth(event){
        event.currentTarget.getElementsByTagName('input')[0].checked=!event.currentTarget.getElementsByTagName('input')[0].checked;
        this.setEthinicityList();
    }
    setEthinicityList(){
        let tempList = [] ;
        let ethElement  =  this.template.querySelector('[data-id="ethinicityBox"]');
        let opts = ethElement.getElementsByTagName('input');
        let ethOPts = [];
        for(var i = 0; i < opts.length; i++) {
            if(opts[i].checked) {
                tempList.push({"label":opts[i].name, "value":opts[i].value});
                ethOPts.push(opts[i].value);
            }
        }
        this.pd['pe']['Participant__r']['Ethnicity__c'] = ethOPts.join(";");
        this.selectedEthinicity = [];
        this.selectedEthinicity = this.selectedEthinicity.concat(tempList); 
        if(this.fcsEth)
            this.template.querySelector('.eBox').focus();  
        this.fcsEth = true;     
    }
    removeE(event){
        this.template.querySelector("input[value='"+event.currentTarget.dataset.id+"']").checked = false;
        this.setEthinicityList();
    }
    removeAllE(event){
        let ethElement  =  this.template.querySelector('[data-id="ethinicityBox"]');
        let opts = ethElement.getElementsByTagName('input');
        for(var i = 0; i < opts.length; i++) {
            opts[i].checked=false;
        }
        this.selectedEthinicity = [];
        this.pd['pe']['Participant__r']['Ethnicity__c'] = "";
    }
    //ethinicity end

    //date field start
    valueDD = '--';
    valueYYYY = '----';
    valueMM = '--';
    lastDay = 31;
    firstYear = 1900;
    lastYear = parseInt(new Date().getFullYear());
    get ageCal(){
        var dob = new Date(this.pd['pe']['Participant__r']['Date_of_Birth__c']);
        //calculate month difference from current date in time
        var month_diff = Date.now() - dob.getTime();
        //convert the calculated difference in date format
        var age_dt = new Date(month_diff); 
        //extract year from date    
        var year = age_dt.getUTCFullYear();
        //now calculate the age of the user
        var age = Math.abs(year - 1970);
        return age;
    }
    
    get optionsDD() {
        var opt = [];
        // opt.push({label: '--', value:'--' });
        for(var i = 1 ; i<=this.lastDay ;i++){
            var x = i.toString();
            if(i<10)
                x='0'+x;
            opt.push({label: x, value: x });
        }
        return opt;
    }
    get optionsMM() {
        var opt = [];
        // opt.push({label: '--', value:'--' });
        opt.push({label: 'January', value:'01' });
        opt.push({label: 'Febuary', value:'02' });
        opt.push({label: 'March', value:'03' });
        opt.push({label: 'April', value:'04' });
        opt.push({label: 'May', value:'05' });
        opt.push({label: 'June', value:'06' });
        opt.push({label: 'July', value:'07' });
        opt.push({label: 'August', value:'08' });
        opt.push({label: 'September', value:'09' });
        opt.push({label: 'October', value:'10' });
        opt.push({label: 'November', value:'11' });
        opt.push({label: 'December', value:'12' });        
        return opt;
    }
    get optionsYYYY() {
        var opt = [];
        // opt.push({label: '----', value:'----' });
        for(var i = this.lastYear ; i>=this.firstYear ;i--){
            opt.push({label: i.toString(), value: i.toString() });
        }
        return opt;
    }
    handleDDChange(event) {
        this.valueDD = event.detail.value;
        this.handleDateChange();
    }
    handleMMChange(event) {
        this.valueMM = event.detail.value;
        this.MMChange();
    }
    MMChange() {
        var maxDayMonths = ['01','03','05','07','08','10','12'];
        var minDayMonths = ['04','06','09','11'];
        if(maxDayMonths.includes(this.valueMM)){
            this.lastDay = 31;
        }
        else if(maxDayMonths.includes(this.valueMM)){
            this.lastDay = 30;
        }
        else if(this.valueMM == '02'){
            if(this.valueYYYY =='----' || this.isLeapYear()){
                this.lastDay = 29;
            }     
            else{
                this.lastDay = 28;
            }            
        }
        if( parseInt(this.valueDD) > this.lastDay){
            this.valueDD = this.lastDay.toString();
        }
        this.handleDateChange();
    }
    handleYYYYChange(event) {
        this.valueYYYY = event.detail.value;
        this.YYYYChange();
    }
    YYYYChange(){
        if(this.valueMM=='02'){
            if(this.valueYYYY =='----' || this.isLeapYear()){
                this.lastDay = 29;
            }     
            else{
                this.lastDay = 28;
            }
        }
        if( parseInt(this.valueDD) > this.lastDay){
            this.valueDD = this.lastDay.toString();
        }
        this.handleDateChange();
    }
    handleDateChange(){
        this.pd['pe']['Participant__r']['Date_of_Birth__c']=this.valueYYYY+'-'+this.valueMM+'-'+this.valueDD;
        this.isAdultCal();  
        this.setReqEmail();      
        this.setReqPhone();      
        this.setReqDelegate();
        this.toggleSave();
    }
    isLeapYear(){
        if(parseInt(this.valueYYYY)%400==0){
            return true;
        }
        if(parseInt(this.valueYYYY)%100==0){
            return false;
        }
        if(parseInt(this.valueYYYY)%4==0){
            return true;
        }
        return false;
    }
    isAdult=false;
    isNotAdult = true;
    altIsNotAdult = true;
    isAdultCal(){
        if(this.contObj && this.pd){
            let cCode = '';
            let csCode = '';
            if(this.pd['pe']['Participant__r']['Mailing_Country_Code__c']){
                cCode =this.pd['pe']['Participant__r']['Mailing_Country_Code__c'];
                if(this.pd['pe']['Participant__r']['Mailing_State_Code__c']){
                    if(this.pd['pe']['Participant__r']['Mailing_State_Code__c']!=''){
                        csCode = cCode+'_'+this.pd['pe']['Participant__r']['Mailing_State_Code__c'];
                    }
                }
            }
            let adultAge = this.contObj.adultAgeByCountryStateCode["Age_for_All_Countries"];
            if(this.contObj.adultAgeByCountryStateCode[cCode]){
                adultAge = this.contObj.adultAgeByCountryStateCode[cCode];
            }
            if(this.contObj.adultAgeByCountryStateCode[csCode]){
                adultAge = this.contObj.adultAgeByCountryStateCode[csCode];
            }
            this.isAdult = (parseInt(this.ageCal)>=parseInt(adultAge));
            this.isNotAdult = !this.isAdult;
            if(this.isNotAdult){
                this.altIsNotAdult = !this.isAdult;
            }
            else if(this.pd.pe.Participant__r.Alternative_Phone_Number__c){
                if(this.pd.pe.Participant__r.Alternative_Phone_Number__c.trim()!==''){
                    this.altIsNotAdult = false;
                }
                else{
                    this.altIsNotAdult = true;
                }
            }
            else{
                this.altIsNotAdult = true;
            }
            this.pd['pe']['Participant__r']['Adult__c'] = this.isAdult;
        }
    }
    //date field end
    get sexAssignedBirth() {
        return [      
            { label: Gender_Male, value: 'Male' },
            { label: Gender_Female, value: 'Female' },
           
        ];
    }
    
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',//default rectype id 
        fieldApiName: language_field
    })
    languages;

    // Contact Information
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',//default rectype id 
        fieldApiName: phType_field
    })
    contactPhoneType;
    partEmailReq;
    setReqEmail(){
        var req = false;
        if(this.isAdult){
            req = true;
            if(this.pd.delegate.Participant_Delegate__r.Email__c){
                if(!this.pd.delegate.Participant_Delegate__r.Email__c.trim()==""){
                    req = false;
                }
            }
        }
        this.partEmailReq=  req;       
    }
    partPhoneReq;
    setReqPhone(){
        var req = false;
        if(this.isAdult){
            req = true;
            if(this.pd.delegate.Participant_Delegate__r.Phone__c){
                if(!this.pd.delegate.Participant_Delegate__r.Phone__c.trim()==""){
                    req = false;
                }
            }
        }
        this.partPhoneReq=  req;       
    }
    contObj;
    contactCountry=[];
    contactstates=[];
    @wire(getCnData)
    wiredCntVal({ error, data }) {
        if (data) {
            this.contObj = data;
            this.contactCountry = data.countryMap;           
            
        } else if (error) {
            console.log("err"+error.message);
        }
    }
    handleValChangeC(event){
        this.pd['pe']['Participant__r']['Mailing_Country__c'] =  event.target.options.find(opt => opt.value === event.detail.value).label;
        this.pd['pe']['Participant__r']['Mailing_Country_Code__c'] =  event.target.value;
        this.pd['pe']['Participant__r']['Mailing_State__c'] =  '';
        this.pd['pe']['Participant__r']['Mailing_State_Code__c'] =  '';
        if(this.delegateMinor && this.showDelYear){
            this.setVal(this.pd['delegate']['Participant_Delegate__r']['Birth_Year__c'],'3','dbyear');
        }
        this.isAdultCal();
        this.setState();        
        this.toggleSave();
    }
    handleValChangeS(event){
        this.pd['pe']['Participant__r']['Mailing_State__c'] =  event.target.options.find(opt => opt.value === event.detail.value).label;
        this.pd['pe']['Participant__r']['Mailing_State_Code__c'] =  event.target.value;
        if(this.showDelYear){
            this.setVal(this.pd['delegate']['Participant_Delegate__r']['Birth_Year__c'],'3','dbyear');
        }
        this.isAdultCal();        
        this.toggleSave();
    }
    stateReq = false;
    setState(){
        this.contactstates=[];
        if(this.pd['pe']['Participant__r']['Mailing_Country__c']){      
            this.contactstates=this.contObj.stateMap[this.pd['pe']['Participant__r']['Mailing_Country__c']];
            this.stateReq = this.contactstates.length >0;
        }   
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(this.toggleSave.bind(this), 50); 
    }
    
    //Info Sharing
    infoSharingValue =[];
    get infoSharingOptions() {
        return [
            { label: this.PG_Ref_L_Permit_IQVIA_To_Contact_Email, value: 'cnt' },
            { label: this.PG_Ref_L_Permit_IQVIA_To_Contact_Phone    , value: 'txtcnt' },
            { label: this.PG_Ref_L_Permit_IQVIA_To_Contact_SMS, value: 'smscnt' },
        ];
    }
    handleSharingOptChange(event) {
        this.infoSharingValue = event.detail.value;
        for(var i=0;i<this.infoSharingOptions.length;i++){
            if(this.infoSharingValue.includes(this.infoSharingOptions[i].value)){
                this.pd['pe'][this.fieldMap.get(this.infoSharingOptions[i].value)]=true;
            }
            else{                
                this.pd['pe'][this.fieldMap.get(this.infoSharingOptions[i].value)]=false;
            }
        }
    }
    // delegate logic
    duplicateDelegateInfo =  {};
    delegateReq;
    showUpdateMsg = false;
    showDupMsg = false;
    delOp = '';
    setshowDupMsg(){
        try{
        //if any field updated on delegate
        var delFields = ['dfirstname','dlstname','demail'];//,'dphone','dbyear','dattest','dpid'];
        var isDelUpdated=false;
        var isAnyEmpty =false;
        var isNew =false;
        var show=false;
        let initDel ;
        if(this.newDel==null){
            initDel = this.initPd.delegate.Participant_Delegate__r;
            console.log("1");

        }
        else{
            initDel = this.newDel;        
            console.log(JSON.stringify(initDel));
            console.log(JSON.stringify(this.pd['delegate']['Participant_Delegate__r']));

        }
        //check for delegate update
        delFields.forEach(function(field){
            if(this.fieldUpdate(initDel[this.fieldMap.get(field)],this.pd['delegate']['Participant_Delegate__r'][this.fieldMap.get(field)])){
                console.log("field"+field);
                isDelUpdated = true;
            }            
            if(!this.pd['delegate']['Participant_Delegate__r'][this.fieldMap.get(field)]){
                isAnyEmpty = true;
            }
            else if(this.pd['delegate']['Participant_Delegate__r'][this.fieldMap.get(field)].trim()==''){
                isAnyEmpty = true;
            }
            
        },this);
        console.log("isDelUpdated" + isDelUpdated);
        console.log("isAnyEmpty" + isAnyEmpty);
        if(isAnyEmpty){  
            this.showDelYear = false;
            this.delOp="";
            isNew = false;
        }
        if(isDelUpdated && !isAnyEmpty){      
            if(!initDel.Birth_Year__c){
                this.delOp= 'insertDelegate';
                this.showDelYear = true;
                isNew = true;
            }      
            checkExisitingParticipant( {strFirstName:this.pd.delegate.Participant_Delegate__r.First_Name__c,
                                        strLastName:this.pd.delegate.Participant_Delegate__r.Last_Name__c,
                                        strDelegateEmail:this.pd.delegate.Participant_Delegate__r.Email__c,
                                        participantId:this.pd.pe.Participant__c
            })
            .then(result => {
                if(result!=null){
                    if(result.PartcipantId == this.pd.delegate.Participant_Delegate__c ){
                        show = false; 
                        this.duplicateDelegateInfo =  {};   
                        this.showDupMsg = show;
                        this.newDupDel = null;
                    }
                    else{
                        show=true;
                        this.duplicateDelegateInfo =  {email:result.email ,lastName:result.lastName,firstName:result.firstName};   
                        this.showDupMsg = show;
                        this.newDupDel = result.DelegateParticipant;
                    }                        
                }
                else{
                    show = false; 
                    this.duplicateDelegateInfo =  {};   
                    this.showDupMsg = show;
                    this.newDupDel = null;
                }
                if(!isNew){  
                    this.showUpdateMsg = !show;
                }
                this.toggleSave();  
            })
            .catch(error => {
                console.error('Error:', error);
            });             
        }else{
            this.showDupMsg = false;
            this.showUpdateMsg = false;
            this.toggleSave();  
        }
        this.toggleSave();        
    }catch(e){
        console.log(e.message);
        console.log(e.stack);
    }
    }
    useDuplicateRecord(){
        try{
        this.newDel = JSON.parse(JSON.stringify(this.newDupDel));
        this.pd.delegate.Id = '';
        this.pd.delegate.Participant_Delegate__r = JSON.parse(JSON.stringify(this.newDupDel));
        this.pd.delegate.Participant_Delegate__c =this.pd.delegate.Participant_Delegate__r.Id;
        this.delOp = 'updateDeligate';
        this.showDelYear = false;        
        this.showDupMsg = false;
        this.showUpdateMsg = false;
        this.setVal(this.pd.delegate.Participant_Delegate__r.Phone__c,'3','dphone');
        this.toggleSave();
        }catch(e){
            console.log(e.message);
        }
    }
    newDel = null;
    newDupDel = null;
    showDelYear = false;    
    createupdateDelegate(event){
        this.showUpdateMsg = false;  
        this.newDel={};
        this.newDel.Email__c = this.pd.delegate.Participant_Delegate__r.Email__c;
        this.newDel.Last_Name__c = this.pd.delegate.Participant_Delegate__r.Last_Name__c;
        this.newDel.First_Name__c = this.pd.delegate.Participant_Delegate__r.First_Name__c;    
        this.newDel.Birth_Year__c = this.pd.delegate.Participant_Delegate__r.Birth_Year__c;    
        this.delOp = 'updateParticipant';
        if(event.detail=='insert'){
            this.pd.delegate.Participant_Delegate__r.id='';
            this.pd.delegate.Participant_Delegate__r.Attestation__c=false;
            this.pd.delegate.Participant_Delegate__r.Birth_Year__c='';
            this.newDel.Birth_Year__c = null;
            this.showDelYear = true;            
            this.delOp = 'insertDelegate';
        }
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(this.toggleSave.bind(this), 50); 
    }
    setReqDelegate(){
        var req = false;
        var delFields=['First_Name__c','Last_Name__c','Phone__c','Email__c'];
        if(!this.isAdult){
            req = true;           
        }
        for(var i=0;i<delFields.length;i++){
            if(this.pd.delegate.Participant_Delegate__r[delFields[i]]){
                if(!this.pd.delegate.Participant_Delegate__r[delFields[i]].trim()==""){
                    req = true;
                }
            }
        }
        this.delegateReq = req; 
         
        if(!req){
           window.clearTimeout(this.delayTimeout);
           this.delayTimeout = setTimeout(this.clearDelFields.bind(this), 50);            
        }else{
            window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(this.checkDelFields.bind(this), 50);
        }
    }
    checkDelFields(){
        this.toggleSave();  
        this.setEth();
    }
    clearDelFields(){
        this.showDupMsg = false;
        this.showUpdateMsg = false; 
        var a = this.template.querySelector(".delFields");
        var inp = a.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            element.reportValidity();
        },this);
        this.setEth();
    }
    delAttest(event){
        this.pd.delegate.Participant_Delegate__r.Attestation__c = event.target.checked;
        this.toggleSave();
    }

    //info section
    get refByPI(){
        return this.pd.pe.Referral_Source__c =="PI";
    }
    get refByHCP(){
        return this.pd.pe.Referral_Source__c =="HCP";
    }
    get notRefByPiHcp(){
        return (this.pd.pe.Referral_Source__c !="PI" && this.pd.pe.Referral_Source__c !="HCP") ;
    }
    
    //save
    toggleSave(){
        if(this.disableEdit){
            this.dispatchEvent(new CustomEvent('enabledetailsave', {  detail: false}));
            this.dispatchEvent(new CustomEvent('detailupdate', {  detail: false}));
        }
        else{
            this.dispatchEvent(new CustomEvent('enabledetailsave', {  detail: this.validate()}));
            var upd = this.isUpdated();
            var updates = (upd.isDelUpdated || upd.isPartUpdated || upd.isPeUpdated);
            this.dispatchEvent(new CustomEvent('detailupdate', {  detail: updates}));
        }
    }
    validate(){
        if(this.showDupMsg || this.showUpdateMsg){
            return false;
        } else if(this.delegateMinor && this.showDelYear){
            return false;
        }
       var inp = this.template.querySelectorAll("lightning-input");
       var inp2 = this.template.querySelectorAll("lightning-combobox");
       var err = 0;
       inp.forEach(function(element){
          if(!element.checkValidity()){
              err++;
          }
       },this);
       inp2.forEach(function(element){
          if(!element.checkValidity()){
              err++;
          }
       },this);
       return err == 0;
    }
    isUpdated(){
        if(this.pd){
            if(this.initPd){
        var peFields = ['src','cnt','smscnt','txtcnt'];
        var isPeUpdated=false;
        var partFields =['pid','adult','ethnicity','firstname','lastname','middlename','fullname','nickname','suffixname','lang','dob','gender','email','phone','phonetype','altph','altphtype','prefCntTime','state','statecode','country','countrycode','zipcode'];
        var isPartUpdated=false;
        var delFields = ['dfirstname','dlstname','dphone','demail','dbyear','dattest','dpid'];
        var isDelUpdated=false;
        //check for per update
        peFields.forEach(function(field){
            if(this.fieldUpdate(this.initPd['pe'][this.fieldMap.get(field)],this.pd['pe'][this.fieldMap.get(field)])){
                isPeUpdated = true;
            }
        },this);
        //check for participant update
        partFields.forEach(function(field){
            if(this.fieldUpdate(this.initPd['pe']['Participant__r'][this.fieldMap.get(field)],this.pd['pe']['Participant__r'][this.fieldMap.get(field)])){
            isPartUpdated = true;
            }
        },this);
        //check for delegate update
        delFields.forEach(function(field){
            if(this.fieldUpdate(this.initPd['delegate']['Participant_Delegate__r'][this.fieldMap.get(field)],this.pd['delegate']['Participant_Delegate__r'][this.fieldMap.get(field)])){
            isDelUpdated = true;
            }
        },this);
        return {"isPeUpdated":isPeUpdated,"isPartUpdated":isPartUpdated ,"isDelUpdated":isDelUpdated}
        }}
        return false;
    }
    saving=false;
    @api
    save(){
        this.dispatchEvent(new CustomEvent('toggleclick'));
        this.saving = true;
        var updates = this.isUpdated();
        doSaveParticipantDetails( { perRecord:this.pd.pe, peDeligateString:JSON.stringify(this.pd.delegate),isPeUpdated:updates.isPeUpdated,isPartUpdated:updates.isPartUpdated,isDelUpdated:updates.isDelUpdated,delegateCriteria:this.delOp})
        .then(result => {
            console.log("updated");
            this.dispatchEvent(new CustomEvent('toggleclick'));
            this.dispatchEvent(new CustomEvent('handletab'));
            this.peid = this.pd.pe.Id;
            const event = new ShowToastEvent({
                variant: 'success',
                message:
                'Record Saved Successfully',
            });
            this.dispatchEvent(event);
            this.saving = false;
        })
        .catch(error => {            
            console.error('Error:', error);
            this.saving = false;
            const event = new ShowToastEvent({
                variant: 'error',
                message:error.message
            });
            this.dispatchEvent(event);
        });
    }
    fieldUpdate(old,upd){
        if(typeof(old)=='boolean'){
            return old!=upd;
        }
        if(old){
            return old!=upd;
        }
        else if(upd){
            if(typeof(upd)!='boolean'){
                return upd.trim() != '';
            }
            else{
                return true;
            }
        }        
        return false;
    }
    //Labels
    BTN_Participant_Information=BTN_Participant_Information;
    PG_AS_F_First_name=PG_AS_F_First_name;
    PG_AS_F_Middle_name=PG_AS_F_Middle_name;
    PG_AS_F_Last_name=PG_AS_F_Last_name;
    PG_AS_F_Suffix=PG_AS_F_Suffix;
    PG_AS_F_Nickname=PG_AS_F_Nickname;
    PG_AS_F_Date_of_Birth=PG_AS_F_Date_of_Birth;
    PG_AP_F_Language=PG_AP_F_Language;
    PIR_Gender=PIR_Gender;
    PG_Ref_L_Primary_Delegate_Information=PG_Ref_L_Primary_Delegate_Information;
    PG_AS_F_Email_address=PG_AS_F_Email_address;
    PG_Ref_L_Primary_daytime_telephone_number=PG_Ref_L_Primary_daytime_telephone_number;
    RH_YearofBirth=RH_YearofBirth;
    RH_DelegateAttestation=RH_DelegateAttestation;
    RH_MinorDelegateErrMsg=RH_MinorDelegateErrMsg;
    PG_AP_F_Phone_Type=PG_AP_F_Phone_Type;
    PE_Country=PE_Country;
    PE_State=PE_State;
    PG_AS_F_Zip_Postal_Code=PG_AS_F_Zip_Postal_Code;
    PG_AP_H_Contact_Information=PG_AP_H_Contact_Information;
    PG_AP_F_Alternative_Phone_Number=PG_AP_F_Alternative_Phone_Number;
    PG_AP_F_Alternative_Phone_Type=PG_AP_F_Alternative_Phone_Type;
    PG_AP_F_Screening_Subject_Id=PG_AP_F_Screening_Subject_Id;
    FD_PE_Field_Arm_Cohort=FD_PE_Field_Arm_Cohort;
    PG_AS_F_Participation_Information=PG_AS_F_Participation_Information;
    Source_ID=Source_ID;
    PG_AS_F_Source_ID_Help_Text=PG_AS_F_Source_ID_Help_Text;
    PG_Ref_L_Information_Sharing=PG_Ref_L_Information_Sharing;
    PG_Ref_L_Permit_IQVIA_Confirmation=PG_Ref_L_Permit_IQVIA_Confirmation;
    PG_Ref_L_Permit_IQVIA_To_Contact_Email=PG_Ref_L_Permit_IQVIA_To_Contact_Email;
    PG_Ref_L_Permit_IQVIA_To_Contact_Phone=PG_Ref_L_Permit_IQVIA_To_Contact_Phone;
    PG_Ref_L_Permit_IQVIA_To_Contact_SMS=PG_Ref_L_Permit_IQVIA_To_Contact_SMS;
    Age=Age;
    RH_Ethnicity=RH_Ethnicity;
    PG_AP_F_Preferred_Contact_Time=PG_AP_F_Preferred_Contact_Time;
    This_Participant_has_reached_legal_age_of_emancipation=This_Participant_has_reached_legal_age_of_emancipation;
    BTN_Verify=BTN_Verify;
    PG_MT_T_Your_permissions_do_not_permit_this_action=PG_MT_T_Your_permissions_do_not_permit_this_action;
}