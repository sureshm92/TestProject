# Salesforce DX Scratch Org Setup 

##### 1) Login to Dev Hub org and make it default (-d key):

   ```
   sfdx force:auth:web:login -d -a devHubAlias
   ```

##### 2) Create Scratch org and make it default (-s key):

   ```sh
   sfdx force:org:create -f config/project-scratch-def.json -d 30 -s -a scratchOrgAlias
   ```

##### 3) Import Org Wide Email Address:

   ```sh
   sfdx force:data:tree:import -f data/OrgWideEmailAddresses.json
   ```
   
   After import complete go to mail boxes updates@cp.clinicalresearch.com & patientupdates@cp.clinicalresearch.com and approve both. Don't forget remove this emails from emailbox. Ask about how to get access to this mailbox
    
##### 4) Setup Scratch Org before push:
    
   ```sh
   sfdx force:org:open
   ```
   <!-- 1. Go to **State and Territory Picklists** and follow instruction for enable (temporary) -->
   1. Go to **Survey Settings** and enable 
   2. Go to **User Interface** in the *Name Settings* section, select "Enable Middle Names for Person Names" and "Enable Name Suffixes for Person Names".
##### 5) Push project to Scratch org:

   ```sh
   sfdx force:source:push -f
   ```

##### 6) Post setup:
    
   ```sh
   post-setup.bat
   ```

##### 7) Publish community:

   Go to Setup > All Communities > Open Community Builder > press "Publish"
  
----------------------------------------------------------------------------------
If merge request fails on the error 
just remove <userPermission> with the name ViewFlowUsageAndFlowEventData from Admin.profile
