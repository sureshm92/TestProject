1. Go to setup > Object Manager > Search for "Trial Survey" object and click on it > Click on "Buttons, Links, and Actions" from the left panel > Serach for "New" and Click on "Edit" on Right side drop down of "New" > for "Lightning Experience Override" option, select "Lightning component" radio button and on Drop down, Select "c:TrialSurveyContainer" > for "Mobile Overrid" option, select "Lightning component" radio button and on Drop down, Select "c:TrialSurveyContainer"  > click on Save
2. Go to https://workbench.developerforce.com/login.php > Login to instance > Navigate to Queries > SOQL Query > Select Object Patient_Delegate__c > Select View As Bulk CSV and run below query
SELECT Contact__c,Id,isInviteToPP__c,Is_Created_by_Bulk_Import__c,Name,Participant_Delegate__c,Participant__c,Primary_Delegate__c,Status__c FROM Patient_Delegate__c WHERE Status__c='Active'
A csv gets downloaded and take it as a backup to continue below steps.
As a System Admin user, Click on Gear Icon > Developer Console > Debug > Open Execute Anonymous window.Copy below script and click on Execute
List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
pdList = [SELECT Id, Status__c, isInviteToPP__c FROM Patient_Delegate__c WHERE Status__c='Active']; 
for(Patient_Delegate__c pd: pdList) {
     if(pd.Status__c=='Active' && pd.isInviteToPP__c == false) {
         pd.isInviteToPP__c = true;
     }
}
database.update(pdList);
