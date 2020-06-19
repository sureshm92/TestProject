## Messaging framework

##### Manual for creating message:

1) In Setup -> Custom Metadata Types -> Notification Type click **Manage Records**
2) Click **New**

#####How to create: 

- **Notification Type Name**: Message_to_HCP_Patient_Accepted_Type
(Where you should put what kind of Recipient Type for this message 
(PT - means Participant, HCP, PI or eRP) and shortly about topic) and then word **Type** to indicate metadata type
- **Parameters Provider**:
Choose that one you need for external parameters 
in your message
- **Description**: put here short description about logic of this message
- **Recipient Type**: PI, HCP, Participant, External Email (if this message for external user outside of SalesForce system)

1) In Setup -> Custom Metadata Types -> Notification Target click **Manage Records**
2) Click **New**

#####How to create: 

- **Notification Target Name**: HCP_Patient_Accepted_Email
(Where you should put what kind of Recipient Type for this message 
(PT - means Participant, HCP, PI or eRP) and shortly about topic) and then word **Email, SMS or Push** to indicate type of message
- **Notification Type**:
Choose that one you created previously to link them
- **Message Body**: (only for SMS and Push target type) Custom Label name (preferable!) or text    
- **Title**: (only for Push target type) Custom Label name (preferable!) or text
- **Email Template**: RP2_Patient_Accepted 
(template name in the system)
- **Email Template Delegate**: (if template for delegate has differences)  
- **Org Wide Email Address**: (for email only) 

for **HCP** Recipient Type use this:
```
IQVIA Referral Hub
```
for **Participant, PI** recipient type use this:
```
Study Specific
```

Study Specific would signal to the system that email could be in GSK or IQVIA style

### Do not forget
After creation **move your type and target** from default metadata directory to messaging/customMetadata

Write down in NotificationCatalog class your new Notification Type for using later in your code
```
static public String MESSAGE_TO_PT_HAS_NOT_LOGGED_IN_TYPE = 'Message_to_PT_has_not_Logged_In_Type';
```
##
####Classes for sending notifications are meant to send notifications. Not to do anything else.
##

#####How to use it in your logic to send email

1) create Notification for each Contact you need
```
Notification__c notification = new Notification__c();
```
#####Where: 

- **Recipient__c**: Id field on Contact
- **WhatId__c**: String field where you can put any SObject Id for addition parameters. For example Participant Enrollment Id.
- **Notification_Type__c**: Notification Type that you created previously
- **Topic__c**: if this notification for subscribe system, use it with Recipient__c = null
- **Email__c**: if this notification for external user, use it with Recipient__c = null and From__c = contact.Id (sender id)
- **isDelegate**: a boolean flag if this notification should use Email Template for delegate in metadata

#####Subscribe logic

There are two objects that you need to create:

1) Topic__c where

- **TopicId__c**: Id field from Clinical_Trial_Profile__c or Therapeutic_Area__c from Therapeutic_Area_Patient__c 
(there are several methods for it in NotificationService)

2) Contact_Topic__c (that would connect Recipient and theme of subscribe)

- **Contact__c**: Id field on Contact
- **Topic__c**: Id field on Topic

####Attention: 
- To send Email and SMS run Batch_ProcessNotification.