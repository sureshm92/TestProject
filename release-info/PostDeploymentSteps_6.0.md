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
3. Open Setup - All Communities - 
    Go to Community Builder | Go to Settings | Advanced | Edit Head Markup. 
4. Add the following line as first: 
    \<link rel="shortcut icon" href="/favicon.ico?v=2" type="image/icon"/\>
5. Save | Publish the changes in Community Builder

## 6. RTL configurations
1. Go to Setup - Language Settings - check Enable end user languages - add Arabic to displayed          languages.
2. Go to Setup - Object Manager - Contact - fields - Language__c - Make picklist value Arabic(ar)       active.
3. Go to Community Builder(IQVIA Referall Hub) - Go to Settings - Languages - Click Add Languages -     Add Arabic to  community Languages
