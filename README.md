# Salesforce DX Scratch Org Setup 

##### 0) Login to Dev Hub org and make it default (-d key):

   ```
   sfdx force:auth:web:login -d -a devHubAlias
   sfdx force:config:set defaultdevhubusername=devHubAlias --global
   ```

##### 1) Create Scratch Org:

   ```sh
   ./create-scratch-org.sh scratchOrgAlias
   ````
----------------------------------------------------------------------------------
If merge request fails on the error 
just remove <userPermission> with the name ViewFlowUsageAndFlowEventData from Admin.profile
