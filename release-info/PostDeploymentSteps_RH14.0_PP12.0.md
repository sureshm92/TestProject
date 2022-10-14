Replace empty values in "Participant DOB format" field with default "DD-MM-YYYY": 1) Goto Setup - Object Manager - Search for "Study Site", Click on it - Fields & Relationships - Search for "Participant DOB format" field , Click on it. 2) Scroll down to the picklist values section, then click on Replace button. 3) Check the Replace all blank values checkbox, and select "DD-MM-YYYY" value in the Select Value Changing To dropdown and click replace

Data correction for date of birth field and age
a)Goto - developer console - Debug - open Execute Anonymous Window - Add the below Script

    Batch_UpdateDOBFieldsParticipants batch = new Batch_UpdateDOBFieldsParticipants();
    Database.executebatch(batch,2000);

    b)Click on execute button
