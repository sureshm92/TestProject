# IQ for release RH3.1/PP1.1IQVIA 
##Referral Hub/Patient PortalDeployment Process

### I. Pre-requisite steps:
1. Make sure that you have a list of COI to load (ZIP file)
2. Verification step: Make screenshot ZIP files.

### II. Pre-Deployment steps:
1. Access to Send Email
    1. Go to Setup > Deliverability > Access level to change on All Email.
    2. Verification step: Make screenshot this setting.
2. Encryption Policy
    1. Go to Setup > Encryption Policy > Click on Encrypt Fields > Click Edit > Navigate to Contact object > Phone field > Change value on Deterministic insensitive in Encryption Scheme column.
    2. Verification step: Make screenshot this setting.
3. Deployment Settings
    1. Setup > Deployment Settings > Continue > Scroll down and putt mark in the box. (Allow deployments of components when corresponding Apex jobs are pending or in progress. Caution: Enabling this option may cause Apex jobs to fail.)
    2. Verification step: Make screenshot this setting.
4. Deployment Settings
    1. Go to Setup > Apex Test Execution > Options > Disable Parallel Apex Testing
    2. Verification step: Make screenshot this setting.
 
### III. Deployment
1. For each file in the package do the following:
    1. Go to https://workbench.developerforce.com/ and login with 'System Administrator' credentials 
    2. Select Migration tab and choose the Deploy option from the dropdown menu.
    3. Upload zip file by hitting the bottom Choose file.
2. Validation steps
    1. For validating the package please add one more criterion Check Only, the selected options are listed below:
    ```
     Test Level = RunLocalTests
      Check Only
      Ignore Warnings
      Rollback On Error 
     Applicable options for Validation
    ```
    [img1]: /release-info/images/img1.JPG

