# Salesforce DX Scratch Org Setup 

##### 1) Login to Dev Hub org and make it default (-d key):

   ```
   sfdx force:auth:web:login -d -a devHubAlias
   ```

##### 2) Create Scratch Org:

   ```sh
   create-scratch-org.bat scratchOrgAlias
   ```

##### 3) Approve Org Wide Email Address:

   Go to mail boxes updates@cp.clinicalresearch.com & patientupdates@cp.clinicalresearch.com and approve both. Don't forget remove this emails from Email box. Ask about how to get access to this mailbox
   
##### 4) Push project to Scratch org:

   ```sh
   push-scratch-org.bat
   ```

##### 5) Publish community:

   Go to Setup > All Communities > Open Community Builder > press "Publish"
  
----------------------------------------------------------------------------------
If merge request fails on the error 
just remove <userPermission> with the name ViewFlowUsageAndFlowEventData from Admin.profile
