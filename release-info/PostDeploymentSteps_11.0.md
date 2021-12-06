1. Go to setup > Object Manager > Search for "Trial Survey" object and click on it > Click on "Buttons, Links, and Actions" from the left panel > Serach for "New" and Click on "Edit" on Right side drop down of "New" > for "Lightning Experience Override" option, select "Lightning component" radio button and on Drop down, Select "c:TrialSurveyContainer" > for "Mobile Overrid" option, select "Lightning component" radio button and on Drop down, Select "c:TrialSurveyContainer"  > click on Save
2. As a System Admin user, Click on Gear Icon > Developer Console > Debug > Open Execute Anonymous window.Copy below script and click on Execute
List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
pdList = [SELECT Id, Status__c, isInviteToPP__c FROM Patient_Delegate__c WHERE Status__c='Active']; 
for(Patient_Delegate__c pd: pdList) {
     if(pd.Status__c=='Active' && pd.isInviteToPP__c == false) {
         pd.isInviteToPP__c = true;
     }
}
