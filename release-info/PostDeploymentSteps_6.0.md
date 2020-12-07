## I. Pre-Deployment steps:

## 1. Add RTL languages
Go to Setup - Language Settings - Add Arabic and hebrew to displayed languages.
Go to Setup - Picklist value sets - languages - New - Add Hebrew and save- edit the api name to 'iw'.

## II. Post-Deployment steps:

## 1. Publish Community
Go to Setup - All communities - Click builder near GSK Community - Click Publish
Go to Setup - All communities - Click builder near IQVIA Referall Hub - Click Publish
Go to Setup - All communities - Click builder near Janssen - Click Publish

## 2. Change custom labels according Community URL
Go to Setup - All Communities > copy link address for IQVIA Referral Hub community
Go to Setup - Custom labels > find 'CommunityURL' custom label and change value with copied in previous step link address
Go to Setup - All Communities > copy link address for Janssen community
Go to Setup - Custom labels > find 'CommunityJanssenURL' custom label and change value with copied in previous step link address

## 3. Configuration theme
Open Setup - All Communities - Click Builder near Janssen Community
Go to Settings - Theme - Configure (tab)
Press"Edit Properties" near LoginThemeLayout and add Community Type - Janssen
Publish Community

## 4. Configuration field
Open Setup - Object Manager - Contact - Fileds and relationships - Visited Communities
Click Activate - Janssen value

## 5. Change CustomMetadata value
Open Setup - Custom Metadata Types > find Guides Setting and click on Manage Records > Edit 	English USA GSK  and change Language to 'en_US' and save.> Edit English USA Janssen and change Language to 'en_US' and save.

## 6. Favicon Configuration for Community Pages
1. Open Setup - All Communities - For 'IQVIA Referral Hub' Community
2. Go to Workspaces | Administration | Pages | Force.com
   Click Edit | Add "iqvia_favicon" static resource to the 'Sites Favourite Icon.' Save
3. Open Setup - All Communities - For 'IQVIA Referral Hub' Community
    Go to Community Builder | Go to Settings | Advanced | Edit Head Markup. 
4. Add the following line as first: 
    \<link rel="shortcut icon" href="/favicon.ico?v=2" type="image/icon"/\>
5. Save | Publish the changes in Community Builder
6. Repeat the same steps from 1 to 5 to covid-19 community.

## 6. RTL configurations
1. Go to Setup - Language Settings - check Enable end user languages - add Arabic and Hebrew to         displayed languages.
2. Go to Setup - Object Manager - Contact - fields - Language__c - Make picklist value Arabic(ar)       and Hebrew(iw) active.
3. Go to Setup - Object Manager - Contact - fields - Second_Choice_Language__c - Make picklist value    Arabic(ar) and Hebrew(iw) active.
4. Go to Setup - Object Manager - Contact - fields - Third_Choice_Language__c - Make picklist value     Arabic(ar) and Hebrew(iw) active.
5. Go to Setup - Object Manager - Contact - Record type - MASTER record type - Language - Add           'Arabic' and 'Hebrew' to selected values.
6. Go to Setup - Object Manager - Contact - Record type - MASTER record type - 2nd Choice Language -    Add  'Arabic' and 'Hebrew' to selected values.
7. Go to Setup - Object Manager - Contact - Record type - MASTER record type - 3rd Choice Language -    Add  'Arabic' and 'Hebrew' to selected values.
8. Go to Community Builder(IQVIA Referall Hub) - Go to Settings - Languages - Click Add Languages -     Add Arabic and Hebrew to community Languages.

## 8. Profile Permissions
1. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Submitted By Field - Click on Set Field Level Security  - For Profiles (Business Lead,Business Admin,Product Owner) ,check Visible
2. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Article External Link	 Field - Click on Set Field Level Security  - For Profiles (Business Lead,Business Admin,Product Owner) ,check Visible   
3. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Article External Link	 Field - Click on Set Field Level Security  - For Profile PRDB , IQVIA SPNL2 ,check Read-Only. 
4. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Submitted By Field - Click on Set Field Level Security  - For Profile PRDB, IQVIA SPNL2  ,check Read-Only. 



## 9. GSK Community Configuration

1.Open Setup - All Communities - Click Builder near GSK  Community
Go to Settings - Security - Clickjack Protection Level-Don't allow framing by any page (Most protection)
Go to Settings - Security - Security Level -Strict CSP: Block Access to Inline Scripts and All Hosts (Recommended)
Publish Community

## 10. GSK Community Terms and Condition page configuration(needs to be done only in formal and UAT)
1.Open Setup - All Communities - Click Builder near GSK  Community
go to gear icon-->Open Terms and Conditions page-->click on gear icon again-->go to Layout section-->check Override the default theme layout for this page-->select Brand_No_Navigation from 
Theme Layout dropdown.
Publish Community 

## 11.System Administrator profile configuration(needs to be done in fomral and UAT)
1.setup-->Profiles-->System Administrator-->object Setting-->Visit_Results-->check Biomarker checkbox in Assigned record types column.

## 12.Batch Job(needs to be done only in formal)
1.open Developer console-->Debug-->Open Execute Anonymous Window-->Run below line of code-->
ResourceExpBatchScheduler.start();
-->select this line --->click on execute highlighted

## 13.Email Banner Configuration
1.switch to classic mode --> click on (+) icon in menu bar-> Documents -> New
2.fill the Document Name & Document Unique Name with 'PPHeaderLogo' text --> check Externally Available Image --> choose PPHeaderLogo image from images folder -->   click on Save.
3.after uploading --> right click on uploaded image -> Open image in new tab -> Copy the url address.
4.In setup --> search Custom metadata type --> Community Template  --> Manage Community Templates --> Default --> Default_EmailTemplateHeaderBackgr Edit  --> paste the same copied url address in the background-image attriute url.
5.Setup-->Custom labels-->WelcomeEmail_PPHeaderLogo-->update the value with same copied url address.

## 14.Email Icons Configuration
1.switch to classic mode -> click on (+) icon in menu bar-> Documents -> New
2.fill the Document Name & Document Unique Name with 'LearnLogo' text --> check Externally Available Image --> choose LearnLogo image from images folder -->   click on Save-->right click on image--> Open image in new tab -> Copy the url address.
3.Setup-->Custom labels-->WelcomeEmail_LearnLogo-->paste the copied url address-->save
4.Documents --> New-->fill the Document Name & Document Unique Name fields with text "DiscoverLogo"-->check Externally Available Image-->choose DiscoverLogo image from images folder-->click on Save-->right click on image--> Open image in new tab -> Copy the url address.
5.Setup-->Custom labels-->WelcomeEmail_DiscoverLogo-->update the value with same copied url address.
6.Documents --> New-->fill the Document Name & Document Unique Name fields with text "TrackLogo"-->check Externally Available Image-->choose TrackLogo image from images folder-->click on Save-->right click on image--> Open image in new tab -> Copy the url address.
7.Setup-->Custom labels-->WelcomeEmail_TrackLogo-->update the value with same copied url address.


## 15.Language configuration for Resource record types 

1) setup-->Object Manager-->in quick find search 'Resource'-->open Resource__c object-->Reord Types-->Article-->Picklists Available for Editing-->Language(Language__c) -->Add all languages from Available values to Selected Values-->Save

Repeat this process for all other record types.


2) setup-->Object Manager-->in quick find search 'Resource'-->open Resource__c object-->Reord Types-->Article-->Picklists Available for Editing-->	
Languages(Languages__c) -->Add all languages from Available values to Selected Values-->Save

Repeat this process for all other record types.

3)setup-->Object Manager-->in quick find search 'Resource'-->open Resource__c object-->Reord Types-->Article-->Picklists Available for Editing-->	
Type-->Add all values  from Available values to Selected Values-->Save

Repeat this process for all other record types.

## 16.Business Lead Profile Configuration
1.setup-->Profiles-->Business Lead-->System Permissions-->Enable  "Manage Flow"	 permission-->Save 

##17. followup reminder custom metadata configuration(formal and UAT)
1.setup-->custom metadata-->FollowUp Reminder-->Manage FolloUp Reminders-->Org Default	-->Edit-->change value of 'Days after Permission gets' from 30 to 2.

## 17.BatchJob for SiteStaff
Execute this step in Production only once:(Only for Dec,2020 Release)

Click setup-> Developer console --> Press Ctrl+E, Remove all code(ctrl+A ,Del) if anything is there.
Copy & Paste the below code:

Batch_SiteStaff_Invited_Update batchSS = new Batch_SiteStaff_Invited_Update();
database.executebatch(batchSS, 50);

Click 'Execute' button.

## 18. GSK Community Cookie Policy page configuration
1.Open Setup - All Communities - Click Builder near GSK  Community
go to gear icon-->Open Cookie Policy page-->click on gear icon again-->change Page Access Value 
Page Access=Public
Publish Community 

2.Open Setup - All Communities - Click Builder near GSK  Community
go to gear icon-->Open Cookie Policy page-->click on the center of the page -->pop up on right side will get opened-->
Set PrivacyPolicy (for Privacy Policy) or CookiePolicy (for Cookie Policy) or leave blank for TC=CookiePolicy
If use for Portal terms then 'true', for Study terms and Privacy Policy - 'false'=false
Publish Community

## 19. Trial Match Learn More Field-Level Security
1.Go to Setup - Object Manager - Clinical Trial Profile - fields - Study_Content__c - Set Field-Level Security --> please check visible checkbox for following profiles : Business Administrator , Business Lead , IQVIA SPNL2 , Product Owner.

2.please check both visible and Read-Only checkboxes for profile : PRDBAPI

3.Go to Setup - Object Manager - Clinical Trial Profile - Page Layouts - Page Layout Assignment - Edit Assignment - hold CTRL button + choose three profiles Business Lead, IQVIA SPNL2,PRDBAPI and then select "Clinical Trial Profile Layout" from Page Layout To Use drop down list - Save. 

## 20. Update existing Delegates Adult flag
1.open Developer console-->Debug-->Open Execute Anonymous Window-->Run below lines of code-->

 TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class);
 TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckBecomesAdultHandler.class);
 TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class);
 TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
 TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
 TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
 TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateParticipantAge.class);
 List<Participant__c> participantsList=[Select Id,Contact__r.Email, Contact__c, Contact__r.userCommunityDelegateId__c, Adult__c from Participant__c where Contact__r.userCommunityMode__c ='Participant' and Contact__r.UserCommunityIsDelegate__c =true and Adult__c = False];
 for (Participant__c participant : participantsList) {
    participant.Adult__c = true;
  }
update participantsList;

2.Verification : open Developer console-->Query Editor-->paste this SOQL query : ( Select Id,Contact__r.Email, Contact__c, Contact__r.userCommunityDelegateId__c, Adult__c from Participant__c where Contact__r.userCommunityMode__c ='Participant' and Contact__r.UserCommunityIsDelegate__c =true and Adult__c = False ) -->Execute--> We should get Zero records after executing that query.
