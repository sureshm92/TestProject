trigger IntegrationReferralTrigger on Integration_Patient_Referral__c (before insert) {
	QualityCheckController.checkStagingRecord((Integration_Patient_Referral__c)Trigger.new[0]);
}