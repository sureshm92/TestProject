## I. Post-Deployment steps:

1. **PEH-1961** Run the batch
    1. Go to Developer Console > Debug > Open execute Anonymous > Insert Batch_UpdateVisitResultsOptIn.run(); > Execute
    
2. **PEH-1965** Add Batch_TrialMatchNotify to the Batch Control Panel

3. **PEH-2206** Go to Developer Console > Debug > Open execute Anonymous > Insert Batch_SetVisitedCommunitiesOnContact.run(); > Execute
   
4. **PEH-2187** **PEH-2199** **PEH-2200** Create Named Credential for connect SF to itself:

    4.1. Create Connected App in Salesforce:
    
         - In setup open 'App Manager' > New Connected App button > enter below fields:
         - Connected App Name: Salesforce Self Connection
         - API Name: Salesforce_Self_Connection
         - Contact Email: any email for contact
         - enable a checkbox 'Enable OAuth Settings'
         - Callback URL: https://dummy.com
         - Selected OAuth Scopes: select all and move to right
         - press Save
    
    4.2. Create Authentication Provider:
    
         - In setup open in a new tab 'Auth. Providers' > New >  enter below fields:
         - Provider Type: Salesforce
         - Name: SF AP
         - URL Suffix: SF_AP
         - Consumer Key: copy value from created Connected App before
         - Consumer Secret: copy value from created Connected App before
         - Default Scopes: full refresh_token offline_access
         - Registration Handler: click on 'Automatically create a registration handler template'
         - click save
         - copy Callback URL to the clipboard 
    
    4.3. Update Callback URL in Connected APP:
    
         - return to your Authentication Provider, press enter and paste to Callback URL field value from clipboard
         - click save and wait 10 minutes
    
    4.4. Create Named Credential:
    
         - In setup open 'Named Credentials' > new
         - Label: Salesforce Credential
         - Name: Salesforce_Credential
         - URL: in setup search enter 'domains'and open in a new tab > find my domain and copy url to clipboard, 
           return to a named credential and paste url, add 'https://' before url value
         - Identity Type: Named Principal
         - Authentication Protocol OAuth 2.0
         - Authentication Provider: SF AP
         - Scope: full refresh_token offline_access
         - Start Authentication Flow on Save: checked
         - click Save
         - you will be redirected to login page, login to this org and press 'Allow' button
         - after save Authentication Status must be: Authenticated as yourUser@email.com 
         - NamedCredential setup complete

5. **PEH-2187** **PEH-2199** **PEH-2200** Create Custom Notification for PP Push Notifications:

    5.1. Go to Setup > Custom Notifications > New 
    
        - Custom Notification Name: PP RH Push Notification
        - API Name: PP_RH_Push_Notification
        - Supported chanenels: Mobile checked; Desktop checked
    
    5.2. Go to Setup > Notification Delivery Settings > Custom Notification Types and for 'PP RH Push Notification' choose application: IQVIA Patient Portal

6. **REF-1441 & REF-1550** Activate the process builder. Go to Setup > Process Builder > Select Create Task For OutReach User > Click on Activate

7. **REF-1441 & REF-1550** Publish the community. Setup > All Communities > Click on the Builder of IQVIA Referal Hub > Once the builder opens click on Publish
