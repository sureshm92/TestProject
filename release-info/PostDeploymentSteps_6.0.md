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
3. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Article External Link	 Field - Click on Set Field Level Security  - For Profile PRDB ,check Read-Only. 
4. Go to Setup - Object Manager - Click on Resource object - Click on Fields and Relationships - Click on Submitted By Field - Click on Set Field Level Security  - For Profile PRDB ,check Read-Only. 

## 8. Record Type and Page Layout Assignments
1. Go to Setup - Object Manager - Click on Resource Object - Click on Record Types - Click New and create new Record Type with Existing Record Type as Master and Record Type Label as 'Submitted Articles'.Make it Active.Check the box Enable for Profile for Profiles(IQVIA SPNL,System Administrator,IQVIA Customer Community Plus Login User).Click Next.Click on Apply a different layout for each profile.
  For Profiles(System Administrator,IQVIA SPNL,IQVIA Customer Community Plus Login User) ,Select Submitted Articles Page Layout from dropdown next to each profile.Click on Save.
2. Go to Resources Object from App Launcher - Click on Submitted Articles List view from the dropdown - Click on gear icon -Click on Edit List Filters - Click on Add Filter - In the field select 'Record Type' ,In the operator select equals and in the value  select 'Submitted Articles'.Click on Done.


