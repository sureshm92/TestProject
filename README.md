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
   1. Go to **State and Territory Picklists** and follow instruction for enable (temporary)
   2. Go to **Survey Settings** and enable 
   3. Go to **Communities Settings** and check "Enable ExperienceBundle Metadata API" checkbox

##### 5) Push project to Scratch org:

   ```sh
   sfdx force:source:push
   ```

##### 6) Import data:
    
   ```sh
   sfdx force:org:open
   ```

   1. Setup > User > edit > set role "View All" 
   2. Upload data

   ```sh
   sfdx force:data:tree:import -p data/import-plan.json
   ```

##### 7) Publish community:

   1. Go to Setup > All Communities > Open Community Builder > press Publish

##### 8) Login to community:

   1. Open Study Site for edit and change Override Status to "Accepted" 
   2. Open HCP Enrollment for edit and change Stats to "Activated" 
   3. Login to community under PI User, HCP user or Participant user on your choice 


