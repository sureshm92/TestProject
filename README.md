# Salesforce DX Scratch Org Setup 

##### 1) Login to Dev Hub org and make it default (-d key):

   ```
   sfdx force:auth:web:login -d -a devHubAlias
   ```

##### 2) Create Scratch Org:

   ```sh
   ./create-scratch-org.sh scratchOrgAlias
   ````

##### 3) Publish community:

   Go to Setup > All Communities > Open Community Builder > press "Publish"
  
----------------------------------------------------------------------------------
If merge request fails on the error 
just remove <userPermission> with the name ViewFlowUsageAndFlowEventData from Admin.profile
