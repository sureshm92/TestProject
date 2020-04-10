# IQ for release RH3.1/PP1.1IQVIA 
# Referral Hub/Patient PortalDeployment Process

## I. Pre-requisite steps:
1. Make sure that you have a list of COI to load (ZIP file)
2. Verification step: Make screenshot ZIP files.

## II. Pre-Deployment steps:
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
 
## III. Deployment

### 1. For each file in the package do the following:
1. Go to https://workbench.developerforce.com/ and login with 'System Administrator' credentials 
2. Select Migration tab and choose the Deploy option from the dropdown menu.
3. Upload zip file by hitting the bottom Choose file.

### 2. Validation steps
1. For validating the package please add one more criterion Check Only, the selected options are listed below:
    ```
    - Test Level = RunLocalTests
    - [v] Check Only
    - [v] Ignore Warnings
    - [v] Rollback On Error 
    ```
    
    ![img1](/release-info/images/img1.JPG)

    Click the Next button and if you selected all options correctly, you’ll see the screen as shown below:
    
    ![img2](/release-info/images/img2.JPG)
    
2. Verification step: Make screenshot this setting
    1. Deploy the file by clicking Deploy
    2. You will be forwarded to the page with the deployment status
    
    ![img3](/release-info/images/img3.JPG)
    
    If the file passed deployment successfully, this will be reflected in the Results section as “success: true”. Take the screenshot of this page.
    
    ![img4](/release-info/images/img4.JPG)
    
3. Verification step: Make screenshot this setting. After validation you can deployment to target environment

### 3. Deployment steps
1. Repeat steps from section 1.0 and next steps choose:
    ```
    - Test Level = RunLocalTests
    - [v] Ignore Warnings
    - [v] Rollback On Error 
    ```

    ![img5](/release-info/images/img5.JPG)
    
2. Click the Next button and if you selected all options correctly, you’ll see the screen as shown below:

    ![img6](/release-info/images/img6.JPG)
    
3. Verification step: Make screenshot this setting.
4. Deploy the file by clicking Deploy
5. You will be forwarded to the page with the deployment status

    ![img7](/release-info/images/img7.JPG)

    If the file passed deployment successfully, this will be reflected in the Results section as “success: true”. Take the screenshot of this page.
    
    ![img8](/release-info/images/img8.JPG)
    
6. Verification step: Make screenshot this setting.

## IV. Post-Deployment steps:

1. Batch Control Panel
    1. Go to Setup > Users > Permission Sets > Choose "PP: Batch Control Panel" and assign it to your user
    2. Go to App Launcher > Click on Batch Control Panel item > Click on an icon and run all a bathes in queue
    3. Verification step: Make screenshot this setting.

2. Run the batch
    1. Go to Developer Console > Debug > Open execute Anonymous > Insert Batch_UpdateScreeningIds.run();> Execute

3. Study Site layout
    1. Go to Setup > Object manager > Study site > Page layouts > Edit Study Site Layout > Find field Primary Key ePR> drag it and add beneath Protocol ID > Save
    2. Verification step: Make screenshot this setting.
    3. Go to Setup > Object manager > Study site > Select Compact Layout >Select system default > press Compact Layout Assignments button > Edit Assignments > choose Study Site Page layout as default > Save
    4. Verification step: Make screenshot this setting.

4. Duplicate and matching rules
    1. Go to Setup > Duplicate rules > deactivate Participant deduplicate 1 and 2.
    2. Verification step: Make screenshot this setting.
    3. Go to Setup > Matching rules > deactivate Participant deduplicate 1 and 2.
    4. Verification step: Make screenshot this setting.

5. Sharing Settings
    1. Go to Setup > Sharing Settings > Edit:
    
        On the fields Clinical Trial Profile & Participant Enrollment in column Default External Access to change on Public Read Only or Read/Write.
    2. Verification step: Make screenshot this setting.

6. Community Settings

    Go to Setup > All community > Click on Builder button near IQVIA Referral Hub > Click on Gear > Find “Past Studies” (If the page doesn't exist, create it with next properties)
    
    1. Click on the Gear and New Page
    2. Choose standard page
    3. Click on button New Blank Page and choose OneColumnLayout
    4. Fill in the following fields 
    5. Name: Past Studies
    6. URL: past-studies
    7. Page Access: Community Default Setting: Required Login
    8. Title: Past Studies
    9. Verification step: Make screenshot this setting.
    10. One column on the layout put Component “VisitReportContainer” and click “Publish”
    11. Verification step: Make screenshot this setting.


    Go to Setup > All community > Click on Builder button near IQVIA Referral Hub > Click on Gear > Find “Messages” (If the page doesn't exist, create it with next properties)
    
    1. Click on the Gear and New Page
    2. Choose standard page
    3. Click on button New Blank Page and choose OneColumnLayout
    4. Fill in the following fields 
    5. Name: Messages
    6. URL: messages
    7. Page Access: Community Default Setting: Required Login
    8. Title: Messages
    9. Verification step: Make screenshot this setting.
    10. One column on the layout put Component “Messages Page” and click “Publish”
    11. Verification step: Make screenshot this setting.





