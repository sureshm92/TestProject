public  without sharing class RPRecordReviewLogHelper {

    public static Set<String> ctpIds;

    public class HCPInit{
        public String delegateAccessLevel;
        public Contact delegateDetails;
        public List<LabelValueItem> studyList = new List<LabelValueItem>();
        public List<LabelValueItem> studySiteList = new List<LabelValueItem>();
        public List<LabelValueItem> selectedstudySiteList = new List<LabelValueItem>();

    }

    public static HCPInit getHCPInitData(String delegateId, String userMode) {       
        HCPInit hInit = new HCPInit();
        try {
                if(userMode == 'HCP') {
                    Id currentContactId = CommunityService.getInstance().getCurrentContactId();
                    //Check access level
                    hInit.delegateAccessLevel = CommunityService.getInstance().getUserAccessLevel(delegateId);                
                    String hcpDelegate = hInit.delegateAccessLevel != null ? delegateId : currentContactId;
                    //Get delegate contact details
                    hInit.delegateDetails = getContact(hcpDelegate);
                    //Get study details
                    hInit.studyList = getStudyDetails(hcpDelegate); 
                    //Get study site details
                    hInit.studySiteList = getStudySiteDetails(ctpIds); 
            }       
            return hInit;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }   
    
     public static Contact getContact(Id currentContact){
        return [Select Id, Email, MailingState, MailingCountry, Phone from Contact where Id =: currentContact]; 
    }
    
    public static List<LabelValueItem> getStudyDetails(String delegateId) {
        List<LabelValueItem> studyDetails = new List<LabelValueItem>();
        ctpIds = new Set<String>();

        for(HCP_Enrollment__c hcpEnroll : [SELECT Id, Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Code_Name__c 
                                            FROM HCP_Enrollment__c WHERE HCP_Contact__c =: delegateId])
        {
            ctpIds.add(hcpEnroll.Clinical_Trial_Profile__c);
            studyDetails.add(new LabelValueItem(hcpEnroll.Clinical_Trial_Profile__c,hcpEnroll.Clinical_Trial_Profile__r.Study_Code_Name__c));
        }
        
        return studyDetails;
    }
    
   

    public static List<LabelValueItem> getStudySiteDetails(Set<String> ctpIds) {
        List<LabelValueItem> studySiteList = new List<LabelValueItem>();

        for(Study_Site__c site : [Select Id, Name from Study_Site__c where Clinical_Trial_Profile__c IN: ctpIds]) {
            studySiteList.add(new LabelValueItem(site.Name, site.Id));
        }

        return studySiteList;
    }

    public static List<LabelValueItem> getStudies(String userMode, String delegateId) {
        List<LabelValueItem> studies = new List<LabelValueItem>();
        Map<Id, String> trialsByName = new Map<Id, String>();
        for (Clinical_Trial_Profile__c trial : TrialService.getAvailableTrials(userMode, delegateId)) {
            trialsByName.put(trial.Id, trial.Study_Code_Name__c);
        }
        for (Id studyId : trialsByName.keySet()) {
            studies.add(new LabelValueItem(trialsByName.get(studyId), studyId));
        }
        return studies;
    }

    public static List<LabelValueItem> getSelectedStudySite(String currentContactId, String ctpId) {
        List<LabelValueItem> studySiteList = new List<LabelValueItem>();
        Set<String> studyId = new Set<String>();
        List<RP_Delegate_Relationship__c> RPD = new List<RP_Delegate_Relationship__c>();
        List<Id> lstcontactId = new List<Id>();

        RPD = [SELECT Delegate_Access_Level__c,Referring_Provider__c FROM RP_Delegate_Relationship__c WHERE Delegate__c = :currentContactId];
            if(RPD.size() != 0){
                for(RP_Delegate_Relationship__c del: RPD){
                    lstcontactId.add(del.Referring_Provider__c);
                }
                lstcontactId.add(currentContactId);
            }else{
                 lstcontactId.add(currentContactId);
            }
         Set<String>dupSet = new Set<String>();
        for(HCP_Enrollment__c hcpEnroll : [SELECT Id, Study_Site__r.Name,Study_Site__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Code_Name__c 
                                            FROM HCP_Enrollment__c WHERE HCP_Contact__c IN: lstcontactId and Clinical_Trial_Profile__c =: ctpId])
        {
            if(dupSet.add(hcpEnroll.Study_Site__c)){
                studySiteList.add(new LabelValueItem(hcpEnroll.Study_Site__r.Name,hcpEnroll.Study_Site__c));
            }
        }

        return studySiteList;
    }
    public static String checkNeedsGuardian(String countryCode, String stateCode, String month ,String year) {
        Boolean needsGuardian = false;
        Integer monthInt;
        Integer yearInt;

        if(month == null || month == ''){
            //System.debug(2/0);
            month = '01';
        }

        boolean monthCheck = month != null && month != '' &&  month != 'undefined' ? true : false;
        boolean yearCheck = year != null && year != '' &&  year != 'undefined' ? true : false;

        if (monthCheck && yearCheck) {
            monthInt = Integer.valueOf(month);
            yearInt = Integer.valueOf(year);

            List<Age_of_Majority__mdt> ageOfMajorities = [
                SELECT DeveloperName, Country_Code__c, State_Code__c, Age__c
                FROM Age_of_Majority__mdt
            ];
            Map<String, Integer> ageByCountryCode = new Map<String, Integer>();
            for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                if (ageOfMajority.Age__c != null) {
                    ageByCountryCode.put(
                        ageOfMajority.DeveloperName,
                        ageOfMajority.Age__c.intValue()
                    );
                }
            }
            String dOBString = year+'-'+month+'-01';        
            Date birthDate =  Date.valueOf(dOBString);
            Integer participantAge = Date.newInstance(2000, birthDate.month(), birthDate.day()) <=
                Date.newInstance(2000, Date.today().month(), Date.today().day())
                ? Date.today().year() - birthDate.year()
                : Date.today().year() - birthDate.year() - 1;

            if (
                ageByCountryCode.get(
                    countryCode +
                    '_' +
                    stateCode
                ) != null
            ) {
                needsGuardian =
                    participantAge <
                    ageByCountryCode.get(
                        countryCode +
                        '_' +
                        stateCode
                    );
            } else if (ageByCountryCode.get(countryCode) != null) {
                needsGuardian =
                    participantAge < ageByCountryCode.get(countryCode);
            } else {
                needsGuardian = participantAge < 18;
            }
        }

        return '' + needsGuardian;
    }

    public static String checkDelegateAge(String countryCode, String stateCode, String year) {
        Boolean isAdult = false;

            List<Age_of_Majority__mdt> ageOfMajorities = [
                SELECT DeveloperName, Country_Code__c, State_Code__c, Age__c
                FROM Age_of_Majority__mdt
            ];
            Map<String, Integer> ageByCountryCode = new Map<String, Integer>();
            for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                if (ageOfMajority.Age__c != null) {
                    ageByCountryCode.put(
                        ageOfMajority.DeveloperName,
                        ageOfMajority.Age__c.intValue()
                    );
                }
            }

            Integer delegateAge =
                (Date.Today().Year()) - (Integer.valueof(year));

            if (
                ageByCountryCode.get(
                    countryCode +
                    '_' +
                    stateCode
                ) != null
            ) {
                isAdult =
                    delegateAge >=
                    ageByCountryCode.get(
                        countryCode +
                        '_' +
                        stateCode
                    );
            } else if (ageByCountryCode.get(countryCode) != null) {
                isAdult = delegateAge >= ageByCountryCode.get(countryCode);
            } else {
                isAdult = delegateAge >= 18;
            }
        
        return '' + isAdult;
    }

    public static List<LabelValueItem> getMonthWithoutZero() {
        List<LabelValueItem> monthOption = new List<LabelValueItem>();
        for(Integer i=1; i<=12; i++){
            String m = String.valueOf(i); 
            monthOption.add(new LabelValueItem(m, m));
        }
        return monthOption;
    }

    public static List<LabelValueItem> getMonthWithZero() {
        List<LabelValueItem> monthOption = new List<LabelValueItem>();
        for(Integer i = 1; i<=12; i++){
            String m;
            if(i<10){
               m = '0'+String.valueOf(i); 
            }
            else{
                m = String.valueOf(i);
            }
            monthOption.add(new LabelValueItem(m, m));
        }
        return monthOption;
    }

    public static List<LabelValueItem> getYear() {
        List<LabelValueItem> yearOption = new List<LabelValueItem>();
        Integer currentYear = System.Today().year();
        for(Integer i = 1900; i<= currentYear; i++){
            String y = String.valueOf(i); 
            yearOption.add(new LabelValueItem(y, y));
        }
        return yearOption;
    }
}