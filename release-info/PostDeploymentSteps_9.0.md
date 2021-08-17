## 1. Add Batch_CreateRecurringAdminTask to the Batch Control Panel

Add Batch_CreateRecurringAdminTask to the Batch Control Panel :
Open developer console --> control+E to open Anonymous Block --> please paste below code and then click on Execute Highlighted button after highlighting the below code.

Batch_Detail__c batchDetail = new Batch_Detail__c(
Scope_Size__c=1, 
Name= 'Batch_CreateRecurringAdminTask',
Panel_Label__c = 'CreateRecurringAdminTask',
Interval_Mode__c = 'Days',
Relaunch_Interval__c=1
);
insert batchDetail;
then
Go to Setup --> Click on App launcher --> Click on Batch Control Panel-->launch the 'CreateRecurringAdminTask'
