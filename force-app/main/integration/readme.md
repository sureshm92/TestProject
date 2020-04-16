## All Integrations of PP RH


### Participant Enrollment fields for integration:

1. Field **Screening_ID__c** must be entered if status PE become "Enrollment Success"
2. Field **IsSubjectIDverifiedInSDH__c** - checkbox, equal TRUE if participant on this study verified in SDH. External System one time per day request all PE's with IsSubjectIDverifiedInSDH__c = FALSE. Then process this PE's and update IsSubjectIDverifiedInSDH__c to TRUE (for this used staging table Integration_Patient__c) 
3. Field **External_Key__c** - formula Study_ID__c + "~" + Study_Site__r.Study_Site_Number__c + "~" + Screening_ID__c. Used as ID of PE in SDH. 
4. Field **Patient_ID__c** - participant ID. Updated only for PE's created by integration (from Integration_Patient_Referral__c)



## Inbound integration for Participant. Staging tables:

### Inbound **_Integration_Patient__c_** (update status PE and set verified on SDH checkbox)

This staging tables used for update PE Status (insert status history records) and update IsSubjectIDverifiedInSDH__c field on participant enrollment object. 
- There are custom metadata object SDH_Status__mdt for mapping between SDH statuses and internal PE statuses
- Field **Integration_Patient__c.External_ID__c** used as ID of PE. So Participant_Enrollment__c.External_Key__c must be equal Integration_Patient__c.External_ID__c for update data from staging record.



### Inbound **_Integration_Patient_Referral__c_** (create PE and update or insert Participant)

This staging table used for create or update Participant and insert new Participant Enrollment in the system. 
- If participant already exists in the system then will be used this participant instead creation of new one.
- For new participant enrolment defined Patient_ID__c id of participant.



### Inbound **_Integration_Visit__c_** (update visit data or create adhoc visits)

This staging table update PE Visits, change visit status or create new adhoc visit 
- Field Integration_Visit__c.USUBJID__c used as PE Id (Integration_Visit__c.USUBJID__c = Participant_Enrollment__c.External_Key__c)
- Fields Integration_Visit__c.VISIT__c or Integration_Visit__c.VISITNUM__c used as ID of visit. If visit not found then created adhoc visit for PE
- Used batch Batch_IntegrationVisitProcess for update new records.


### Inbound **_Integration_Visit_Result__c_** (update visit results)


Insert, update or delete visit results. 
- Used Batch Batch_IntegrationVisitResultProcess for process new staging records.
- Visit identification: Integration_VisitResult__c.USUBJID__c + Integration_VisitResult__c.VISIT__c + Integration_VisitResult__c.VSDTC__c = Patient_Visit__c.SDH_Key__c





#Outbound Integrations:

## Outbound send PE to StudyHub

When PE.Participant_Status__c = 'Eligibility Passed' then send PE to StudyHub 
- Named Credential: callout:ServiceNowAndStudyHub
- TODO: need refactoring, move to Remote Call classes


## Outbound send PE Status History to EPR

When PE.Participant_Status__c = 'Eligibility Passed' then send PESH to EPR 
- Named Credential: depend on PE referral source
- TODO: need refactoring, move to Remote Call classes


## Outbound send SMS

Send SMS to Mulesoft
- Action: Action_SendSMS
- Remote Call: RemoteCall_SendSMS
- Named Credential: MulesoftSMS


## Outbound Payments (get card details)

Get card details on the fly, data not stored in the system
- Remote Call: RemoteCall_GetCardDetails
- Named Credential: PaymentCredentials

## Outbound Get Travel Vendor Booking details

Get travel vendor booking details on the fly, data not stored in the system
- RemoteCall: RemoteCall_GetTravelBookingDetails
- NamedCredential: Travel_Bookings