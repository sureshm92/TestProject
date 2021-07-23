## 1. Publish Community

Go to Setup - All communities - Click builder near IQVIA Referall Hub - Click Publish

## 2. Update Theme Settings for Janssen

Go to Setup - All communities - Click builder near Janssen - Select "Login" from pages dropdown - Click on Theme (paint brush icon) - Theme Settings - Populate Community Type as "Janssen" - Click Publish

## 3. Give read access for Business Profiles

Go to Setup -> Profiles ->Open Business Administrator -> Open Object Settings-> Open 'Participant Enrollment'-> Under fields give Read access to 'Invited To PP Date'.Do the same for Product Owner and Business Lead Profiles.

## 4. Uncheck Require email confirmations for email address changes (applies to users in Experience Builder sites)

Go to Setup -> Identity Verification -> Uncheck Require email confirmations for email address changes (applies to users in Experience Builder sites)

#DONT Perform step #5 and #6 for Production

## 5. Update privacy policy records to show headers, updated date and pdf for IQVIA Referral Hub

Go to Terms and Conditions records > Open the record where 'T&C Type' is 'Privacy Policy'.
'Active Portal T&C' is true. Language is English. Community Name is 'IQVIA Referral Hub'.
Go to 'Policy Headers' field on the record.
Get the headers from below (#Policy Headers for (IQVIA Referral Hub) - English).
Add the headers in policy headers field. Add one header per line (just like in picklist fields).
Get the last updated date value from bottom of the 'T&C Text'.
Enter that text in 'Last Updated on' field.
(e.g. if text is 'This Privacy Policy was last updated on July 8, 2020.' enter the date in 'Last Updated on' >> 'July 8, 2020')

## 6. Update privacy policy records to show headers, updated date and pdf for Janssen Community

Go to Terms and Conditions records > Open the record where 'T&C Type' is 'Privacy Policy'.
'Active Portal T&C' is true. Language is English. Community Name is 'IQVIA Referral Hub'.
Go to 'Policy Headers' field on the record.
Get the headers from below (#Policy Headers for (Janssen) - English).
Add the headers in policy headers field. Add one header per line (just like in picklist fields).
Get the last updated date value from bottom of the 'T&C Text'.
Enter that text in 'Last Updated on' field.
(e.g. if text is 'This Privacy Policy was last updated on July 8, 2020.' enter the date in 'Last Updated on' >> 'July 8, 2020')

#Policy Headers for (IQVIA Referral Hub) - English
Our Commitment to Privacy
The Information We Collect
Web logs
Cookies and other technologies
Device information
The Way We Use Your Information
How We May Disclose Your Information
Access, Correction, Deletion, and Removal of Personal Information
Your Choices
International Transfers
Information Security
Children's Privacy
Data Retention
Accountability/Compliance and How to Contact Us

#Policy Headers for (Janssen) - English
Our Commitment to Privacy
The Information We Collect
Web logs
Cookies and other technologies
Device information
The Way We Use Your Information
How We May Disclose Your Information
Access, Correction, Deletion, and Removal of Personal Information
International Transfers
Information Security
Children's Privacy
Data Retention
Accountability/Compliance and How to Contact Us

## 7. Update Date Flag on Participant Enrollment
Go to Anonymous window of Developer console ->Paste the below line and execute :
DataBase.executeBatch(new Batch_UpdateInviteToPPDateOneTime(), 1000);
Go to ApexJObs and check if it is completed
After its completion, run the below query :

SELECT Id,Invited_To_PP_Date__c,Participant__c,Participant_Status__c,Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,Participant_Contact__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Protocol_Id__c,Study_Site__c,Study_Site__r.Study_Site_Type__c  from Participant_Enrollment__c WHERE Id IN ('a1U1I000005JMNUUA4','a1U1I000005JMNtUAO','a1U1I000005JMNyUAO','a1U2o000007ItpOEAS','a1U2o000007IxaMEAS','a1U2o000007J0ouEAC','a1U2o000007J0pJEAS','a1U2o000007J2O0EAK','a1U2o000007J2owEAC','a1U2o000007WwfBEAS','a1U2o000007WwqYEAS','a1U2o000007WwqiEAC','a1U2o000007WwtIEAS','a1U2o000007WwwlEAC','a1U2o000007oGFZEA2','a1U2o000007oGsuEAE','a1U2o000007oq74EAA','a1U2o000008qOI2EAM','a1U2o000008qOdIEAU','a1U2o000008rbhtEAA','a1U2o00000BRxsiEAD','a1U2o00000BRxvwEAD','a1U2o00000BS2quEAD','a1U2o00000BS39mEAD','a1U2o00000BS3ALEA1','a1U2o00000BS5EOEA1','a1U2o00000BS5EdEAL')

If the Invited_To_PP_Date__c field of all the records above is null/empty, then go to Setup->Object Manager->Participant Enrollment ->Validation Rules-> Open Participant_Workflow_Final_Step_on_CTP ->Deactivate the rule.

Then run the script present inside 'Update_PE.txt' by copying the code in the file and pastig it in anonymous window in developer console and execute

Reactivate the Validation Rule 