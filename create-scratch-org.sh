#!/bin/sh

echo "Creating scratch org..."
sfdx force:org:create -f config/project-scratch-def.json -d 30 -s -a $1

echo "Creating OrgWideEmailSddresses..."
sfdx force:data:tree:import -f data/OrgWideEmailAddresses.json

echo "Pushing project in progress..."
sfdx force:org:open -p 'lightning/setup/DeployStatus/home'

sfdx force:source:push -f

if [ $? = 0 ] ; then
    echo "Post setup in progress..."
    sfdx force:apex:execute -f scripts/apex/SFDX_Setup_UpdateUserRole.apex

    sfdx force:data:tree:import -p data/import-plan.json

    sfdx force:apex:execute -f scripts/apex/SFDX_Setup_UpdateSSAndHCPEStatuses.apex

    sfdx force:apex:execute -f scripts/apex/PostSetupBatches.apex

    echo "Publish communities..."
    sfdx force:community:publish --name "IQVIA Referral Hub"
    sfdx force:community:publish --name "GSK Community"

    echo "Assign permissions to admin user..."
    sfdx force:user:permset:assign --permsetname PP_Approved_Languages_Edit
    sfdx force:user:permset:assign --permsetname PP_Batch_Control_Panel
    sfdx force:user:permset:assign --permsetname PP_CTP_Edit
    sfdx force:user:permset:assign --permsetname PP_Manual_Creation_Panel
    sfdx force:user:permset:assign --permsetname PP_Message_Configuration_Edit
    sfdx force:user:permset:assign --permsetname PP_Motivational_Messages_Edit
    sfdx force:user:permset:assign --permsetname PP_Participant_BL
    sfdx force:user:permset:assign --permsetname PP_Participant_Non_PIII_View
    sfdx force:user:permset:assign --permsetname PP_Participant_PII_Edit
    sfdx force:user:permset:assign --permsetname PP_Participant_PII_On_Cases_View
    sfdx force:user:permset:assign --permsetname PP_Payment_Vendors_Edit
    sfdx force:user:permset:assign --permsetname PP_StudySite_Edit
    sfdx force:user:permset:assign --permsetname PP_Study_Resources_Edit
    sfdx force:user:permset:assign --permsetname PP_Toggle_Feature_Delta_Edit
    sfdx force:user:permset:assign --permsetname PP_Travel_Vendors_Edit
    sfdx force:user:permset:assign --permsetname PP_Trial_Surveys_Edit
    sfdx force:user:permset:assign --permsetname PP_Visits_Configuration_Edit
    sfdx force:user:permset:assign --permsetname PP_Visits_Results_Sharing_Edit
    sfdx force:user:permset:assign --permsetname Patient_Portal_Edit_Study_Settings
    sfdx force:user:permset:assign --permsetname SurveyCreator

    echo "Push completed successfully!"
fi
if [ $? != 0 ] ; then
    echo "Push not completed properly, check logs and try again"
fi