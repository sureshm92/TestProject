Replace empty values in "Participant DOB format" field with default "DD-MM-YYYY": 1) Goto Setup - Object Manager - Search for "Study Site", Click on it - Fields & Relationships - Search for "Participant DOB format" field , Click on it. 2) Scroll down to the picklist values section, then click on Replace button. 3) Check the Replace all blank values checkbox, and select "DD-MM-YYYY" value in the Select Value Changing To dropdown and click replace

Data correction for date of birth field and age
a)Goto - developer console - Debug - open Execute Anonymous Window - Add the below Script

    Batch_UpdateDOBFieldsParticipants batch = new Batch_UpdateDOBFieldsParticipants();
    Database.executebatch(batch,2000);

    b)Click on execute button

1. Switch to Salesforce Classic -> Go to Documents Tab -> Click on New -> Enter below values in field:
   Document Name : PP_IQVIA_Logo
   Document Unique Name : PP_IQVIA_Logo
   Externally Available Image : checked
   Folder : Shared Documents
   Description : IQVIA Footer Logo for PP Email Templates

    From 'File to Upload' button, upload PP_IQVIA_Logo.png file present in
    https://gitlabrnds.quintiles.com/e2e-pe/rhpp-project/-/blob/INT14/release-info/images/PP_IQVIA_Logo.png
    Click on Save.
    For any quiries related to this step, contact rushikesh.kadam@iqvia.com

2. Switch to Salesforce Classic -> Go to Documents Tab -> Click on New -> Enter below values in the fields:
   Document Name : PP_Community_Email_Top_Background
   Document Unique Name : PP_Community_Email_Top_Background
   Externally Available Image : checked
   Folder : Shared Documents
   Description : Top Header Background for PP Email Templates

    From 'File to Upload' button, upload PP_Community_Email_Top_Background.png file present in
    https://gitlabrnds.quintiles.com/e2e-pe/rhpp-project/-/blob/INT14/release-info/images/PP_Community_Email_Top_Background.png
    Click on Save.
    For any quiries related to step, contact rushikesh.kadam@iqvia.com

Create the Screener records based on the Clinical trial profile MRR and Prescreener link. It will create the screener records and clear the screener links from Clinical trial profile. 
Also, Create the screener response records based on participant enrollment MRR and Prescreener response fields. It will create the screener response records and clear the screener response fields from participant enrollment. 
This will be one time batch for historical data.

a) Goto - Setup - Object Manager - search "Clinical Trial Profile" Object and Click on it - Validation Rules in left panel
    Open the below listed validation rules and deactivate those (Click on edit and uncheck the active check box and Save)
    i)   DCT_Platform_Mandatory
    ii)  Sync_flag_must_be_checked_before_DR
    iii) Sync_flag_must_be_checked_before_PP    
    iv)  Sync_flag_must_be_checked_before_PSS
    v)   Sync_flag_must_be_checked_before_RNS    
    vi)  Sync_flag_must_be_checked_before_RPSS    
    vii) Type_of_NCT_number
b) Goto - developer console - Debug - open Execute Anonymous Window
    Remove if any lines already added in the snippet window,Paste the below snippet and Click Execute.
    Database.executeBatch(new Batch_CreateScreener());
c) Goto - Quick find - Apex Jobs - Search for "Batch_CreateScreener" - Check the Status (It should be completed)
d) Once the batch is completed, Goto - Setup - Object Manager - search "Clinical Trial Profile" Object and Click on it - Validation Rules in left panel
    Open the below listed validation rules and Activate those (Click on edit and check the active check box and Save)
    i)   DCT_Platform_Mandatory
    ii)  Sync_flag_must_be_checked_before_DR
    iii) Sync_flag_must_be_checked_before_PP    
    iv)  Sync_flag_must_be_checked_before_PSS
    v)   Sync_flag_must_be_checked_before_RNS    
    vi)  Sync_flag_must_be_checked_before_RPSS    
    vii) Type_of_NCT_number
e) Once the batch is completed, Goto - Setup - Object Manager - search "Participant Enrollment" Object and Click on it - Validation Rules in left panel
    Open the below listed validation rules and deactivate those (Click on edit and uncheck the active check box and Save)
    i)   HCP_On_Hold
    ii)  InitialVisitOccurredDate_InFuture
    iii) Participant_Workflow_Final_Step_on_CTP    
    iv)  Revisit_Date_is_available
f) Goto - developer console - Debug - open Execute Anonymous Window
    Remove if any lines already added in the snippet window,Paste the below snippet and Click Execute.
    Database.executeBatch(new Batch_CreateScreenerResponse());
g) Goto - Quick find - Apex Jobs - Search for "Batch_CreateScreenerResponse" - Check the Status (It should be completed)
h) Once the batch is completed, Goto - Setup - Object Manager - search "Participant Enrollment" Object and Click on it - Validation Rules in left panel
    Open the below listed validation rules and Activate those (Click on edit and check the active check box and Save)
    i)   HCP_On_Hold
    ii)  InitialVisitOccurredDate_InFuture
    iii) Participant_Workflow_Final_Step_on_CTP    
    iv)  Revisit_Date_is_available
Note : I have attached document FYI. 


Post Deployment Steps for RH-8326

Step1: Open the developer console and copy the script 1 given below and click on execute
Script 1
******************
public  List<String> perIds = new List<String>();
public  List<String> perExcludeIds = new List<String>();
Database.executeBatch(new Batch_UpdatetimestampsexistingContacts(perIds,perExcludeIds));

Step2: Open the developer console and copy the script 2 given below and click on execute
Script 2
*******************
List<Id> perTargetIds = new List<Id>();
List<Id> perExcludeIds = new List<Id>();
List<Participant_Enrollment__c >  enrollments = [select id,Participant_Status__c,Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c from Participant_Enrollment__c where ((Participant_Status__c = 'Enrollment Success' AND Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c != 'Enrollment') OR (Participant_Status__c = 'Randomization Success' AND Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c != 'Randomization')) ];
for(Participant_Enrollment__c per : enrollments){
    perExcludeIds.add(per.Id);
}

Database.executeBatch(new Batch_UpdatetimestampsforexistingPER(perExcludeIds,perTargetIds));