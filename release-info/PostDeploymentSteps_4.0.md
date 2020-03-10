### Post Deployment Steps 4.0

1) **Related JIRA Task Number Here**. Step description here ... 
2) **Use the next descripiton for steps:**
      * Go to Setup > Click.. > Edit > ..choose/move etc > Click Save
      * Explain the verification step e.x - Make screenshots this setting

 **Example:** 
* a)  Go to Setup > Public  Groups > Click on the “Case team notification” public group > Edit 
* b)  In “Search” picklist choose “Users” and move: Diane Cloose from column “Available Members” to the “Selected Members” > click Save
* c)  Verification step: Make screenshots this setting

**Steps R4.0:**
1) **Community page, PEH-1228**
     * Go to Setup > All community > Click on Builder button near IQVIA Referral Hub > Click on Gear > Find “Messages” (If the page doesn't exist, create it with next properties)
     * Click on the Gear and New Page
     * Choose standard page
     * Click on button New Blank Page and choose OneColumnLayout
     * Fill in the following fields
     * Name: Messages
     * URL: messages
     * Page Access: Community Default Setting: Required Login
     * Title: Messages
     * Verification step: Make screenshot this setting.
     * One column on the layout put Component “Messages Page” and click “Publish”
     * Verification step: Make screenshot this setting.

2) **Activate languages, PEH-1407**
     * Go to Setup > Object Manager > Resource > Record type > For all record type for everyone in turn > Open Record Type > In PickList Language and Languages activate all languages.
     * Verification step: Make screenshot this setting.
     
3) **Activate languages, PEH-1407**
     * Go to Setup > Object Manager > Resource > Record type > For all record type for everyone in turn > Open Record Type > In PickList Conuty and Conutys activate all values.
     * Verification step: Make screenshot this setting.
     * Verification step: Make screenshot this setting.
     
4) Batch Control Panel (PEH-1407)
    1) Go to Setup > Batch Control Panel > Click on button "Add new Job"
        - Select batch – "Batch_ConversationReminder" 
        - Batch label "ConversationReminder" 
        - Select Interval mode – "Minutes" 
        - Relaunch interval - "10" 
        - Scope size – "200" 
    2) Create new Batch Detail
    3) Click on "Run" button near the batch in "Action" column.
    3) Verification step: Make screenshot this setting.
    
5) Batch Control Panel 
    1) Go to Setup > Batch Control Panel > Click on button "Add new Job"
        - Select batch – "Batch_ProcessActionSetupObjects" 
        - Batch label "ProcessActionSetupObjects" 
        - Select Interval mode – "Minutes" 
        - Relaunch interval - "2" 
        - Scope size – "50" 
    2) Create new Batch Detail
    3) Click on "Run" button near the batch in "Action" column.
    3) Verification step: Make screenshot this setting.
    
6) Batch (REF-773)
    1) Go to Setup > Developer Console Debug > Open Execute Anonymous Window > Past ‘Database.executeBatch(new Batch_UpdateParticipantEnrollmentRP(), 20);’ > Click Execute
    2) Verification step: Make screenshot status logs.
    
7) Batch (REF-745)
    1) Go to Setup > Developer Console Debug > Open Execute Anonymous Window > Past ‘Database.executeBatch(new Batch_UpdatePEStatuses('ParticipantEnrollmentId'));’ > Click Execute
    2) Verification step: Make screenshot status logs.
    
8) Batch (REF-745)
    1) Go to Setup > Developer Console Debug > Open Execute Anonymous Window > Past ‘Database.executeBatch(new Batch_UpdatePESHStatuses('ParticipantEnrollmentId'));’ > Click Execute
    2) Verification step: Make screenshot status logs.

9) Batch (PEH-747)
    1) Go to Setup > Developer Console Debug > Open Execute Anonymous Window > Past ‘Database.executeBatch(new Batch_UpdatePatientDelegateStatuses(), 200);’ > Click Execute
    2)Verification step: Make screenshot status logs.

