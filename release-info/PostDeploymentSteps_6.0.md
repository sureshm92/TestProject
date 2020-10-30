## I. Post-Deployment steps:

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
1. Go to Setup - Language Settings - check Enable end user languages - add Arabic to displayed          languages.
2. Go to Setup - Object Manager - Contact - fields - Language__c - Make picklist value Arabic(ar)       active.
3. Go to Community Builder(IQVIA Referall Hub) - Go to Settings - Languages - Click Add Languages -     Add Arabic to  community Languages

## 7. Profile Permissions
1. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Submitted By Field - Click on Set Field Level Security  - For Profiles (Business Lead,Business Admin,Product Owner) ,check Visible
2. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Article External Link	 Field - Click on Set Field Level Security  - For Profiles (Business Lead,Business Admin,Product Owner) ,check Visible   
3. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Article External Link	 Field - Click on Set Field Level Security  - For Profile PRDB , IQVIA SPNL2 ,check Read-Only. 
4. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Submitted By Field - Click on Set Field Level Security  - For Profile PRDB, IQVIA SPNL2  ,check Read-Only. 



## 8. GSK Community Configuration

1.Open Setup - All Communities - Click Builder near GSK  Community
Go to Settings - Security - Clickjack Protection Level-Don't allow framing by any page (Most protection)
Go to Settings - Security - Security Level -Strict CSP: Block Access to Inline Scripts and All Hosts (Recommended)
Publish Community

## 9. GSK Community Terms and Condition page configuration(needs to be done only in formal and UAT)
1.Open Setup - All Communities - Click Builder near GSK  Community
go to gear icon-->Open Terms and Conditions page-->click on gear icon again-->go to Layout section-->check Override the default theme layout for this page-->select Brand_No_Navigation from 
Theme Layout dropdown.

## 10.System Administrator profile configuration(needs to be done in fomral and UAT)
1.setup-->Profiles-->System Administrator-->object Setting-->Visit_Results-->check Biomarker checkbox in Assigned record types column.

## 11.Batch Job(needs to be done only in formal)
1.open Developer console-->Debug-->Open Execute Anonymous Window-->Run below line of code-->
ResourceExpBatchScheduler.start();
-->select this line --->click on execute highlighted