public without sharing class FileContainer {    
    public class StudyDetails{
        @AuraEnabled
        public Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c();
        @AuraEnabled
        public Study_Site__c studySite = new Study_Site__c();
        @AuraEnabled 
        public LabelValueItem studies;
	}

    public class HCPInit{
        @AuraEnabled 
        public String delegateAccessLevel;
        @AuraEnabled
        public List<StudyDetails> activelyEnrollingStudies = new List<StudyDetails>();
        @AuraEnabled
        public Contact delegateDetails;
        @AuraEnabled
        public Boolean showInstructions;
        
        public HCPInit(String delegateAccessLevel, List<StudyDetails> activelyEnrollingStudies,Contact delegateDetails, Boolean showInstructions) {
            this.delegateAccessLevel = delegateAccessLevel;
            this.activelyEnrollingStudies = activelyEnrollingStudies;
            this.delegateDetails = delegateDetails;
            this.showInstructions = showInstructions;
        }
    }
    
    @AuraEnabled
    public static HCPInit getHCPInitData(Id delegateId, String userMode) {       
        Id hcpDelegate;
        String delegateAccessLevel;
        List<StudyDetails> trials;
        Contact cntDetails;
        boolean showInstructions;
        Map<Id, HCP_Enrollment__c> trialHCPEnrollmentMap = new Map<Id, HCP_Enrollment__c>();
        try{
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            if(userMode == 'HCP'){
				//get show instructions flag from contact
                showInstructions = getInstructionStatus(currentContactId);
                //Check access level
                delegateAccessLevel = CommunityService.getInstance().getUserAccessLevel(delegateId);  
                hcpDelegate = delegateAccessLevel != null ? delegateId : currentContactId; 
                //Get trials
                trials = getTrials(hcpDelegate); 
                //Get contact details
                cntDetails = getContact(hcpDelegate);
            }		
            return new HCPInit(delegateAccessLevel, trials, cntDetails, showInstructions);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }    
        
    public static boolean getInstructionStatus(Id currentContact){
        Contact cnt = [Select Id, Show_Instructions__c from Contact where Id =: currentContact];
        return cnt.Show_Instructions__c; 
    }
    
    public static Contact getContact(Id currentContact){
        return [Select Id, Email, MailingState, MailingCountry, Phone from Contact where Id =: currentContact]; 
    }
    @auraEnabled
    public static void getShowInstructValue(boolean flag)
    {
        Contact cnt = new Contact();
        cnt.id = [Select contactId from user where Id =: userInfo.getUserId()].contactId;
        cnt.Show_Instructions__c = flag;
        update cnt;
    }
    
    public static List<StudyDetails> getTrials(Id delegateId) {
        List<StudyDetails> studyDetails = new List<StudyDetails>();
        List<Id> ctpIdList = new List<Id>();
        
        for(HCP_Enrollment__c hcpEnroll : [SELECT 
                                           Id, Study_Site__c,
                                           Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Title__c 
                                           FROM HCP_Enrollment__c 
                                           WHERE HCP_Contact__c =: delegateId and Clinical_Trial_Profile__r.Override_Recruitment_Status__c = 'Actively Enrolling'])
        {
            if(!ctpIdList.contains(hcpEnroll.Clinical_Trial_Profile__c)){
                ctpIdList.add(hcpEnroll.Clinical_Trial_Profile__c);
                StudyDetails studySiteWrapper = new StudyDetails();
                studySiteWrapper.studies = new LabelValueItem(hcpEnroll.Clinical_Trial_Profile__r.Study_Title__c, hcpEnroll.Study_Site__c);
                studyDetails.add(studySiteWrapper);  
            }
        }
        return studyDetails;
    }
    
}