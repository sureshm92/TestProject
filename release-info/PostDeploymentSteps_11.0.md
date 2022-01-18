## RH-11.0_PP-9.0 Post Deployment Steps:

1. Go to setup > Object Manager > Search for "Trial Survey" object and click on it > Click on "Buttons, Links, and Actions" from the left panel > Serach for "New" and Click on "Edit" on Right side drop down of "New" > for "Lightning Experience Override" option, select "Lightning component" radio button and on Drop down, Select "c:TrialSurveyContainer" > for "Mobile Overrid" option, select "Lightning component" radio button and on Drop down, Select "c:TrialSurveyContainer"  > click on Save
2. Go to https://workbench.developerforce.com/login.php > Login to instance with API 53.0 > Navigate to Queries > SOQL Query > Select Object Patient_Delegate__c > Select View As Bulk CSV and run below query
SELECT Contact__c,Id,isInviteToPP__c,Is_Created_by_Bulk_Import__c,Name,Participant_Delegate__c,Participant__c,Primary_Delegate__c,Status__c FROM Patient_Delegate__c WHERE Status__c='Active'
A CSV gets downloaded and take it as a backup to continue below steps.
As a System Admin user, Click on Gear Icon > Developer Console > Debug > Open Execute Anonymous window.Copy below script and click on Execute
```
List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
pdList = [SELECT Id, Status__c, isInviteToPP__c FROM Patient_Delegate__c WHERE Status__c='Active']; 
for(Patient_Delegate__c pd: pdList) {
     if(pd.Status__c=='Active' && pd.isInviteToPP__c == false) {
         pd.isInviteToPP__c = true;
     }
}
database.update(pdList);
```
3. Go to Setup – All Sites – click on builder beside IQVIA Referral Hub  to open community builder– click on publish button present at the top right corner without doing anychanges– again click on publish button on the popup. 
4. Go to Setup – All Sites – click on builder beside GSK Community to open community builder  – click on publish button present at the top right corner without doing anychanges – again click on publish button on the popup. 
5. Go to setup > Object Manager > Search for "Trial Survey" object and click on it > Click on "Buttons, Links, and Actions" from the left panel > Search for "Edit" button and Click on "Edit" on Right side drop down of "Edit" button > for "Lightning Experience Override" option, select "Lightning component" radio button and on Drop down, Select "c:TrialSurveyContainer" > for "Mobile Overrid" option, select "Lightning component" radio button and on Drop down, Select "c:TrialSurveyContainer"  > click on Save
6. Update IsCommunityUserRegistered__c field on user record.
Click on Gear Icon > Developer Console > Debug > Open Execute Anonymous window.Copy below script and click on Execute
```
List<User> userList = [SELECT Id, IsCommunityUserRegistered__c, profile.Name, LastLoginDate FROM User WHERE profile.Name='IQVIA Customer Community Plus Login User' AND IsCommunityUserRegistered__c = false  AND LastLoginDate != null];

for(User userRec:userList) {
    userRec.IsCommunityUserRegistered__c = true;    
}

update userList;
```

7. Click on App launcher --> Click on Batch Control Panel-->Click on Add new Job->Select Batch_CreateECOASubject -> Select Interval mode as Minutes and Relaunch Interval Mode to 5 and Scope Size: 50 -> Click on Create new batch detail
