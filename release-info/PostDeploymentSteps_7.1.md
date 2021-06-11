## I. Post-Deployment steps:

## 1. Transfer all SPNL Profile users to Minimum Access- Salesforce Profile

1.Log into Workbench -> Open Utilities->Click on Apex Execute-> Copy the script from "SPNL_To_MinAccess_Script.txt" and paste it.->Execute the Script

2.After script is executed, run the below query on workbench by clicking on Queries->SOQL Query and see the result on workbench:
SELECT Id FROM User WHERE Profile.Name = 'IQVIA SPNL'

3.If zero records are found from above query then open salesforce->Setup->All Profiles->Open 'IQVIA SPNL'->Click on Delete->Ok.

## 2.Enable member visibility in GSK community.

setup-->All Sites-->GSK Community-->Workspaces-->Administration-->Preferences-->enable See other members of this site-->Save
publish GSK Community
