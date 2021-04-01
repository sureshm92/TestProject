## I. Post-Deployment steps:

## 1. Delete Custom Label and Custom Metadata Records.

Go to Setup - Custom labels > find 'ICOS_Description' custom label and Delete it .

Go to Setup - Custom labels > find 'Inducible_co_stimulator' custom label and Delete it .

Go to Setup - Custom Metadata > Visit Result Type >Manage Record >Delete the record whose Visit Result Type Name =Inducible_co_stimulator>Delete It.

## 2. Run the Batch Apex.
## Execute only in lower orgs, This has been executed already in prodn.
After login --> click on gear icon --> select Developer console --> ctrl+E and enter 'Database.executeBatch(new Batch_PE_ExternalKeyWF_Update(), 2000);' --> Highlight this line and then click on 'Execute Highlighted'

## 3.
Click on App Launcher Icon -> Click on Batch Create Panel -> Click on PatientTaskExpire -> In the Edit Modal change the interval mode to minutes and Relaunch Interval to 5 -> Click Save.
## 4.
Click on App Launcher Icon -> Click on Batch Create Panel -> Click on PatientTaskReminder -> In the Edit Modal change the interval mode to minutes and Relaunch Interval to 2 -> Click Save.

## 5.System Administrator profile configuration(needs to be done in fomral and UAT)
1.setup-->Profiles-->System Administrator-->object Setting-->Visit_Results-->check Biomarker checkbox in Assigned record types column.
