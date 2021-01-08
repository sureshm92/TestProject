## I. Post-Deployment steps:

## 1. Update Batch Patient Task Reminder

Update Batch Patient Task Reminder--> Go to Setup --> Click on App launcher --> Click on Batch Control Panel-->Click on Patient Task Reminder-->Change Interval Mode to Minutes and Relaunch Interval to 15

## 2.Allow Users to Use Standard External Profiles to Self-Register and Log Into Communities and Portals

Go to Setup - Release Updates - Click Get Started of update 'Allow Users to Use Standard External Profiles to Self-Register and Log Into Communities and Portals' - Click Done in Assess the impact of this release update - check the two checkboxes - click Confirm - Apply Update.

## 3.Check for Null Record Variables or Null Values of Lookup Relationship Fields in Process and Flow Formulas

Quick Find box - Release Updates - Check for Null Record Variables or Null Values of Lookup Relationship Fields in Process and Flow Formulas - Click Get Started - click Mark as Complete in Assessment step - Click Done in Review Alert - check the two checkboxes - click Confirm.

## 4.Require Verification When External Users Change Their Email Address

Quick Find box - Release Updates - Require Verification When External Users Change Their Email Address - Click Get Started -
a)Customize Your Email Templates : Quick findbox - All Communities - Workspaces next to name of any community - Administration - Emails - click mirror image next to Old Email Address Change Verification - select the 'Communities: Old Email - Change Email Verification' from the Unfiled Public Classic Email Templates folder - then click on mirror image next to 'New Email Address Change Verification' - select the 'Communities: New Email - Change Email Verification' - Click Save finally. --> repeat this step for each community : Covid-19,GSK Community,IQVIA Referral Hub,Janssen Community - click mark as Complete.
b)Communicate the Change to Your Users : click mark as Complete.
c)Enable Email Change Verification : Quick Find box - Identity Verification - Enable the setting Require email confirmations for email address changes (applies to external users in Lightning Communities) - click mark as Complete.
d)Review Alert : Click Done - check the two checkboxes - click Confirm.
e) Quick Find box - Identity Verification - Disable the Require email confirmations for email address changes (applies to external users in Lightning Communities).

## 5.Enforce Data Access in Flow Merge Fields

Go to Setup - Release Updates - Click Get Started of update 'Enforce Data Access in Flow Merge Fields' - Click on Enable Test Run - Click Done in Assess the impact of this release update - check the two checkboxes - click Confirm .

## 6.Enable Partial Save for Invocable Actions

Go to Setup - Release Updates - Click Get Started of update 'Enable Partial Save for Invocable Actions' - Click on Enable Test Run - Click Done in Assess the impact of this release update - check the two checkboxes - click Confirm.

## 7.Enable AuraEnabled Critical Updates

setup-->Release Updated->Use with sharing for @AuraEnabled Apex Controllers with Implicit Sharing
--->Get Started-->Enabled Test Run-->Assess the impact of this release update-->Done-->check both checkboxes-->confirm

## 8.Require Permission to View Record Names in Lookup Fields

Go to Setup - Quick Find box - Type as Release Updates - Click 'Get Started' button in the 'Require Permission to View Record Names in Lookup Fields' - Click Done in Assess the impact of this release update - check the two checkboxes - click Confirm.
    
	8.1) In Quick Find box - Type as Profiles - Click on 'Business Administrator' Profile - Click on Edit button - Search with 'View All Lookup Record Names' permission - Enable the permission by Click Marking the checkbox - Click on Save button
	Repeat the above (8.1) steps for the following mentioned Profiles 
	   a)Business Lead
	   b)IQVIA Customer Community Plus Login User
	   c)IQVIA SPNL2
	   d)PRDBAPI
	   e)Product Owner
	   	   
## 9.Require User Permission for the Send Custom Notification Action

Go to Setup - Quick Find box - Type as Release Updates - Click 'Get Started' button of update 'Require User Permission for the Send Custom Notification Action' - Click 'Mark as Complete' button in Review Impact on Flows of this release update - Click 'Mark as Complete' button in Review Impact on Apex Integrations of this release update - Click 'Mark as Complete' button in Review Impact on REST API Integrations of this release update - Click 'Mark as Complete' button in Review Impact on Processes of this release update - Click 'Done' button in Review Alert of this release update - check the two checkboxes - click Confirm.

    9.1) In Quick Find box - Type as Profiles - Click on 'Business Administrator' Profile - Click on Edit button - Search with 'Send Custom Notifications' permission - Enable the permission by Click Marking the checkbox - Click on Save button
	Repeat the above (9.1) steps for the following mentioned Profiles 
	   a)Business Lead
	   b)IQVIA Customer Community Plus Login User
	   c)IQVIA SPNL2
	   d)PRDBAPI
	   e)Product Owner

## 10.Make Flows Respect Access Modifiers for Legacy Apex Actions

Go to Setup - Release Updates - Make Flows Respect Access Modifiers for Legacy Apex Actions - Click Done in Assess the impact of this release update - check the two checkboxes - click Confirm - Apply Update.

## 11.Prevent Creation of Function Expressions When Using $A.createComponent() or $A.createComponents() in Aura Components

Go to Setup - Release Updates - Prevent Creation of Function Expressions When Using $A.createComponent() or $A.createComponents() in Aura Components - Click Done in Assess the impact of this release update - check the two checkboxes - click Confirm - Apply Update.

## 12.Transition to new Bot Options Menu behavior

Go to Setup - Release Updates - Click Get Started of update 'Transition to new Bot Options Menu behavior' - Click on Enable Test Run - Click Done in Assess the impact of this release update - check the two checkboxes - click Confirm. 

## 13. Run below Script to execute the batch
 Go to developer console > Open "Open execute Annonymous Window" uder debug tab > Run below script:
 Id myBatch= Database.executeBatch(new Batch_UpdPESHReasonToNonEnReason(), 2000);
## 14. Profile Permission
Step 1: Go to Setup >Go to Profiles-> Open Profile "Business Lead" ->Object Settings Open "Participant Enrollment Status History" object ->  Under Field Permissions: Give Read and Write Access on Notes and Additional Notes fields and Read Access to rest of the fields.

Step 2: Go to Setup >Go to Profiles-> Open Profile "Business Administrator" ->Object Settings Open "Participant Enrollment Status History" object -> Under Object Permissions,give Read,Edit and Create Access.Under Field Permissions: Give Read and Edit Access on "Non-Enrollment Reason" Field and "Additional Notes" field. 

Step 3: Go to Setup >Go to Profiles-> Open Profile "Business Lead" ->Object Settings Open "Participant Enrollment" object ->  Under Field Permissions: Give Read Access on "Last Status Changed Additional Notes" field.
Give Read Access on "Last Status Changed Additional Notes" Field.
Remove Edit Access for:
Participant Status
Participant Status Last Changed Date
Non-Enrollment Reason
Last Status Changed Notes 

Step 4: Go to Setup >Go to Profiles-> Open Profile "Business Administrator" ->Object Settings Open "Participant Enrollment" object ->  Under Field Permissions: 
Give Read Access on "Last Status Changed Additional Notes" Field.
Remove Edit Access for:
Participant Status
Participant Status Last Changed Date
Non-Enrollment Reason
Last Status Changed Notes 

Step 5: Go to Setup >Go to Profiles-> Open Profile "Product Owner" ->Object Settings Open "Participant Enrollment Status History" object ->  Under Field Permissions: Give Read and Edit Access on "Non-Enrollment Reason" ,"PESH Date" and "Additional Note" field.

Step 6: Go to Setup >Go to Profiles-> Open Profile "Product Owner" ->Object Settings Open "Participant Enrollment" object ->  Under Field Permissions: Give Read Access on "Last Status Changed Additional Notes" field.
Give Read Access on "Last Status Changed Additional Notes" Field.

## 15. Add User lock out email temlate for Janssen Community
Go to setup > serach for All Community and click on that > Click on  Workspaces before Janssen Community > Click on Administration > Click on Email Under Administration > Under Email Templates section,  Searche for "User Lockout Email Janssen" in User Lockout serch box and select that > Click on Save	

## 16. Enable ICU Locale Date Formats
1.	Navigate to Setup -> Release Updates
2.	Search for Enable ICU Locale Formats
3.	Enable the Dry run
For English(Canada) we request you to separately enable the required locale via below steps. 
1.	From Setup, enter User Interface in the Quick Find box.
2.	Select User Interface.
3.	In Currency Display Settings, select Enable ICU formats for en_CA locale.
4.	Click Save.