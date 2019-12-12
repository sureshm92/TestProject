HCP_Enrollment__c[] hcpeList = [SELECT Id FROM HCP_Enrollment__c];
for(HCP_Enrollment__c hcpe : hcpeList) hcpe.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
update hcpeList;
Study_Site__c[] ssList = [SELECT Id FROM Study_Site__c];
for(Study_Site__c ss : ssList) ss.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
update ssList;
SystemService.markAsScratchOrg();