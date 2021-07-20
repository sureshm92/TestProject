## Steps for configuring new Privacy Policy for new Language

As per the July 2021 release for Patient Portal, privacy policy is shown as a popup and in PageView with hyperlinks (Currently implemented only for IQVIA Referral Hub and Janssen community).

1. Go to the 'Terms and Conditions' record where language is 'English' and check the community name in 'Community Name' filed. Also 'Active Portal T&C' checkbox will be true for this record. (This is the master record for that particular community).
2. Now go to the related list.And create new privacy policy under 'Terms and Conditions'.
3. Fill the fields as required and enter the 'Language'.
4. Get the headers from the 'T&C Text' field. Ask buisness for the Headers if not provided.
5. Enter each header in 'Policy Headers' field in seperate lines.
6. Now get the last updated date from the 'T&C Text'. It will be at the end of the text.Ask from buisness if not provided.

## Steps for configuring new Privacy Policy for new communities

1. Make code changes to include required communities in TermsAndCondition.cmp.
2. Follow the above steps for creating the privacy policy record.
